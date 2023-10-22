//
//  DefaultAlertView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/02/21.
//

import SwiftUI

struct DefaultAlertView: View{

    @State var isShow = false
    @Environment(\.presentationMode) var presentation
    
    let alertType: AlertType
    var primaryButton: ButtonView
    var secondButton: ButtonView?
    
    init(alertType: AlertType, primaryButton: () -> ButtonView, secondButton: (() -> ButtonView)? = nil){
        
        self.alertType = alertType
        self.primaryButton = primaryButton()
        self.secondButton = secondButton?()
    }
    
    var body: some View {
        ZStack{
            Color.gray.opacity(0.75).edgesIgnoringSafeArea(.all)
                VStack(spacing: 10){
                    ZStack{
                        Circle()
                            .frame(width: 60, height: 60)
                        
                        alertType.alertImage
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.white)
                            .frame(width: 20, height: 20)
                        
                    }
                    
                    VStack(spacing: 5){
                        Text(alertType.title())
                            .font(.system(size: 25))
                        
                            Text(alertType.message())
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        
                        primaryButton
                            .clipShape(Capsule())
                        
                        if let secondButton = secondButton {
                            Spacer()
                            secondButton
                                .clipShape(Capsule())
                        }
                    }
                    .frame(width: 280)
                }
                .padding()
                .frame(maxWidth:315, minHeight: 180)
                .background(Color.white)
                .cornerRadius(20)
        }
    }
}



struct DefaultAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            DefaultAlertView(alertType: .custom(title: "회원가입", message: "회원가입을 하시겠습니까?", image: "person.fill")) {
                ButtonView(title: "네") {
                    
                }
            } secondButton: {
                ButtonView(title: "잠시만요", color: .gray){
                    
                }
            }

//            DefaultAlertView(alertType: .success(title: "완료", message: "회원가입이 완료되었습니다.")) {
//                ButtonView(title: "확인") {
//                    
//                }
//            }
        }
    }
}
