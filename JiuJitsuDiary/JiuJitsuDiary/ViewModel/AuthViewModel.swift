//
//  FirebaseViewModel.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/04/04.
//

import UIKit
import Combine
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftUI

extension Notification.Name {
    static let signOutNotification = Notification.Name("signOutNotification")
    static let deleteUserNotification = Notification.Name("deleteUserNotification")
}

class AuthViewModel: ObservableObject {
    
    @Published var onboardingState: Int = 0
    
    @Published var currentUser: Firebase.User?
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isError: Bool = false
    @Published var message: String?
    @Published var handle: AuthStateDidChangeListenerHandle?
    
    let database = Firestore.firestore()
    @Published var listener: ListenerRegistration?
    @Published var user: UserInfo = UserInfo(email: nil, profile: nil, nickname: nil, birthday: nil, beltInfo: nil, achievements: nil)
    
    //@Published var userSubscriber = PassthroughSubject<UserInfo?, Never>()
    @Published var imageSubscriber = PassthroughSubject<UIImage?, Never>()
    @Published var cancellables = Set<AnyCancellable>()
    
    //user info edit관련 property
    var userEditViewModel: UserEditViewModel
    @Published var isUserInfoEditClick: Bool = false
    
    //achievements관련 property
    var achievementViewModel: AchievementViewModel
    @Published var isAchievementsNilOrEmpty: Bool = true
    @Published var isAchievementViewAppear: Bool = false
    @Published var isAchievementAddClicked: Bool = false
    
    @Published var forgotPasswordEmail: String = ""
    
    var title: String = "로그인 오류"
    
    init() {
        
        achievementViewModel = AchievementViewModel()
        userEditViewModel = UserEditViewModel()
        
        addStateDidChangeHandler()
        
        $isAchievementViewAppear
            .sink { [weak self] isClicked in
                if isClicked {
                    guard let email = self?.currentUser?.email else { return }
                    self?.achievementViewModel.email = email
                    self?.achievementViewModel.achievements = self?.user.achievements
                }
            }
            .store(in: &cancellables)
        
        $isAchievementAddClicked
            .sink { [weak self] isClicked in
                if isClicked {
                    guard let email = self?.currentUser?.email else { return }
                    self?.achievementViewModel.email = email
                    self?.achievementViewModel.isAchievementAddClick = true
                }
            }
            .store(in: &cancellables)
        
        $isUserInfoEditClick
            .sink{ [weak self] isClicked in
                if isClicked {
                    self?.userEditViewModel.isEdit = false
                    self?.userEditViewModel.email = self?.user.email ?? ""
                    self?.userEditViewModel.nickname = self?.user.nickname ?? ""
                    self?.userEditViewModel.birthday = self?.user.birthday ?? ""
                    self?.userEditViewModel.profile = self?.user.profile ?? nil
                    self?.userEditViewModel.controller.belt = self?.user.beltInfo ?? Belt()
                    self?.userEditViewModel.oldValue = self?.user
                }
            }
            .store(in: &cancellables)
        
        addNotification()

    }
    
    deinit {
        removeStateDidChangeHandler()
        listener?.remove()
    }
    
    func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(signOut), name: .signOutNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteFirebaseUser), name: .deleteUserNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileImage), name: .userProfileUpdated, object: nil)
    }

    func addStateDidChangeHandler(){
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, _user) in
            if _user != nil {
                withAnimation {
                    self?.currentUser = _user
                    self?.getUserData()
                    self?.loadProfileImage()
 
                    DispatchQueue.main.async {
                        withAnimation {
                            self?.onboardingState = 1
                        }
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    withAnimation{
                        self?.onboardingState = 0
                    }
                }
            }
        }
    }
    
    func removeStateDidChangeHandler() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(){
        if email.isEmpty {
            self.message = "이메일을 입력해 주세요"
        } else if password.isEmpty {
            self.message = "비밀번호를 입력해 주세요"
        } else {
            Auth.auth().signIn(withEmail: email, password: password){ result, error in
                if error != nil {
                    if let error = AuthErrorCode.Code(rawValue: error!._code){
                        switch error {
                        case .networkError:
                            self.message = "네트워크 오류가 발생했습니다."
                        case .userNotFound:
                            self.message = "사용자 계정을 찾을 수 없습니다."
                        case .operationNotAllowed:
                            self.message = "이메일 및 비밀번호 계정의 사용 설정이 되어있지 않습니다."
                        case .invalidEmail:
                            self.message = "올바르지 않은 이메일 형식입니다."
                        case .userDisabled:
                            self.message = "사용이 중지된 계정입니다."
                        case .wrongPassword:
                            self.message = "일치하지 않는 비밀번호 입니다."
                        default:
                            self.message = "예상치 못한 오류가 발생했습니다."
                        }
                    }
                }
                
                if self.message != nil {
                    self.isError = true
                }
                
                if let user = result?.user {
                    self.isError = false
                    self.currentUser = user
                    //self.isLoggedIn = true
                }
            }
        }
        
        if self.message != nil {
            self.isError = true
        }
    }
    
    @objc func signOut(){
        currentUser = nil
        message = nil
        isError = false
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                withAnimation{
                    self.userEditViewModel.isSignOutUser = false
                    self.onboardingState = 0
                    print("onboardingState: \(self.onboardingState)")
                }
            }
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func getUserData() {
        listener = database.collection("users").document((currentUser?.email!)!).addSnapshotListener { (snapshot, error) in
            if error == nil && snapshot != nil && snapshot!.data() != nil {
                if let data = snapshot!.data() {
                    let email = data["email"] as? String
                    let nickname = data["nickname"] as? String
                    let birthday = data["birthday"] as? String
                    
                    var belt = Belt()
                    if let beltData = data["belt"] as? [String:Any]{
                        belt.color = Color[beltData["color"] as! String]
                        belt.graus = beltData["graus"] as! Double
                        belt.type = beltData["type"] as? String == "Adult" ? BeltType.Adult : BeltType.Youth
                    }
                    
                    //get achivements
                    var achievements: [Achievement]? = []
                    
                    if let achievementsData = data["achievements"] as? [[String:Any]]{
                        if !achievementsData.isEmpty {
                            for item in achievementsData {
                                let date = item["date"] as? String
                                let title = item["title"] as? String
                                let state = item["state"] as? String
                                let uuid = item["uuid"] as? String

                                achievements?.append(Achievement(uuid: uuid ?? "", state: state ?? "", title: title ?? "", date: date ?? ""))
                            }
                            
                            achievements?.sort()
                            self.isAchievementsNilOrEmpty = false
                        } else {
                            self.isAchievementsNilOrEmpty = true
                        }
                    } else {
                        achievements = nil
                        self.isAchievementsNilOrEmpty = true
                    }
                    
                    self.user.email = email
                    self.user.nickname = nickname
                    self.user.birthday = birthday
                    self.user.beltInfo = belt
                    self.user.achievements = achievements
                    self.achievementViewModel.achievements = achievements
                }
            }
            
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
        }
    }
    
    func loadProfileImage(){
        FirebaseStorageManager.downloadProfileImage(url: (currentUser?.email!)!) { image in
            self.user.profile = image
        }
    }
    
    @objc func updateProfileImage(){
        FirebaseStorageManager.downloadProfileImage(url: (currentUser?.email!)!) { image in
            if let _image = image {
                print("image is not nil")
                self.user.profile = _image
            }
            else {
                print("image is nil")
                self.user.profile =  nil
            }
            
        }
    }
    
    @objc func deleteFirebaseUser(){
        deleteUser(email: (user.email!))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("User deleted successfully.")
                }
                DispatchQueue.main.async {
                    withAnimation {
                        self.userEditViewModel.isDeleteUser = false
                        self.onboardingState = 0
                        print("onboardingState : \(self.onboardingState)")
                    }
                }
            }, receiveValue: {})
            .store(in: &cancellables)
    }
    
    private func deleteUser(email: String) -> AnyPublisher<Void, Error> {
        let auth = Auth.auth()
        let firestore = Firestore.firestore()
        let storage = Storage.storage()
        
        return Future<Void, Error> { promise in
            // First, delete the user from Firestore.
            firestore.collection("users").document(email).delete { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                    // Next, delete the user's profile image from Firebase Storage.
                    if self.user.profile != nil {
                        let profileImageRef = storage.reference().child("\(email)/profile")
                        profileImageRef.delete { error in
                            
                            if let error = error {
                                print(error)
                            }
                    }
                }
                
                // Finally, delete the user from Firebase Auth.
                auth.currentUser?.delete(completion: { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                })
            }
        }
        .eraseToAnyPublisher()
    }
}
