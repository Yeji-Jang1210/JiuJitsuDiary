//
//  ResetPasswordViewModel.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 10/16/23.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ResetPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var emailStatus: EmailStatus = .EmptyEmail
    @Published var cancellable = Set<AnyCancellable>()
    @Published var isEmailSendSuccessfuly: Bool = false
    @Published var emailSendResultSubject = PassthroughSubject<Bool, Never>()
    
    init(){
        $email
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .map { (text) -> EmailStatus in
                if self.email.isEmpty {
                    return .EmptyEmail
                } else if !ValidateUserInfo.validateUsableEmail(email: self.email) {
                    return .IncorrectEmail
                } else {
                    return .ReadyForSendEmail
                }
            }
            .sink { emailStatus in
                self.emailStatus = emailStatus
                print(emailStatus.message)
            }
            .store(in: &cancellable)
      
    }
    
    func sendEmailForPasswordReset(){
        Auth.auth().sendPasswordReset(withEmail: self.email) { error in
                if let error = error {
                    self.isEmailSendSuccessfuly = false
                    print("Error sending password reset email: \(error.localizedDescription)")
                    self.emailSendResultSubject.send(false)
                } else {
                    self.isEmailSendSuccessfuly = true
                    self.emailStatus = .CompletedSendEmail
                    print("Password reset email sent successfully.")
                    self.emailSendResultSubject.send(true)
                }
            }
    }
}
