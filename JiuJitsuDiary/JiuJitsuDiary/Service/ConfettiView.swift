//
//  ConfettiView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/03/15.
//

import SwiftUI
import UIKit

struct ExampleConfettiView: View {
    
    @State var isAnimated: Bool = false
    @State var point: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
    var body: some View {
        ZStack{
            
            ConfettiView(point: $point)
                .scaleEffect(1,anchor: .top)
                .opacity(1)
                .ignoresSafeArea()
            
            VStack {
                Text("Congratulations!!")
                    .opacity(isAnimated ? 1 : 0)
            }
            
        }
        .onTapGesture { point in
            self.point = point
        }
        .onAppear {
            withAnimation(.easeInOut){
                isAnimated = true
            }
        }
    }
}

func getRect() -> CGRect {
    return UIScreen.main.bounds
}

//UIViewRepresentable: A wrapper for a UIKit view that you use to integrate that view into your SwiftUI view hierarchy.
struct ConfettiView: UIViewRepresentable {
    //Emitter Layer
    @Binding var point: CGPoint
    @State var emitterLayer = CAEmitterLayer()
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        
        //.line : 위에서 아래로 떨어지는 애니메이션 그 이외에 .circle(원의 중심에서부터 방출)등 있다.
        emitterLayer.emitterShape = .point
        emitterLayer.emitterCells = createEmitterCells()
        
        //particle의 사이즈를 얼마나크게 할건지
        emitterLayer.emitterSize = CGSize(width: getRect().width, height: 1)
        
        emitterLayer.birthRate = 1
        
        view.layer.addSublayer(emitterLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        //emitterLayer의 중심위치를 정함
        emitterLayer.emitterPosition = point
        
        emitterLayer.birthRate = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            //birth rate 가 0이 되면 더 이상 값을 방출하지 않는 것처럼 보임
            emitterLayer.birthRate = 0
        }
    }
    
    func getImage(index: Int) -> String{
        if index < 4 {
            return "🥋"
        }
        else if index > 5 && index <= 8 {
            return "🥳"
        } else if index > 8 && index <= 11 {
            return "🔹"
        } else {
            return "♥️"
        }
    }
    
    func createEmitterCells() -> [CAEmitterCell] {
       
        //다양한 셀 이미지 추가할 수 있음
        var emitterCells: [CAEmitterCell] = []
        
        for index in 1...12{
            let cell = CAEmitterCell()
            
            //어떤것을 표시할지 정하는 것 이다. 도형을 UIImage로 추가했을 경우 cell의 색도 변경가능하다.
            //cell.contents = UIImage(named:"rectangle")?.cgImage
            //cell.color = UIColor.red.cgColor
            cell.contents = getImage(index: index).textToImage(50)!.cgImage
            //cell이 초당 몇개나 생성할건지를 정하는 것
            cell.birthRate = 20
            
            //얼마나 유지시킬건지를 정함 :내려오면서 시간 지나면 사라짐
            cell.lifetime = 3
            //셀의 애니메이션 속도를 정함
            //cell 의 속도입니다. 셀의 속도는 velocityRange 값으로 지정된 범위에 따라 달라집니다. 수치가 높을 수록 더 빠르게, 더 멀리 방출되는 효과
            //yAcceleration 에 의해서도 영향을 받습니다.
            cell.velocity = 700
            cell.velocityRange = 50
            
            //cell의 이미지 크기 조정
            cell.scale = 0.25
            //특정 범위 내에서 cell의 크기를 변경한다 설정하지 않을 경우 셀의 입자가 같음
            cell.scaleRange = 0.3
            //angle을 바꿈
            //cell.emissionLongitude = .pi * 2
            //cell이 움직이는정도..? .line에 설정하지 않을경우 수직으로 떨어진다.
            cell.emissionRange = .pi * 2
            
            //cell이 회전하면서 떨어짐
            cell.spin = 5
            //cell의 lifetime 동안 스핀 값이 변할 수 있는 평균 양을 지정
            cell.spinRange = 10
            
            // 양수면 중력이 적용되는 것처럼 보이고, 음수면 중력이 없어져서 날아가는 것 처럼 보임.
            // velocity 와 yAcceleration의 조합이 distance 를 결정
            cell.yAcceleration = 1200
            
            //초당 alpha값이 줄어듬
            cell.alphaSpeed = -0.25
            
            emitterCells.append(cell)
        }
        
        return emitterCells
    }
}



//string 이모지를 UIImage로 변경
extension String {
    func textToImage(_ size: CGFloat) -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: size) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIColor.clear.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? UIImage()
    }
}

struct ExampleConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleConfettiView()
    }
}
