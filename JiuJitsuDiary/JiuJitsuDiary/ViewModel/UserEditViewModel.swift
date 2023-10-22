//
//  UserEditViewModel.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/05/23.
//

import Foundation
import UIKit
import FirebaseFirestore
import Firebase
import FirebaseAuth
import Combine



//버그
//이미지를 nil로 바꾸고 닉네임을 변경하면 이미지가 다시뜨고 바뀌지 않은 현상이 발생
//근데 firebase의 이미지는 삭제되어있는 상태

extension Notification.Name {
    static let userProfileUpdated = Notification.Name("userProfileUpdated")
}

class UserEditViewModel: ObservableObject {
    
    var controller: BeltUIController = BeltUIController()
    
    @Published var email: String = ""
    @Published var nickname: String = ""
    @Published var birthday: String = ""
    @Published var profile: UIImage?
    @Published var isEditSucceeded: Bool = false
    @Published var isLoadingViewPresented: Bool = false
    @Published var nicknameIsAvailableNotifyMessage: String = ""
    @Published var birthdayIsAvailableNotifyMessage: String = ""
    @Published var isNicknameValid: Bool = false
    @Published var isBirthdayValid: Bool = false
    
    @Published var isEdit: Bool = false
    @Published var isEditFinished: Bool = false
    
    @Published var isProfileImageEdit: Bool = false
    @Published var isProfileInfoEdit: Bool = false
    
    @Published var isProfileUpdated: Bool = false
    @Published var isSignOutUser: Bool = false
    @Published var isDeleteUser: Bool = false
    @Published var cancellables = Set<AnyCancellable>()
    @Published var oldValue: UserInfo?
    
    let database = Firestore.firestore()
    
    init(){
        $nickname
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map { (text) -> String in
                print("edit nickName")
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
            }.store(in: &cancellables)
        
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
                        if self.convertStringToDate(strDate: text) > Date.getCurrentDate() {
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
            .store(in: &cancellables)
        
        $isSignOutUser
            .sink { isClicked in
                if isClicked {
                    NotificationCenter.default.post(name: .signOutNotification, object: nil)
                }
            }
            .store(in: &cancellables)
        
        $isDeleteUser
            .sink { isClicked in
                if isClicked{
                    NotificationCenter.default.post(name: .deleteUserNotification, object: nil)
                    //self.isDeleteUser = false
                }
            }
            .store(in: &cancellables)
        
        $isProfileUpdated
            .sink { isUpdated in
                if isUpdated {
                    print("notification is Active: userProfileUpdated")
                    NotificationCenter.default.post(name: .userProfileUpdated, object: nil)
                    self.isProfileUpdated = false
                }
            }
            .store(in: &cancellables)
    }
    
    func convertDateToString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
    
    func convertStringToDate(strDate: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.date(from: strDate) ?? Date.getCurrentDate()
    }
    
    func checkIsUserInfoChanged(){
        print("isProfileInfoEdit value: \(isProfileInfoEdit.description)")
        print("isProfileImageEdit value: \(isProfileImageEdit.description)")
        print("oldValue: \(oldValue?.nickname ?? "")")
        print("newValue: \(self.nickname)")
        if oldValue?.nickname != self.nickname ||
            oldValue?.birthday != self.birthday ||
            oldValue?.beltInfo?.color != self.controller.belt.color ||
            oldValue?.beltInfo?.graus != self.controller.belt.graus ||
            oldValue?.beltInfo?.type != self.controller.belt.type {
            self.isProfileInfoEdit = true
        } else {
            self.isProfileInfoEdit = false
        }
        
        if oldValue?.profile != self.profile {
            self.isProfileImageEdit = true
        } else {
            self.isProfileImageEdit = false
        }
        
        if self.isProfileInfoEdit || self.isProfileImageEdit {
            self.isEdit = true
        } else {
            self.isEdit = false
        }
        
        print("isProfileInfoEdit value: \(isProfileInfoEdit.description)")
        print("isProfileImageEdit value: \(isProfileImageEdit.description)")
        print("isEdit Value: \(isEdit.description)")
    }
    
    func updateUserInfo(){
        DispatchQueue.main.async {
            self.database.collection("users").document(self.email).updateData([
                "nickname": self.nickname,
                "birthday": self.birthday,
                "belt" : [
                    "color" : self.controller.belt.color.description,
                    "graus" : self.controller.belt.graus,
                    "type" : self.controller.belt.type.rawValue
                ]
            ]){ err in
                if let error = err {
                    print("update failed: \(error.localizedDescription)")
                    return
                }
            }
        }
    }
    
    func updateUserProfile(completion: @escaping (Bool) -> Void){
        //1.프로필이 nil이 아닐경우
        if self.profile != nil {
            //4. 프로필을 수정했을 경우
            if self.oldValue?.profile != self.profile {
                if let _image = self.profile {
                    FirebaseStorageManager.uploadProfileImage(_image, id: self.email) { url in
                        print("이미지 저장 성공")
                        if url != nil {
                            completion(true)
                            return
                        } else {
                            completion(false)
                            return
                        }
                    }
                } else {
                    print("이미지 로드 실패")
                    completion(false)
                    return
                }
            } else {
                //3. 프로필을 수정하지 않았을 경우
                completion(true)
                return
            }
        } else {
            //2. 기존 프로필을 지웠을 경우
            //2-1.근데 기존에도 nil이었을경우
            if self.oldValue?.profile == nil {
                completion(true)
                return
            } else {
                FirebaseStorageManager.deleteProfileStroage(email: self.email) {  result in
                    if result {
                        print("profile 삭제 성공")
                        completion(true)
                        return
                        
                    } else {
                        print("profile 삭제 실패")
                        completion(false)
                        return
                    }
                }
            }
        }
    }
    
    func updateUser_(completion: @escaping (Bool)->Void){
        
        print("start updateuser func")
        if self.isEdit {
            DispatchQueue.main.async {
                print("isLoading View Presented")
                self.isLoadingViewPresented = true
                
                if self.isProfileInfoEdit {
                    print("updated user profile")
                    self.updateUserInfo()
                    
                    if !self.isProfileImageEdit {
                        completion(true)
                    }
                }
                
                print(self.isProfileImageEdit.description)
                
                if self.isProfileImageEdit {
                    self.updateUserProfile{ result in
                        if !result {
                            print("error")
                        }
                        //isProfileImageEdit = true
                        
                        DispatchQueue.main.async {
                            print("260 isProfileUpdated true")
                            self.isProfileUpdated = true
                        }
                        completion(true)
                    }
                }
                
            }
            
        }
    }
}
