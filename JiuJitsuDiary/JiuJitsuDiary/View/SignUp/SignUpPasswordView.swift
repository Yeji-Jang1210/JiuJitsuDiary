//
//  SignUpPasswordView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/02/13.
//

import SwiftUI

struct SignUpPasswordView: View {
    
    @EnvironmentObject var viewModel: SignUpViewModel
    @State var attempts: Int = 1
    
    @FocusState var pwdFieldFocused: Bool
    @FocusState var pwdCheckedFieldFocused: Bool

    @ViewBuilder
    var body: some View {
        BaseSignUpView(title: "사용할 패스워드를 입력해주세요.",discription: "8~16자 영문+숫자+특수문자 조합을 사용해주세요.") {

            VStack(spacing: 50){
                
                Spacer()
                
                VStack{
                    PasswordTextFieldView(placeholder: "패스워드를 입력해 주세요.", useImg: false, fontSize: 20, pwd: $viewModel.password)
                        .onSubmit {
                            pwdCheckedFieldFocused = true
                        }
                        .focused($pwdFieldFocused)
                        .submitLabel(.next)
                    
                    if !viewModel.isPasswordAvailable {
                        if viewModel.password.count >= 1 {
                            Text("⚠️ 잘못된 비밀번호 형식입니다.")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(Color.red)
                                .padding(.horizontal)
                                .font(.system(size: 15))
                                .modifier(Shake(animatableData: CGFloat(attempts)))
                        }
                    } else {
                        Text("✅ 사용가능한 비밀번호입니다.")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(Color.green)
                            .padding(.horizontal)
                            .font(.system(size: 15))
                    }
                }
                
                VStack {
                    PasswordTextFieldView(placeholder: "패스워드를 다시 입력해 주세요.", useImg: false, fontSize: 20, pwd: $viewModel.passwordChecked)
                        .focused($pwdCheckedFieldFocused)
                        .submitLabel(.done)
                    
                    if viewModel.passwordStatus != .WrongPassword {
                        Text("\(viewModel.passwordStatus.errorMessage)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(Color.red)
                            .padding(.horizontal)
                            .font(.system(size: 15))
                            .modifier(Shake(animatableData: CGFloat(attempts)))
                    }
                    
                }
                
                Spacer()
                
                VStack{
                    ButtonView(title: "확인") {
                        withAnimation(.easeInOut(duration: 0.5)){
                            if !viewModel.passwordStatus.isError {
                                viewModel.onboardingState = 2
                            } else {
                                attempts += 1
                                setPasswordStatusKeboardFocus()
                            }
                        }
                    }
                    
                    ButtonView(title: "이전으로", color: Color(red: 190/255, green: 190/255, blue: 190/255)) {
                        withAnimation(.easeInOut(duration: 0.5)){
                            viewModel.onboardingState = 0
                            pwdFieldFocused = false
                            pwdCheckedFieldFocused = false
                        }
                    }
                }
            }
        }
    }
}

extension SignUpPasswordView {
        func setPasswordStatusKeboardFocus() {
            switch viewModel.passwordStatus {
            case .EmptyPassword:
                pwdFieldFocused = true
                pwdCheckedFieldFocused = false
            case .EmptyRecheckedPassword:
                if !viewModel.isPasswordAvailable {
                    pwdFieldFocused = true
                    pwdCheckedFieldFocused = false
                }
                else {
                    pwdFieldFocused = false
                    pwdCheckedFieldFocused = true
                }
            case .WrongPassword:
                pwdFieldFocused = true
                pwdCheckedFieldFocused = false
            case .IncorrectPassword:
                pwdFieldFocused = false
                pwdCheckedFieldFocused = true
            case .CorrectPassword:
                break
            }
        }
}

struct SignUpPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPasswordView()
            .environmentObject(SignUpViewModel())
    }
}
