//
//  LoadingView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/03/30.
//

import SwiftUI

//LoadingView<Content> View where Content: View와 동일
struct LoadingView/*<Content: View>*/: View {
    
    @Binding var isShowing: Bool
    @State var text: String?
    @State var blinking: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
                Rectangle()
                    .fill(Color.gray).opacity(isShowing ? 0.6 : 0)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 48) {
                    ProgressView().scaleEffect(2.0, anchor: .center)
                    
                    VStack(spacing: 12){
                        Text(text ?? "Loading...")
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .font(.title)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        Text("잠시만 기다려 주세요")
                            .foregroundColor(.gray)
                            .opacity(blinking ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(), value: blinking)
                    }
                }
                .frame(width: 250, height: 200)
                .background(Color.white)
                .foregroundColor(Color.primary)
                .cornerRadius(16)
        }
        .onAppear {
            withAnimation {
                blinking = true
            }
        }
    }
}


struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(isShowing: .constant(true), text: "회원가입을 처리 중 입니다.")
    }
}
