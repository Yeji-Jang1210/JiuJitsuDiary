//
//  SignUpViewModel.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/03/08.
//

import UIKit
import Combine
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftUI

class SignUpViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var emailStatus: EmailStatus = EmailStatus.EmptyEmail
    @Published var isEmailDuplicateChecked: Bool?
    
    @Published var password: String = ""
    @Published var passwordChecked: String = ""
    @Published var passwordStatus: PasswordStatus = PasswordStatus.EmptyPassword
    @Published var isPasswordAvailable: Bool = false
    
    @Published var nickname: String = ""
    @Published var nicknameIsAvailableNotifyMessage : String = ""
    var isNicknameValid: Bool = false
    
    @Published var birthday: String = ""
    @Published var isBirthdayValid: Bool = false
    @Published var birthdayIsAvailableNotifyMessage : String = ""
    @Published var image: UIImage?
    
    var beltController = BeltUIController()
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - View Properties
    
    @Published var onboardingState: Int = 0
    @Published var dismissSignUpPage: Bool = false
    
    let dataBase = Firestore.firestore()
    @Published var isSignUpSucceeded: Bool?
    @Published var isLoadingViewPresented: Bool = false
    @Published var signUpErrorMessage: String = ""
    
    // MARK: - funcion
    
    init(){
        addEmailSubscriber()
        addPasswordSubscriber()
        addUserInfoSubscriber()
        //NotificationCenter.default.addObserver(self, selector: #selector(handleBeltInfo(_:)), name: .beltInfoUpdated, object: nil)
    }
    
    func addEmailSubscriber(){
        $email
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .map { (text) -> EmailStatus in
                if self.isEmailDuplicateChecked == nil {
                    if self.email.isEmpty {
                        return .EmptyEmail
                    } else if !ValidateUserInfo.validateUsableEmail(email: text) {
                        return .IncorrectEmail
                    } else {
                        return .NotValidateEmail
                    }
                } else {
                    self.isEmailDuplicateChecked = nil
                    return .NotValidateEmail
                }
            }
            .sink { emailStatus in
                self.emailStatus = emailStatus
                print(emailStatus.message)
            }
            .store(in: &cancellable)
        
        $isEmailDuplicateChecked
            .map { (bool) -> EmailStatus in
                if let result = bool {
                    if result {
                        return .CorrectEmail
                    } else {
                        return.DuplicateEmail
                    }
                } else {
                    return .NotValidateEmail
                }
            }
            .sink { emailStatus in
                self.emailStatus = emailStatus
            }
            .store(in: &cancellable)
    }
    
    func addPasswordSubscriber(){
        $password
            .combineLatest($passwordChecked)
            .map { (password, confirmPassword) -> PasswordStatus in
                if password.isEmpty {
                    return .EmptyPassword
                }
                else if !self.validatePassword() {
                    return .WrongPassword
                }
                else if password == confirmPassword {
                    return .CorrectPassword
                }
                else {
                    if confirmPassword.isEmpty {
                        return .EmptyRecheckedPassword
                    } else {
                        return .IncorrectPassword
                    }
                    
                }
            }
            .sink(receiveValue: { status in
                if status == .EmptyPassword {
                    self.isPasswordAvailable = false
                }
                self.passwordStatus = status
                print("status: \(status.errorMessage)")
            })
            .store(in: &cancellable)
        
    }
    
    func validatePassword() -> Bool{
        self.isPasswordAvailable = ValidateUserInfo.validateUsablePwd(password: password)
        return isPasswordAvailable
    }
    
    func addUserInfoSubscriber(){
        $nickname
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map { (text) -> String in
                if text.isEmpty {
                    self.isNicknameValid = false
                    return "별명을 입력해 주세요."
                }
                else if text.count < 3 {
                    self.isNicknameValid = false
                    return "최소 세글자 이상이어야 합니다."
                }
                else if text.count >= 16 {
                    self.isNicknameValid = false
                    return "최대 16글자까지 가능합니다."
                }
                self.isNicknameValid = true
                return ""
            }
            .sink{ message in
                self.nicknameIsAvailableNotifyMessage = message
            }.store(in: &cancellable)
        
        $birthday
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map{ (text) -> String in
                if text.isEmpty {
                    self.isBirthdayValid = false
                    return "생년월일을 입력해 주세요."
                } else {
                    let dateRegex = "^(19[0-9][0-9]|20\\d{2})(0[0-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])$"
                    let date = NSPredicate(format:"SELF MATCHES %@", dateRegex)
                    self.isBirthdayValid = date.evaluate(with: text)
                    if !self.isBirthdayValid {
                        return "유효하지 않는 생년월일 입니다."
                    } else {
                        if Date.convertStringToDate(strDate: text) > Date.getCurrentDate() {
                            self.isBirthdayValid = false
                            return "오늘날짜 이상의 값 입니다."
                        }
                    }
                    self.isBirthdayValid = true
                    return ""
                }
            }
            .sink { message in
                self.birthdayIsAvailableNotifyMessage = message
            }
            .store(in: &cancellable)
    }
    
    func checkDuplicatedEmail(){
        dataBase.collection("users").getDocuments { snapshot, error in
            if snapshot != nil, error == nil {
                if let isSnapshotEmpty = snapshot?.isEmpty {
                    if isSnapshotEmpty {
                        print("document is Empty")
                        self.isEmailDuplicateChecked = true
                    }else {
                        for document in snapshot!.documents {
                            if self.email == document.documentID {
                                print("존재하는 아이디입니다.")
                                self.isEmailDuplicateChecked = false
                                break
                            } else {
                                self.isEmailDuplicateChecked = true
                            }
                        }
                    }
                }
            }
            if let err = error { print(err) }
        }
    }
    
    //Use FirebaseAuth
    func registerUser() {
        
        Auth.auth().createUser(withEmail: email, password: password){ authResult, error in
            if error == nil {
                self.dataBase.collection("users").document(self.email).setData([
                    "email" : self.email,
                    "nickname" : self.nickname,
                    "birthday" : self.birthday,
                    "belt" : [
                        "color" : self.beltController.belt.color.description,
                        "graus" : self.beltController.belt.graus,
                        "type" : self.beltController.belt.type.rawValue
                    ]
                ]) { error in
                    if let err = error {
                        print(err)
                        self.isLoadingViewPresented = false
                        self.isSignUpSucceeded = false
                        
                        return
                    } else {
                        if self.image != nil {
                            if let _image = self.image {
                                FirebaseStorageManager.uploadProfileImage(_image, id: self.email) { url in
                                    print("이미지 저장 성공")
                                    self.isLoadingViewPresented = false
                                    self.isSignUpSucceeded = true
                                }
                            } else {
                                print("이미지 저장 실패")
                                self.isLoadingViewPresented = false
                                self.isSignUpSucceeded = false
                            }
                        } else {
                            print("이미지 선택 안함")
                            self.isLoadingViewPresented = false
                            self.isSignUpSucceeded = true
                        }
                    }
                }
            } else if let _error = error {
                print(_error.localizedDescription)
                self.isLoadingViewPresented = false
                self.isSignUpSucceeded = false
            }
        }
    }
}

class ValidateUserInfo {
    static func validateUsableEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let filter = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return filter.evaluate(with: email)
    }
    
    static func validateUsablePwd(password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,16}"
        let filter = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return filter.evaluate(with: password)
    }
}
