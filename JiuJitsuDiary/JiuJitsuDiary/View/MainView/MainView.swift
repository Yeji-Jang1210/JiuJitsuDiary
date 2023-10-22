//
//  MainView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/04/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct MainView: View {
    
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @State var isPresented: Bool = false
    var body: some View {
        ZStack (alignment: .top){
            Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all)
            
            VStack{
                VStack(spacing: -8) {
                    Text("JIUJITSU")
                        .italic()
                        .font(.system(size: 20))
                        .fontWeight(.heavy)
                        
                    Text("DIARY")
                        .italic()
                        .font(.system(size: 20))
                        .fontWeight(.heavy)
                }
                
                VStack(spacing: 30){
                    HStack(spacing: 20){
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.black)
                            .frame(width: 150, height: 150)
                            .overlay{
                                VStack(spacing: 10){
                                    Text("\(mainViewModel.todayString[2])")
                                        .foregroundColor(.white)
                                        .font(.system(size: 60))
                                    
                                    Text("\(mainViewModel.todayString[0])년 \(mainViewModel.todayString[1])월")
                                        .foregroundColor(.white)
                                }
                            }
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                            .frame(height: 150)
                            .overlay{
                                VStack(spacing: 10){
                                    Text("이번달 운동횟수")
                                    HStack{
                                        Text("\(mainViewModel.monthlyPostingCount)")
                                            .font(.system(size: 40).bold())
                                            .foregroundColor(.blue)
                                        
                                        Text("/")
                                            .font(.system(size: 30))
                                        
                                        Text("\(mainViewModel.today.getDaysInMonth())")
                                            .font(.system(size: 40))
                                    }
                                    
                                    
                                }
                            }
                    }
                    
                    CustomWeeklyCalendarView()
                        .environmentObject(mainViewModel.weekcalendarViewController)
                        .foregroundColor(.black)
                    
                    VStack{
                        HStack{
                            Text("이번주")
                                .font(.system(size: 20))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button {
                                isPresented.toggle()
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.black)
                            }
                            
                        }
                        
                        if mainViewModel.currentWeeklyPosts.isEmpty {
                            Spacer()
                            
                            VStack(spacing: 40){
                                //Image를 template모드로 변경 후 renderingMode를 설정해주면 이미지의 색상을 변경 할 수 있다.
                                Image("empty-box")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                
                                Text("이번주는 아직 운동을 시작하지 않았어요.")
                            }
                            .foregroundColor(.black.opacity(0.6))
                            
                            Spacer()
                        } else {
                            ScrollView{
                                VStack(spacing:30){
                                    ForEach(Date.fetchCurrentWeek(), id: \.self){ date in
                                        if !mainViewModel.extractDayPostFromPosts(date: date).isEmpty{
                                            VStack{
                                                HStack{
                                                    Rectangle()
                                                        .frame(width: 5)
                                                    Text(Date.extractDate(date: date, format: "EEE"))
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                
                                                ForEach(mainViewModel.extractDayPostFromPosts(date: date), id: \.self.id){ post in
                                                    VStack{
                                                        HStack{
                                                            Image(uiImage: post.category.icon)
                                                                .resizable()
                                                                .frame(width: 30, height: 30)
                                                            
                                                            Text("\(post.title)")
                                                                .font(.system(size: 15))
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                        }
                                                        
                                                        HStack(spacing: 15){
                                                            switch mainViewModel.postsMediaContentData[post.id]?.first!.dataType {
                                                            case.image:
                                                                Image(uiImage: UIImage(data: (mainViewModel.postsMediaContentData[post.id]?.first!.data)!)!)
                                                                    .resizable()
                                                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fill)
                                                                    .frame(width: 60, height: 60)
                                                            case .video:
                                                                Image(uiImage: FirebaseStorageManager.extractImageFromVideo(data: (mainViewModel.postsMediaContentData[post.id]?.first!.data)!))
                                                                    .resizable()
                                                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fill)
                                                                    .frame(width: 60, height: 60)
                                                            case .unknown:
                                                                Text("is unknown")
                                                            case .none:
                                                                ProgressView()
                                                            }
                                                            
                                                            Text("\(post.content)")
                                                                .lineLimit(3)
                                                                .font(.system(size: 12))
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                        }
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .padding()
                                                    .background(.white)
                                                    .cornerRadius(20)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .sheet(isPresented: $isPresented, onDismiss: {
                    mainViewModel.postViewModel.postMode = .add
                }, content: {
                    AddDailyPostView()
                        .environmentObject(mainViewModel.postViewModel)
                })
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(MainViewModel())
    }
}
