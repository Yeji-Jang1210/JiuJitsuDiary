//
//  ButtonView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/08.
//

import SwiftUI

struct ButtonView: View {
    
    typealias ActionHandler = () -> Void
    
    @Environment(\.isEnabled) var isEnabled
    
    let title: String
    let fontSize: CGFloat
    let height: CGFloat
    let color: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let role: ButtonRole?
    let handler: ActionHandler
    
    init(title: String,
         fontSize: CGFloat = 20,
         height: CGFloat = 55,
         color: Color = Color.primary,
         foregroundColor: Color = Color("background"),
         cornerRadius: CGFloat = 15,
         role: ButtonRole? = nil,
         handler: @escaping ButtonView.ActionHandler){
        
        self.title = title
        self.fontSize = fontSize
        self.height = height
        self.color = color
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.role = role
        self.handler = handler
    }
    
    var body: some View {

        Button(role: role, action: handler){
            Text(title)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .font(.system(size: fontSize))
                .foregroundColor(isEnabled ? foregroundColor : Color(red: 220/255, green: 220/255, blue: 220/255))
                .padding(.horizontal)
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .background(isEnabled ? color : Color(red: 180/255, green: 180/255, blue: 180/255))
                .cornerRadius(cornerRadius)
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(title: "CustomButton"){ }
            .previewLayout(PreviewLayout.sizeThatFits)
            .previewDisplayName("Join Button")
            .padding()
            .disabled(true)
    }
}
