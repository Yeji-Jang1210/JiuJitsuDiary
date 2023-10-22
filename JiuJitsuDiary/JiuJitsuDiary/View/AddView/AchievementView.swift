//
//  AchievementView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/05/09.
//

import SwiftUI

struct AchievementView: View {
    
    @EnvironmentObject var viewModel: AchievementViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 40){
                    HStack{
                        Text("Title")
                            .font(.title)
                        
                        TextField("제목을 입력하세요.", text: $viewModel.title)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("Date")
                                .font(.title)
                            
                            Text(viewModel.dateString)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(.black)
                            
                    }
                    
                    VStack(alignment: .leading){
                        Text("Icon")
                            .font(.title)
                        
                        LazyVGrid(
                            columns: columns,
                            alignment: .center,
                            pinnedViews: []
                        ){
                            ForEach(AchievementStatus.allCases.indices, id: \.self) { index in
                                Button {
                                    viewModel.selectedStatus = AchievementStatus(rawValue: index)!
                                } label: {
                                    VStack{
                                        Image(uiImage: AchievementStatus.getStatusImage(status: AchievementStatus(rawValue: index)!, size: 40)
                                              ?? UIImage(systemName: "exclamationmark.triangle.fill")!)
                                        .padding()
                                        .background {
                                            if viewModel.selectedStatus == AchievementStatus(rawValue: index){
                                                Circle()
                                                    .fill(Color(red: 232/255, green: 232/255, blue: 232/255))
                                            }
                                        }
                                        
                                        Text("\(AchievementStatus.getStatusMessage(status: AchievementStatus(rawValue: index)!))")
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle(viewModel.isAchievementAddClick ? "등록" : "편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.isAchievementAddClick {
                    ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarTrailing) {
                        Button {
                            viewModel.createAchievement()
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                           Text("추가")
                        }
                    }
                } else if viewModel.isAchievementEditClick {
                    
                    ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarLeading) {
                        Button {
                            viewModel.isDelete.toggle()
                        } label: {
                           Text("삭제")
                                .foregroundColor(.red)
                        }
                    }
                    
                    ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarTrailing) {
                        Button {
                            //Edit후 저장버튼
                            viewModel.updateAchievement()
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                           Text("저장")
                        }
                    }
                }   
            }
            .alert(isPresented: $viewModel.isDelete,
                   alert:
                    DefaultAlertView( alertType: .custom(title: "삭제", message: "삭제하시겠습니까?", image: "trash.fill")){
                ButtonView(title: "확인") {
                    viewModel.deleteAchievement()
                    viewModel.isDelete = false
                    presentationMode.wrappedValue.dismiss()
                }
            } secondButton: {
                ButtonView(title: "잘 모르겠어요", color: Color(red: 190/255, green: 190/255, blue: 190/255), role: .destructive){
                    viewModel.isDelete = false
                }
            })
            .alert(isPresented: $viewModel.isUpdate,
                   alert:
                    DefaultAlertView( alertType: .custom(title: "저장", message: "저장하시겠습니까?", image: "square.and.arrow.down")){
                ButtonView(title: "확인") {
                    viewModel.updateAchievement()
                    viewModel.isUpdate = false
                    presentationMode.wrappedValue.dismiss()
                }
            } secondButton: {
                ButtonView(title: "잘 모르겠어요", color: Color(red: 190/255, green: 190/255, blue: 190/255), role: .destructive){
                    viewModel.isUpdate = false
                }
            })
        }
    }
}

struct AddAchievementView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementView()
            .environmentObject(AchievementViewModel())
    }
}
