//
//  BeltOptionButtonView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/02/21.
//

import SwiftUI

struct BeltOptionButton: View {
    
    @EnvironmentObject var controller: BeltUIController
    @State var color: Color
    @State var type: BeltType
    
    var body: some View {
        Button {
            controller.belt.color = color
            controller.belt.type = type
        } label: {
            Circle()
                .fill(color)
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 4, y: 4)
                .overlay(
                    GeometryReader { circle in
                        if controller.belt.color == color && controller.belt.type == type {
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: circle.size.width * 0.5, height: circle.size.height * 0.5)
                                .frame(width: circle.size.width, height: circle.size.height)
                                .foregroundColor(color == .white ? .black : .white)
                        }
                    }
                )
        }
        .scaledToFit()
    }
}

struct BeltOptionButton_Previews: PreviewProvider {
    
    @State static var controller = BeltUIController()
    
    static var previews: some View {
        VStack{
            BeltOptionButton(color: .white, type: BeltType.Adult)
                .frame(width: 80, height: 80)
            
            BeltOptionButton(color: .purple, type: BeltType.Youth)
                .frame(width: 80, height: 80)
                
            BeltOptionButton(color: .brown, type: BeltType.Adult)
                .frame(width: 140, height: 140)
            
            Text("\(controller.belt.color.description)")
            Text("\(controller.belt.type.rawValue)")
        }
        .environmentObject(BeltUIController())
        .previewLayout(.sizeThatFits)
    }
}
