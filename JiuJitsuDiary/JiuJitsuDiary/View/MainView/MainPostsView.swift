//
//  MainPostsView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/07/26.
//

import SwiftUI

struct MainPostsView: View {
    
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @State var columns = [
        GridItem(.flexible(), spacing:0),
        GridItem(.flexible(), spacing:0),
        GridItem(.flexible(), spacing:0)
    ]
    
    @State var isPresented: Bool = false
    @State var isDetailViewPresented: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
                VStack(alignment: .leading){
                    Text("POST")
                        .font(.system(size: 25).italic().bold())
                        .fontWeight(.heavy)
                    
                    HStack{
                        
                        Spacer()
                        
                        Picker(selection: $mainViewModel.selectedOrderedValue) {
                            ForEach(mainViewModel.sortedOptions, id: \.self){ option in
                                Text(option)
                                    .tag(option)
                            }
                        } label: {
                            Text("\(mainViewModel.selectedOrderedValue)")
                        }
                        .tint(.gray)
                        
                        Picker(selection: $mainViewModel.selectedCategoryValue) {
                            ForEach(mainViewModel.categoryOptions, id: \.self){ category in
                                Text(category)
                                    .tag(category)
                            }
                        } label: {
                            Text("\(mainViewModel.selectedCategoryValue)")
                        }
                        .tint(.gray)
                    }
                    
                }
                .padding(.horizontal)
                
                if mainViewModel.filteredPosts.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 30){
                        //Image를 template모드로 변경 후 renderingMode를 설정해주면 이미지의 색상을 변경 할 수 있다.
                        Image("empty-box")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                        
                        Text("작성한 포스트가 없어요.")
                        
                        ButtonView(title: "포스팅 하러 가기") {
                            isPresented.toggle()
                        }
                        .padding()
                    }
                    .foregroundColor(.black.opacity(0.6))
                    
                    Spacer()
                } else {
                    ScrollView{
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(mainViewModel.filteredPosts, id: \.self.id){ post in
                                Button {
                                    mainViewModel.selectedPost = post
                                    isDetailViewPresented.toggle()
                                } label: {
                                    switch mainViewModel.postsMediaContentData[post.id]?.first!.dataType {
                                    case.image:
                                        Image(uiImage: UIImage(data: (mainViewModel.postsMediaContentData[post.id]?.first!.data)!)!)
                                            .resizable()
                                            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fill)
                                    case .video:
                                        Image(uiImage: FirebaseStorageManager.extractImageFromVideo(data: (mainViewModel.postsMediaContentData[post.id]?.first!.data)!))
                                            .resizable()
                                            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fill)
                                    case .unknown:
                                        Text("is unknown")
                                    case .none:
                                        ProgressView()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isDetailViewPresented){
                PostingDetailView()
                    .environmentObject(mainViewModel)
            }
            .sheet(isPresented: $isPresented, onDismiss: {
                mainViewModel.postViewModel.postMode = .add
            }, content: {
                AddDailyPostView()
                    .environmentObject(mainViewModel.postViewModel)
            })
        }
    }
}

struct MainPostsView_Previews: PreviewProvider {
    static var previews: some View {
        MainPostsView()
            .environmentObject(MainViewModel())
    }
}
