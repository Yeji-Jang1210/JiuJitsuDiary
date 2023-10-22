//
//  AchievementListView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/05/11.
//

import SwiftUI

struct AchievementListView: View {
    
    @EnvironmentObject var viewModel: AchievementViewModel
    
    var body: some View {
        NavigationStack{
            if let achievements = viewModel.achievements {
                if !achievements.isEmpty {
                    List{
                        ForEach(achievements.indices, id: \.self){ index in
                             Button {
                              withAnimation {
                                  viewModel.selectedAchievementIndex = index
                                  viewModel.selectedAchievement = achievements[index]
                                  viewModel.isAchievementEditClick = true
                              }
                            } label: {
                                HStack{
                                    Image(uiImage: AchievementStatus.getStatusImage(string: achievements[index].state,size : 20) ?? UIImage(systemName: "exclamationmark.triangle.fill")!)

                                    Text("\(achievements[index].title)")
                                        .foregroundColor(.black)

                                    Spacer()
                                    
                                    Text("\(achievements[index].date)")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            .background(
                                NavigationLink("", destination: {
                                    AchievementView()
                                        .transition(AnyTransition.slide.animation(.easeInOut))
                                        .environmentObject(viewModel)
                                })
                                .opacity(0)
                            )
                        }
                    }
                    .navigationTitle("목록")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                withAnimation{
                                    viewModel.isAchievementAddClick.toggle()
                                }
                            } label: {
                                Image(systemName: "plus")
                            }
                            .sheet(isPresented: $viewModel.isAchievementAddClick) {
                                AchievementView()
                                    .transition(AnyTransition.slide.animation(.easeInOut))
                                    .environmentObject(viewModel)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct AchievementListView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementListView()
            .environmentObject(AchievementViewModel())
    }
}
