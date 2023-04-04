//
//  BeltView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/23.
//

import SwiftUI

struct BeltView: View {
    
    @EnvironmentObject var viewModel: SignUpViewModel
    @State var rows: [GridItem] = Array(repeating: .init(.fixed(60)), count: 1)
    @State var isSliderEdited: Bool = false
    @State var isBlack = false
    
    
    
    var body: some View {
        
        let beltTypes = [
            BeltType.Adult: [Color.white, Color.blue, Color.purple, Color.brown, Color.black],
            BeltType.Youth: [Color.white, Color.gray, Color.yellow, Color.orange, Color.green]
        ]
        
        VStack{
            
            //벨트
            VStack(alignment: .leading){
                Text("벨트")
                BeltUI()
            }
            
            //벨트 색상 버튼
            VStack(spacing: 40){
                ForEach(Array(beltTypes.keys.sorted{ $0.rawValue < $1.rawValue }), id: \.self){ key in
                    VStack(spacing: 20){
                        Text("\(key.rawValue)")
                            .font(.system(size: 15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        LazyHGrid(rows: rows, spacing: .minimum(25, 25)){
                            ForEach(beltTypes[key]!, id: \.self){ color in
                                VStack{
                                    BeltOptionButton(color: color, type: key)
                                        .environmentObject(viewModel)
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
                Text("그랄: \(String(format: "%.f", viewModel.beltInfo.graus))")
                
                VStack{
                    Slider(value: $viewModel.beltInfo.graus, in: 0...viewModel.maxGraus, step: 1.0) {
                        Text("")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("\(String(format: "%.f", viewModel.maxGraus))")
                    }
                }
            }
        }
        .environmentObject(viewModel)
        .padding(.horizontal)
    }
}

struct BeltUI: View {
    
    @EnvironmentObject var viewModel: SignUpViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(viewModel.beltInfo.color)
                .animation(Animation.default, value: viewModel.beltInfo.color)
                .frame(height: 30)
                .padding()
            
            HStack{
                Spacer()
                
                ZStack{
                    Rectangle()
                        .animation(Animation.default, value: viewModel.pretaWidth)
                        .frame(width: viewModel.pretaWidth, height: 30)
                        .foregroundColor(viewModel.pretaColor)
                    
                    HStack{
                        Spacer()
                        
                        ForEach(0..<Int(viewModel.beltInfo.graus), id: \.self){ count in
                            Rectangle()
                                .frame(width: 5, height: 30)
                                .foregroundColor(.white)
                                .animation(Animation.default, value: viewModel.beltInfo.graus)
                        }
                    }
                    .padding(.trailing, 8)
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
            .environmentObject(SignUpViewModel())
            .previewLayout(.sizeThatFits)
            
    }
}
