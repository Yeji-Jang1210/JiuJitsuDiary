//
//  LoginView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/03.
//

import SwiftUI

struct LoginView: View {
    
    @State var id: String = ""
    @State var pwd: String = ""
    @State var isShowPassword: Bool = false
    @State var isJoinViewPresented: Bool = false
    
    @FocusState var isIdFocused: Bool
    @FocusState var isPwdFocused: Bool
    
    var body: some View {
        ZStack {
            Color("background").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 80){
                
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
                
                //Spacer()
                
                //로그인 텍스트필드
                VStack(alignment: .trailing, spacing: 30){
                    
                    //아이디 텍스트필드
                    TextFieldView(placeholder: "아이디를 입력해 주세요.", imgName: "person.fill", fontSize: 18, keyboardType: .emailAddress, text: $id)
                        .focused($isIdFocused)
                        .submitLabel(.next)
                        .onSubmit {
                            isPwdFocused = true
                        }
                    
                    //비밀번호 텍스트필드
                    PasswordTextFieldView(placeholder: "비밀번호를 입력해 주세요.", useImg: true, fontSize: 18, pwd: $pwd)
                        .submitLabel(.done)
                        .focused($isPwdFocused)
                }

                Spacer()
                
                //회원가입
                VStack(spacing: 20){
                    Button {
                        
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
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    isIdFocused = true
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
            .preferredColorScheme(.light)
            .previewDevice("iPhone 11")
    }
}
