//
//  TextFieldView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/08.
//

import SwiftUI

struct TextFieldView: View {
    
    let placeholder: String
    let imgName: String?
    let foregroundColor: Color = Color.secondary
    let fontSize: CGFloat
    let keyboardType: UIKeyboardType
    @Binding var text: String
    
    var body: some View {
        VStack{
            HStack(spacing: 15){
                
                if imgName != nil {
                    Image(systemName: imgName!)
                        .foregroundColor(foregroundColor)
                }
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .font(.system(size:fontSize))
                    .keyboardType(keyboardType)
            }
            .padding(.horizontal)
            .padding(.vertical,5)
            
            Divider()
                .padding(.horizontal)
        }
    }
}

struct TextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TextFieldView(placeholder: "아이디를 입력해 주세요",
                          imgName: "person.fill",
                          fontSize: 18,
                          keyboardType: .default,
                          text: .constant("")
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("ID TextField")
        }
        .padding()
    }
}
