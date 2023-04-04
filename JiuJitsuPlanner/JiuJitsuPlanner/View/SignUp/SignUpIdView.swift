//
//  SignUpIdView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/13.
//

import SwiftUI

struct SignUpIdView: View {
    
    @EnvironmentObject var viewModel: SignUpViewModel
    //@StateObject var viewModel: SignUpViewModel = SignUpViewModel()
    @FocusState var idFieldFocused: Bool
    
    @State var isPresentAlert: Bool = false
    @State var attempts: Int = 1
    
    @ViewBuilder
    var body: some View {
        BaseSignUpView(title: "사용할 아이디를 입력해주세요.",
                       discription: "아이디는 이메일 형식으로 가능하며, \n한번 지정한 아이디는 변경할 수 없습니다.") {
            
            VStack(alignment: .trailing){
                
                HStack {
                    TextFieldView(placeholder: "아이디 입력해 주세요.", imgName: nil, fontSize: 18, keyboardType: .emailAddress, text: $viewModel.id)
                        .focused($idFieldFocused)
                        .submitLabel(.done)
                        .keyboardType(.emailAddress)
                        .frame(width: UIScreen.main.bounds.width * 0.6)
                        .disabled(viewModel.idStatus == IdStatus.CorrectEmail)
                    
                    Button {
                        viewModel.checkDuplicatedId()
                    } label: {
                        Text("중복확인")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding()
                            .background(viewModel.idStatus.disabledDuplicationButton ? .gray : .black)
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.idStatus.disabledDuplicationButton)
                }
                .task(id: viewModel.id) {
                    viewModel.setIdStatus()
                }
                
                Text("\(viewModel.idStatus.message)")
                    .foregroundColor(viewModel.idStatus.messageColor)
                    .font(.system(size: 15))
                    .padding(.vertical)
                    .modifier(Shake(animatableData: CGFloat(attempts)))
                
            }
            
            Spacer()
            
            ButtonView(title: "확인") {
                withAnimation(.easeInOut(duration: 0.5)){
                    if viewModel.idStatus == IdStatus.CorrectEmail {
                        if idFieldFocused {
                            idFieldFocused = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                            withAnimation(.easeInOut(duration: 0.5)){
                                viewModel.onboardingState = 1
                            }
                        }
                    }
                    else {
                        if viewModel.id.isEmpty{
                            isPresentAlert = true
                        } 
                        else {
                            attempts += 1
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
                                idFieldFocused = true
                            }
                            
                        }
                    }
                }
            }
        }
       .onAppear {
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
               idFieldFocused = true
           }
       }
       .alert(isPresented: $isPresentAlert,
              alert:
                DefaultAlertView(alertType: .error(title: "오류", message: "아이디를 입력해주세요.")){
           ButtonView(title: "확인") {
               isPresentAlert = false
               idFieldFocused = true
           }
       }
       )
    }
}

struct SignUpIdView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpIdView()
            .environmentObject(SignUpViewModel())
    }
}
