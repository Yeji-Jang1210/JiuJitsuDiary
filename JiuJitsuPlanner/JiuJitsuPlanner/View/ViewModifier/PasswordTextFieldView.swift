//
//  PasswordTextFieldView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/08.
//

import SwiftUI

struct PasswordTextFieldView: View {

    let placeholder: String
    let useImg: Bool
    let foregroundColor: Color = Color.secondary
    let fontSize: CGFloat
    let keyboardType: UIKeyboardType = UIKeyboardType.alphabet
    
    @Binding var pwd: String
    @State var isShowPassword: Bool = false
    
    var body: some View {
        VStack{
            HStack(spacing: 15){
                
                if useImg {
                    Image(systemName: "lock.fill")
                        .foregroundColor(foregroundColor)
                }
                
                if isShowPassword {
                    TextField(placeholder, text: $pwd)
                        .autocapitalization(.none)
                        .font(.system(size: fontSize))
                        .keyboardType(keyboardType)
                } else {
                    SecureField(placeholder,text: $pwd)
                        .autocapitalization(.none)
                        .font(.system(size: fontSize))
                        .keyboardType(keyboardType)
                }
                                            
                Button {
                    isShowPassword.toggle()
                } label: {
                    Image(systemName: isShowPassword ? "eye" : "eye.slash")
                        .foregroundColor(foregroundColor)
                }
            }
            .padding(.horizontal)
            .padding(.vertical,5)
            
            Divider()
                .padding(.horizontal)
        }
    }
}

struct PasswordTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordTextFieldView(placeholder: "비밀번호를 입력해 주세요", useImg: true, fontSize: 18, pwd: .constant(""))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Password TextField")
            .padding()
    }
}
