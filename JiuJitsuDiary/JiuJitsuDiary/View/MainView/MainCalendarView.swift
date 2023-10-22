//
//  MainCalendarView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/06/28.
//

import SwiftUI
import Charts

struct MainCalendarView: View {
    
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @State var isAddPostPresented: Bool = false
    @State var isChartPresented: Bool = true
    @State var isAlertPresented: Bool = false
    @State var isEditPostPresented: Bool = false
    @State var isDetailPostViewPresented: Bool = false
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 30){
                    
                    VStack(spacing: 15){
                        Button {
                            withAnimation {
                                isChartPresented.toggle()
                            }
                        } label: {
                            Text(isChartPresented ? "통계 접기" : "이번년도 통계 확인하기")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .underline()
                                .foregroundColor(.black)
                        }

                        if isChartPresented {
                            VStack(spacing: 40){
                                VStack(alignment: .leading){
                                    Text("\(Date.extractDate(date: Date.now, format: "YYYY"))년도")
                                        .font(.system(size: 25).bold())
                                    
                                    Chart(mainViewModel.monthlyStatics){
                                        LineMark(x: .value("월", $0.date, unit: .month), y: .value("", $0.count))
                                            .symbol {
                                                Circle()
                                                    .fill(.white)
                                                    .frame(width: 5)
                                                    .shadow(radius: 2)
                                            }
                                    }
                                    .foregroundStyle(.black)
                                    
                                    HStack(spacing:5){
                                        Text("\(Date.extractDate(date: Date.now, format: "MM"))월달에는 ")
                                            .font(.system(size: 20))
                                        Text("\(mainViewModel.monthlyPostingCount)")
                                            .font(.system(size: 30).bold())
                                            .underline()
                                        Text("번 운동했어요!")
                                            .font(.system(size: 20))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    
                                }
                                
                                VStack(alignment: .leading){
                                    Text("이번달에는 이렇게 운동했어요 💪🏻")
                                        .font(.system(size: 20))
                                    
                                    Chart(mainViewModel.currentMonthCategoryStatics){
                                        BarMark(x: .value("카테고리", $0.category.title), y: .value("횟수", $0.count))
                                            .foregroundStyle(by: .value("", $0.category.title))
                                    }
                                    .chartForegroundStyleScale(domain: mainViewModel.currentMonthCategoryStatics.map { $0.category.title }, range: Category.categoryColors)
                                   .frame(minHeight: 180)
                                   
                                }
                            }
                        }
                    }
                    
                    CustomMonthlyCalendar(height: 450)
                        .environmentObject(mainViewModel.calendarViewController)
                    
                    VStack(alignment: .leading){
                        Text("\(mainViewModel.mainCalendarViewSelectedDateString ?? "nil")")
                            .font(.system(size: 20).bold())
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        //for문으로 돌려야함
                        withAnimation{
                            ForEach(mainViewModel.extractDayPostFromPosts(date: mainViewModel.calendarViewController.selectedDate), id: \.self.id){ post in
                                VStack{
                                    HStack{
                                        Button {
                                            mainViewModel.selectedPost = post
                                            isDetailPostViewPresented.toggle()
                                        } label: {
                                            Group{
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
                                                
                                                VStack(alignment: .leading, spacing: 8){
                                                    HStack{
                                                        Image(systemName: "deskclock")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 12, height: 12)
                                                        
                                                        Text("\(Date.extractDate(date: post.times.first!.startTime, format: "HH:mm")) - \(Date.extractDate(date: post.times.first!.endTime, format: "HH:mm"))")
                                                            .font(.system(size: 13))
                                                            
                                                        
                                                        if post.times.count > 1 {
                                                            Text("+")
                                                                .font(.system(size: 13))
                                                                
                                                        }
                                                    }
                                                    .foregroundColor(.gray)
                                                    
                                                    
                                                    Text("\(post.title)")
                                                        .font(.system(size: 15).bold())
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                        
                                        Menu {
                                            Button {
                                                mainViewModel.postViewModel.postMode = .edit
                                                mainViewModel.selectedPostSubject.send(post)
                                                isEditPostPresented.toggle()
                                            } label: {
                                                Label("수정", systemImage: "pencil")
                                            }

                                            
                                            Button(role: .destructive) {
                                                isAlertPresented.toggle()
                                            } label: {
                                                Label("삭제", systemImage: "trash.fill")
                                            }
                                        } label: {
                                            Label("", systemImage: "ellipsis")
                                                .foregroundColor(.black)
                                        }
                                        .padding(.trailing)
                                        
                                    }
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .background(.white)
                                .cornerRadius(20)
                                .shadow(color: .gray.opacity(0.3), radius: 6, x: 4, y: 4)
                            }
                        }
                        .transition(.opacity.animation(Animation.easeInOut(duration: 0.5)))
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            
                        } label: {
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
                            .foregroundColor(.black)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            mainViewModel.postViewModel.postMode = .add
                            isAddPostPresented.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                        }
                    }
                }
                .fullScreenCover(isPresented:$isDetailPostViewPresented){
                    PostingDetailView()
                        .environmentObject(mainViewModel)
                }
                .fullScreenCover(isPresented: $isAddPostPresented) {
                    AddDailyPostView()
                        .environmentObject(mainViewModel.postViewModel)
                }
                .fullScreenCover(isPresented: $isEditPostPresented){
                    AddDailyPostView()
                        .environmentObject(mainViewModel.postViewModel)
                }
                .alert(isPresented: $isAlertPresented, alert: DefaultAlertView(alertType: .custom(title: "삭제", message: "게시글을 삭제하시겠습니까?", image: "trash.fill"), primaryButton: {
                    ButtonView(title: "확인") {
                       
                    }
                }, secondButton: {
                    ButtonView(title: "취소", color: Color(red: 190/255, green: 190/255, blue: 190/255), role: .destructive){
                        isAlertPresented = false
                    }
                }))
            }
        }
    }
}

struct MainCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        MainCalendarView()
            .environmentObject(MainViewModel())
    }
}
