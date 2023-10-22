//
//  ForgotPasswordView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 10/16/23.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @ObservedObject var viewModel: ResetPasswordViewModel = ResetPasswordViewModel()
    @Environment(\.presentationMode) var presentationMode
    @FocusState var idFieldFocused: Bool
    @State var isCompletedSendEmailAlertViewPresented: Bool = false
    @State var isFailedSendEmailAlertViewPresented: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 15){
                Spacer()
                
                HStack {
                    TextFieldView(placeholder: "이메일을 입력해 주세요.", imgName: nil, fontSize: 18, keyboardType: .emailAddress, text: $viewModel.email)
                        .focused($idFieldFocused)
                        .submitLabel(.done)
                        .keyboardType(.emailAddress)
                        .frame(width: UIScreen.main.bounds.width * 0.6)
                        .disabled(viewModel.emailStatus == EmailStatus.CompletedSendEmail)
                    
                    Button {
                        viewModel.sendEmailForPasswordReset()
                    } label: {
                        Text("전송하기")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding()
                            .background(viewModel.emailStatus.disabledDuplicationButton ? .gray : .black)
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.emailStatus.disabledDuplicationButton)
                }
                    
                Text("\(viewModel.emailStatus.message)")
                    .foregroundColor(viewModel.emailStatus.messageColor)
                    .font(.system(size: 15))
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .animation(.easeInOut, value: viewModel.emailStatus)
            
                
                Spacer()
            }
            .navigationTitle("비밀번호 재설정")
            .padding()
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        DispatchQueue.main.async{
                            withAnimation(.smooth){
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } label:{
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
            .onReceive(viewModel.emailSendResultSubject){ result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    if result {
                        isCompletedSendEmailAlertViewPresented.toggle()
                    } else {
                        isFailedSendEmailAlertViewPresented.toggle()
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .alert(isPresented: $isCompletedSendEmailAlertViewPresented, alert: DefaultAlertView(alertType: .success(title: "전송 완료", message: "재설정 이메일이 전송되었습니다."), primaryButton: {
                ButtonView(title: "완료") {
                    DispatchQueue.main.async{
                        isCompletedSendEmailAlertViewPresented = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }))
            .alert(isPresented: $isFailedSendEmailAlertViewPresented, alert: DefaultAlertView(alertType: .error(title: "전송 실패", message: "이메일 전송을 실패했습니다. 다시 입력해 주세요."), primaryButton: {
                ButtonView(title: "완료") {
                    DispatchQueue.main.async{
                        isFailedSendEmailAlertViewPresented = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }))
        }
    }
}

#Preview {
    ForgotPasswordView()
}
