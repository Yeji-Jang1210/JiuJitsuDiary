//
//  SignUpViewModel.swift
//  JiuJitsuPlanner
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
    
    @Published private var user: UserInfo = UserInfo()
    
    // MARK: - UserInfo Properties
    var id: String {
        get {
            return user.userId
        }
        set(newValue){
            user.userId = newValue
        }
    }
    
    var pwd: String {
        get {
            return user.userPwd
        }
        set(newValue){
            user.userPwd = newValue
        }
    }
    
    var img: UIImage? {
        get {
            return user.userImg
        }
        set(newValue){
            user.userImg = newValue
        }
    }
    
    var nickname: String {
        get {
            return user.userNickname
        }
        set(newValue){
            user.userNickname = newValue
        }
    }
    
    var birthday: String {
        get {
            return user.userBirthday
        }
        set(newValue){
            user.userBirthday = newValue
        }
    }
    
    var beltInfo: Belt {
        get {
            return user.userBeltInfo
        }
        
        set(newValue){
            user.userBeltInfo = newValue
        }
    }
    
    // MARK: - View Properties
    
    @Published var onboardingState: Int = 0
    
    //@Published var isIdDuplicate: Bool?
    @Published var idStatus: IdStatus = IdStatus.EmptyEmail
    var isIdVerificationCompleted: Bool = false
    var isPwdValid: Bool = false
    var isNicknameValid: Bool = false
    var isBirthdayValid: Bool = false
    var passwordStatus: PasswordStatus = PasswordStatus.EmptyPassword
    
    @Published var pwdChecked: String = ""
    
    @Published var maxGraus: Double = 4
    @Published var pretaWidth: CGFloat = 60
    @Published var pretaColor: Color = Color.black
    
    @Published var image: UIImage?
    @Published var dismissSignUpPage: Bool = false

    let dataBase = Firestore.firestore()
    @Published var isSignUpSucceeded: Bool?
    @Published var isLoadingViewPresented: Bool = false
    
    // MARK: - funcion
    func checkDuplicatedId(){
        dataBase.collection("users").getDocuments { snapshot, error in
            if snapshot != nil, error == nil {
                for document in snapshot!.documents {
                    if self.id == document.documentID {
                        print("존재하는 아이디입니다.")
                        self.isIdVerificationCompleted = false
                        self.idStatus = .DuplicateEmail
                        break
                    } else {
                        self.isIdVerificationCompleted = true
                        self.idStatus = .CorrectEmail
                    }
                }
            }
            if let err = error { print(err) }
        }
    }
    
    func validateUsableId() -> Bool{
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let email = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return email.evaluate(with: id)
    }
    
    func setIdStatus() {
        if id.isEmpty {
            idStatus = .EmptyEmail
        } else if !validateUsableId() {
            idStatus = .IncorrectEmail
        } else if isIdVerificationCompleted {
            idStatus = .CorrectEmail
        } else {
            idStatus = .NotValidateEmail
        }
    }
    
    func isPasswordCorrect() -> Bool {
        setPasswordStatus()
        return passwordStatus.isError
    }
    
    func validateUsablePwd() -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,16}"
        let password = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        isPwdValid = password.evaluate(with: pwd)
        return isPwdValid
    }
    
    func setPasswordStatus(){
        //3. 패스워드와 재입력한 패스워드가 일치하지 않을 때
        //4. 패스워드의 조건이 충족되지 않을 때
        if pwd.isEmpty || pwdChecked.isEmpty {
            //1. 패스워드가 입력되지 않을 때
            //2. 패스워드를 재입력 하지 않을 때
            if (pwd.isEmpty && pwdChecked.isEmpty) || pwd.isEmpty {
                passwordStatus = .EmptyPassword
            } else if pwdChecked.isEmpty {
                passwordStatus = .EmptyRecheckedPassword
            }
        } else if pwd != pwdChecked{
            passwordStatus = .IncorrectPassword
        } else if !isPwdValid {
            passwordStatus = .WrongPassword
        } else {
            passwordStatus = .CorrectPassword
        }
    }
    
    func validateBirthday() -> String {
        if birthday.isEmpty {
            isBirthdayValid = false
            return "생년월일을 입력해 주세요."
        } else {
            let dateRegex = "^(19[0-9][0-9]|20\\d{2})(0[0-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])$"
            let date = NSPredicate(format:"SELF MATCHES %@", dateRegex)
            isBirthdayValid = date.evaluate(with: birthday)
            if !isBirthdayValid {
                return "유효하지 않는 생년월일 입니다."
            } else {
                if user.convertStringToDate(strDate: birthday) > Date.now {
                    isBirthdayValid = false
                    return "오늘날짜 이상의 값 입니다."
                }
            }
            isBirthdayValid = true
            return ""
        }
    }
    
    func changeToBlackBeltOption(){
        if beltInfo.color == Color.black {
            maxGraus = 6
            pretaWidth = 85
            pretaColor = Color.red
        }
        else {
            if beltInfo.graus >= maxGraus - 1 {
                beltInfo.graus = 4
            }
            maxGraus = 4
            pretaWidth = 60
            pretaColor = Color.black
        }
    }
    
    func validateNickname() -> String {
        if nickname.isEmpty {
            isNicknameValid = false
            return "별명을 입력해 주세요."
        }
        else if nickname.count < 3 {
            isNicknameValid = false
            return "최소 세글자 이상이어야 합니다."
        }
        else if nickname.count >= 16 {
            isNicknameValid = false
            return "최대 16글자까지 가능합니다."
        }
        isNicknameValid = true
        return ""
    }
    
    //Use FirebaseAuth
    func registerUser() {
        Auth.auth().createUser(withEmail: self.id, password: self.pwd){ authResult, error in
            if error == nil {
                self.dataBase.collection("users").document(self.id).setData([
                    "email" : self.id,
                    "nickname" : self.nickname,
                    "birthday" : self.birthday,
                    "belt" : [
                        "color" : self.beltInfo.color.description,
                        "graus" : self.beltInfo.graus,
                        "type" : self.beltInfo.type.rawValue
                    ]
                ]) { error in
                    if let err = error {
                        print(err)
                        self.isLoadingViewPresented = false
                        self.isSignUpSucceeded = false
                        
                        return
                    } else {
                        if self.img != nil {
                            if let image = self.img {
                                FirebaseStorageManager.uploadProfileImage(image, id: self.id) { url in
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

class FirebaseStorageManager {
    
    //FirebaseStorage사용
    //Storage에 imageName과 imageData를 파라미터로 넘겨서 저장 요청
    static func uploadProfileImage(_ image: UIImage, id: String, completion: @escaping ((_ url: String?)->())) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let filePath = "profile"

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"

        let storageRef = Storage.storage().reference().child("\(id)/\(filePath)")
        storageRef.putData(imageData, metadata: metaData){ metaData, error in
            storageRef.downloadURL { url, error in
                if let _url = url?.absoluteString {
                    completion(_url)
                    print(_url)
                    return
                }
            }
        }
    }
}
