//
//  UserInfoView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/05/31.
//

import SwiftUI

struct UserInfoView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        JiuJitsuNavigationView{
            NavigationStack{
                ScrollView {
                    VStack(spacing: 40){
                        VStack(spacing: 20){
                            
                            HStack{
                                Text("내정보")
                                    .font(.system(size: 30))
                                    .fontWeight(.heavy)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                NavigationLink {
                                    UserEditView().environmentObject(viewModel.userEditViewModel)
                                } label: {
                                    Text("수정")
                                        .foregroundColor(.black)
                                }
                                .simultaneousGesture(TapGesture().onEnded({
                                    viewModel.isUserInfoEditClick = true
                                }))
                            }
                            
                            //프로필 이미지
                            ZStack{
                                if let image = viewModel.user.profile {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 130, height: 130)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 130, height: 130)
                                        .clipShape(Circle())
                                        .foregroundColor(Color(red: 222/255, green: 222/255, blue: 222/255))
                                }
                            }
                            
                            VStack(spacing: 5) {
                                Text(viewModel.user.nickname ?? "")
                                    .font(.system(size: 23))
                                
                                Text(viewModel.user.email ?? "")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        VStack{
                            HStack {
                                Text("생년월일")
                                    .frame(width: 100)
                                
                                Spacer()
                                
                                Text("벨트 색")
                                    .frame(width: 100)
                                
                                Spacer()
                                
                                Text("그  랄")
                                    .frame(width: 100)
                            }
                            
                            HStack{
                                Text(viewModel.user.birthday ?? "")
                                    .frame(width: 100)
                                
                                Spacer()
                                
                                VStack{
                                    Circle()
                                        .fill(viewModel.user.beltInfo?.color ?? .white)
                                        .frame(width: 40, height: 40)
                                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 4, y: 4)
                                }
                                .frame(width: 100)
                                
                                Spacer()
                                
                                Text(String(format: "%.0f", viewModel.user.beltInfo?.graus ?? 0))
                                    .font(.system(size: 30).bold())
                                    .foregroundColor(.gray)
                                    .frame(width: 100)
                                
                            }
                        }
                        
                        VStack(spacing: 20){
                            
                            HStack{
                                Text("업적")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if !viewModel.isAchievementsNilOrEmpty {
                                    HStack{
                                        NavigationLink {
                                            AchievementListView()
                                                .environmentObject(viewModel.achievementViewModel)
                                        } label: {
                                            Image(systemName: "pencil")
                                                .foregroundColor(.black)
                                        }
                                        .simultaneousGesture(TapGesture().onEnded({
                                            viewModel.isAchievementViewAppear.toggle()
                                        }))
                                    }
                                }
                            }
                            
                            
                            if !viewModel.isAchievementsNilOrEmpty {
                                VStack(alignment: .leading){
                                    if let data = viewModel.user.achievements {
                                        ForEach(data, id: \.self){ item in
                                            HStack{
                                                Image(uiImage: AchievementStatus.getStatusImage(string: item.state,size : 20) ?? UIImage(systemName: "exclamationmark.triangle.fill")!)
                                                
                                                Text("\(item.title)")
                                                
                                                Spacer()
                                                
                                                Text("\(item.date)")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.gray)
                                                    .multilineTextAlignment(.trailing)
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                
                            } else {
                                achievementsButton
                                    .sheet(isPresented: $viewModel.isAchievementAddClicked) {
                                        AchievementView()
                                            .environmentObject(viewModel.achievementViewModel)
                                    }
                            }
                            
                            
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("내정보")
                .toolbar(.hidden)
                .padding()
            }
        }
        
    }
    
    var achievementsButton: some View {
        Button {
            viewModel.isAchievementAddClicked.toggle()
        } label: {
            RoundedRectangle(cornerRadius: 15)
                .fill(.black)
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .overlay {
                    HStack(spacing: 20){
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        
                        Text("달성한 내용을 기록해 보세요!")
                            .foregroundColor(.white)
                    }
                }
        }
    }
}

struct UserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        UserInfoView()
            .environmentObject(AuthViewModel())
    }
}
