//
//  BaseSignUpView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/02/13.
//

import SwiftUI

struct BaseSignUpView<Content>: View where Content: View {
    
    let title: String
    let discription: String
    let content: () -> Content
    
    init(title: String, discription: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.title = title
        self.discription = discription
    }
    
    var body: some View {
        VStack(spacing: 10){
            Text(title)
                .font(.system(size: 25))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(discription)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity,alignment: .leading)
            
            Spacer()
            
            content()
            
        }
        .padding()
    }
}

struct BaseSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        BaseSignUpView(title: "Title", discription: "이메일 형식으로 입력해 주세요") {
            TextFieldView(placeholder: "아이디를 입력해주세요", imgName: "person.fill", fontSize: 25, keyboardType: .default, text: .constant(""))
            
            Spacer()
            
            ButtonView(title: "확인"){
                
            }
        }
    }
}
