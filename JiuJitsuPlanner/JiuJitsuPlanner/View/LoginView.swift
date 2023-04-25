//
//  LoginView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/03.
//

import SwiftUI

struct LoginView: View {
    
    enum Field: Hashable {
        case email, password
    }
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State var id: String = ""
    @State var pwd: String = ""
    @State var isShowPassword: Bool = false
    @State var isJoinViewPresented: Bool = false
    
    @State var errorAlertView: DefaultAlertView?
    @FocusState private var focusField: Field?
    
    var body: some View {
        ZStack {
            Color("background").edgesIgnoringSafeArea(.all)
            
            VStack {
                
                Spacer()
                
                //title
                VStack(spacing: -20) {
                    Text("JIUJITSU")
                        .italic()
                        .font(.system(size: 50))
                        .fontWeight(.heavy)
                        
                    Text("PLANNER")
                        .italic()
                        .font(.system(size: 50))
                        .fontWeight(.heavy)
                }
                
                Spacer()
                
                //로그인 텍스트필드
                
                VStack(alignment: .trailing, spacing: 30){
                    
                    //아이디 텍스트필드
                    TextFieldView(placeholder: "이메일을 입력해 주세요.", imgName: "person.fill", fontSize: 18, keyboardType: .emailAddress, text: $viewModel.email)
                        .focused($focusField, equals: .email )
                        .submitLabel(.next)
                        .onSubmit {
                            focusField = .password
                        }
                    
                    //비밀번호 텍스트필드
                    PasswordTextFieldView(placeholder: "비밀번호를 입력해 주세요.", useImg: true, fontSize: 18, pwd: $viewModel.password)
                        .submitLabel(.done)
                        .focused($focusField, equals: .password)
                    
                    Text(viewModel.message ?? "")
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .opacity(viewModel.isError ? 1 : 0)
                        .animation(.easeInOut, value: viewModel.isError)
                }

                Spacer()
                
                //회원가입
                VStack(spacing: 20){
                    
                    Button {
                        //비밀번호 찾는 sheet
                        
                    } label: {
                        Text("비밀번호를 잊으셨나요?")
                    }.padding(.horizontal)
                    
                    Button {
                        withAnimation {
                            viewModel.signIn()
                        }
                    } label: {
                        Text("로그인")
                            .padding()
                            .padding(.horizontal, 80)
                            .foregroundColor(Color("background"))
                    }
                    .background(.primary)
                    .cornerRadius(20)
                    
                    HStack{
                        Text("아직 회원이 아니신가요?")
                        Button{
                            isJoinViewPresented.toggle()
                        } label: {
                            Text("회원가입")
                        }
                        .fullScreenCover(isPresented: $isJoinViewPresented) {
                            SignUpView()
                        }
                    }
                }
                
            }
            .ignoresSafeArea(.keyboard)
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    focusField = .email
                }
            }
            .padding()
            
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
            .preferredColorScheme(.light)
            .previewDevice("iPhone 11")
    }
}
