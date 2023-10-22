//
//  PostingDetailView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/07/26.
//

import SwiftUI
import Combine
import AVFoundation
import _AVKit_SwiftUI

struct PostingDetailView: View {
    
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State var maxRating: Int = 5
    @State var postCategory: Category = Category.practice
    @State var isAlertPresented: Bool = false
    @State var isEditPostPresented: Bool = false
    
    var body: some View {
        if let post = mainViewModel.selectedPost {
            NavigationView{
                ScrollView{
                    VStack(alignment: .leading, spacing: 30){
                        GeometryReader{ geometryReader in
                            TabView{
                                if let selectedPostMedia = mainViewModel.postsMediaContentData[post.id] {
                                    ForEach(selectedPostMedia, id: \.self){ media in
                                        switch media.dataType {
                                        case .image:
                                            Image(uiImage: UIImage(data: media.data)!)
                                                .resizable()
                                                .scaledToFit()
                                                .aspectRatio(CGSize(width: geometryReader.size.width, height: ((geometryReader.size.width)/3) * 4), contentMode: .fill)
                                                .ignoresSafeArea()
                                        case .video:
                                            if let asset = FirebaseStorageManager.createAVAsset(fromData: media.data){
                                                VideoPlayer(player: AVPlayer(playerItem: AVPlayerItem(asset: asset)))
                                                    .aspectRatio(CGSize(width: geometryReader.size.width, height: ((geometryReader.size.width)/3) * 4), contentMode: .fill)
                                                    .ignoresSafeArea()
                                            } else {
                                                VStack(spacing: 20){
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 60)
                                                    
                                                    Text("영상을 불러오는데 오류가 생겼습니다.")
                                                }
                                                .foregroundColor(.gray)
                                                
                                            }
                                        case .unknown:
                                            Text("Can't display")
                                        }
                                    }
                                } else {
                                    ProgressView("사진을 불러오는중 입니다.")
                                }
                            }
                            .background(.gray.opacity(0.1))
                            .frame(width: geometryReader.size.width, height: ((geometryReader.size.width)/3) * 4)
                            .tabViewStyle(.page)
                        }
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.width/3) * 4)
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                        
                        VStack(alignment: .leading, spacing: 15){
                            
                            HStack{
                                Text("#\(post.title)")
                                    .bold()
                                    .foregroundColor(Color(uiColor: post.category.color))
                                
                                Spacer()
                                
                                Text("\(post.category.title)")
                                    .padding()
                                    .font(.system(size: 12).bold())
                                    .foregroundColor(Color(uiColor: post.category.color))
                                    .background(Capsule().fill(Color(uiColor: post.category.color).opacity(0.1)))
                            }
                            
                            Divider()
                            
                            HStack{
                                Text("운동점수")
                                
                                Spacer()
                                
                                ForEach(1..<maxRating + 1, id: \.self){ number in
                                    RoundedStar(cornerRadius: 1)
                                        .scale(post.satisfactionRate < number ? 1.0 : 1.5)
                                        .aspectRatio(1, contentMode: .fit)
                                        .foregroundColor(post.satisfactionRate < number ? .gray : .yellow)
                                        .rotationEffect(Angle(degrees: 20))
                                        .frame(width: 10, height: 10)
                                }
                            
                            }
                            
                            Divider()
        
                            HStack{
                                Image(systemName: "calendar")
                                Text("\(Date.extractDate(date: post.date, format: "yyyy년 MM월 dd일"))")
                            }
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12){
                                HStack(alignment: .top){
                                    Image(systemName: "deskclock")
                                    Text("타임")
                                }
                                
                                ForEach(post.times, id: \.self){ time in
                                    VStack{
                                        Text("\(Date.extractDate(date: time.startTime, format: "HH:mm")) - \(Date.extractDate(date: time.endTime, format: "HH:mm"))")
                                    }
                                }
                            }
                            Divider()
                            
                            Text("\(post.content)")
                            
                        }
                        .padding(.horizontal)
                    }
                }
                .onAppear{
                    UIPageControl.appearance().currentPageIndicatorTintColor = .black
                    UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("뒤로")
                                .foregroundColor(.black)
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("\(Date.extractDate(date: post.date, format: "yyyy-MM-dd EEE"))").font(.headline)
                            Text("\(post.title)").font(.subheadline)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing){
                        Menu {
                            Button {
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

                    }
                }
                .fullScreenCover(isPresented: $isEditPostPresented) {
                    AddDailyPostView()
                        .environmentObject(mainViewModel.postViewModel)
                }
                .alert(isPresented: $isAlertPresented, alert: DefaultAlertView(alertType: .custom(title: "삭제", message: "게시글을 삭제하시겠습니까?", image: "trash.fill"), primaryButton: {
                    ButtonView(title: "확인") {
                        mainViewModel.deletePost{ result in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                if result {
                                    isAlertPresented = false
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }, secondButton: {
                    ButtonView(title: "취소", color: Color(red: 190/255, green: 190/255, blue: 190/255), role: .destructive){
                        isAlertPresented = false
                    }
                }))
            }
        } else {
            ZStack(alignment: .top){
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
                    
                    Spacer()
                    
                    VStack{
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        
                        Text("게시글을 불러오는데 오류가 생겼습니다.")
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("뒤로")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

struct PostingView_Previews: PreviewProvider {
    static var previews: some View {
        
        //let post = Post(id: UUID().uuidString, date: Date.now, times: [PostTimes(startTime: Date.now, endTime: Date.now)], satisfactionRate: 5, title: "title", content: "content", category: Category.openMat)
            
            PostingDetailView()
            .environmentObject(MainViewModel())
    }
}
