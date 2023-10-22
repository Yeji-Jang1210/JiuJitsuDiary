//
//  BeltView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/02/23.
//

import SwiftUI

struct BeltView: View {
    
    @EnvironmentObject var controller: BeltUIController
    
    @State var rows: [GridItem] = Array(repeating: .init(.fixed(60)), count: 1)
    @State var isSliderEdited: Bool = false
    @State var isBlack = false
    
    var body: some View {
        
        VStack{
            
            //벨트
            VStack(alignment: .leading){
                Text("벨트")
                BeltUI()
                    .environmentObject(controller)
            }
            
            //벨트 색상 버튼
            VStack(spacing: 40){
                ForEach(Array(controller.beltTypes.keys.sorted{ $0.rawValue < $1.rawValue }), id: \.self){ key in
                    VStack(spacing: 20){
                        Text("\(key.rawValue)")
                            .font(.system(size: 15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        LazyHGrid(rows: rows, spacing: .minimum(25, 25)){
                            ForEach(controller.beltTypes[key]!, id: \.self){ color in
                                VStack {
                                    BeltOptionButton(color: color, type: key)
                                        .environmentObject(controller)
                                    Text("\(color.description)")
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }.padding()
            
            Divider()
                .padding(.vertical)
            
            //그랄 슬라이더
            VStack(alignment: .leading){
                Text("그랄: \(String(format: "%.f", controller.belt.graus))")
                
                VStack{
                    Slider(value: $controller.belt.graus, in: 0...controller.maxGraus, step: 1.0) {
                        Text("")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("\(String(format: "%.f", controller.maxGraus))")
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct BeltUI: View {
    
    @EnvironmentObject var controller: BeltUIController
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(controller.belt.color)
                .animation(Animation.default, value: controller.belt.color)
                .frame(height: 30)
                .padding()
            
            HStack{
                Spacer()
                
                ZStack {
                    Rectangle()
                        .animation(Animation.default, value: controller.pretaWidth)
                        .frame(width: controller.pretaWidth, height: 30)
                        .foregroundColor(controller.pretaColor)
                    
                    HStack{
                        Spacer()
                        
                        ForEach(0..<Int(controller.belt.graus), id: \.self){ count in
                            Rectangle()
                                .frame(width: 5, height: 30)
                                .foregroundColor(.white)
                                .animation(Animation.default, value: controller.belt.graus)
                        }
                    }
                    .padding(.trailing, 8)
                }
                .onChange(of: controller.belt.color) {
                    controller.changeToBlackBeltOption(color: controller.belt.color)
                }
                .fixedSize()
            }.padding(.trailing,40)
        }
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 2, y: 3)
    }
    
}

struct BeltView_Previews: PreviewProvider {
    static var previews: some View {
        BeltView()
            .environmentObject(BeltUIController())
            .previewLayout(.sizeThatFits)
            
    }
}
