//
//  SignUpCompleteView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/03/03.
//

import SwiftUI

struct TabItem: Identifiable {
    var id = UUID()
    var title: Text
    var image: Image
    var tag: Int
}

struct SignUpCompleteView: View {
    
    @EnvironmentObject var viewModel: SignUpViewModel
    @State var isAnimated: Bool = false
    @State var isTabPageAnimated: Bool = false
    @State var point: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
    @State var pageIndex: Int = 0
    
    let tabData = [
            TabItem(title: Text("운동 갔다온 날을 기록해요"), image: Image("tabPage_1"), tag: 1),
            TabItem(title: Text("그날 배운 기술을 기록해요"), image: Image("tabPage_2"), tag: 2),
            TabItem(title: Text("주짓수가 무엇인지 배워봐요"), image: Image("tabPage_3"), tag: 3),

        ]

    init() {
        UIPageControl.appearance().preferredCurrentPageIndicatorImage = UIImage(systemName: "capsule.fill")
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    var body: some View {
        if let value = viewModel.isSignUpSucceeded {
            if value {
                ZStack {
                    ConfettiView(point: $point)
                        .opacity(0.5)

                    VStack(spacing: 20){
                        
                        Spacer()
                        
                        VStack(spacing: 20){
                            Text("반가워요!")
                                .font(.system(size: 40))
                                .bold()
                                .opacity(isAnimated ? 1 : 0)
                                .offset(y: isAnimated ? 0 : -15)
                                .transition(AnyTransition.move(edge: .bottom))
                                .animation(.easeInOut(duration: 0.5), value: isAnimated)
                            
                            HStack(alignment: .bottom){
                                Text(viewModel.nickname)
                                    .font(.system(size: 30))
                                    .bold()
                                Text("님")
                                    .font(.system(size: 25))
                            }
                            .opacity(isAnimated ? 1 : 0)
                            .offset(y: isAnimated ? 0 : -15)
                            .transition(AnyTransition.move(edge: .bottom))
                            .animation(.easeInOut(duration: 0.5).delay(0.5), value: isAnimated)
                        }
                        
                        TabView(selection: $pageIndex){
                            
                            ForEach(tabData){ tabItem in
                                VStack(spacing: 40){
                                    
                                    VStack{
                                        tabItem.image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250, height: 250)
                                    }
                                    .opacity(pageIndex == tabItem.tag ? 1 : 0)
                                    .offset(y: pageIndex == tabItem.tag ? 0 : -50)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.4), value: pageIndex)
                                    
                                    Text("\(tabItem.title)")
                                        .font(.system(size: 20))
                                        .bold()
                                        .opacity(pageIndex == tabItem.tag ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: pageIndex)
                                }
                                .tag(tabItem.tag)
                            }
                        }
                        .tabViewStyle(.page)
                        
                        Spacer()
                        
                        ButtonView(title: "로그인하러 가기") {
                            viewModel.dismissSignUpPage = true
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear{
                    isAnimated = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        pageIndex = 1
                    }
                }
                .onTapGesture { point in
                    self.point = point
                }
            }
            else {
                signUpFailureView
            }
        } else {
            signUpFailureView
        }
    }
    
    var signUpFailureView: some View {
        ZStack {
            VStack{
                
                Spacer()
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 15){
                    Text("회원가입 실패")
                        .font(.title)
                    
                    Text("예상치 못한 오류로 회원가입에 실패하였습니다.")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                ButtonView(title: "로그인 페이지로 이동") {
                    viewModel.dismissSignUpPage = true
                }
            }
        }.padding()
    }
}

struct SignUpCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpCompleteView()
            .environmentObject(SignUpViewModel())
    }
}
