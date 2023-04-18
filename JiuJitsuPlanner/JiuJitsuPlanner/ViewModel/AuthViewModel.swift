//
//  FirebaseViewModel.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/04/04.
//

import UIKit
import Combine
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftUI

class AuthViewModel: ObservableObject {
    
    @Published var currentUser: Firebase.User?
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAlertPresented: Bool = false
    @Published var message: String?
    
    let valiableLoginInfo: PassthroughSubject = PassthroughSubject<(String,String), Error>()
    private var cancellbles: [AnyCancellable] = []
    
    var title: String = "로그인 오류"
    
    init() {
        currentUser = Auth.auth().currentUser
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
                
                self.currentUser = result?.user
            }
        }
        
        if self.message != nil {
            self.isAlertPresented.toggle()
        }
    }
}
