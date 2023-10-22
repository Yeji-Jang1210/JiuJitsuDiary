//
//  UserEditView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/05/24.
//

import SwiftUI

struct UserEditView: View {
    
    enum Field: Hashable {
        case nickname, birthday
    }
    
    @FocusState var focusField: Field?
    
    @EnvironmentObject var viewModel: UserEditViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State var isEditAlertPresented: Bool = false
    @State var isReadyLoadingView: Bool = false
    @State var isLoadingPresented: Bool = false
    @State private var isShowPhotoLibrary = false
    @State var attempts: Int = 1
    @State var isEditSucceeded: Bool = false
    
    @State var isLogout: Bool = false
    @State var isDeleteUser: Bool = false
    
    @FocusState var nickNameFocused: Bool
    @FocusState var birthdayFocused: Bool
    
    var body: some View {
        JiuJitsuNavigationView{
            NavigationStack{
                ScrollView {
                    VStack(spacing: 40){
                        VStack {
                            //프로필 이미지
                            ZStack {
                                if viewModel.profile != nil {
                                    Image(uiImage: viewModel.profile!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 150, height: 150)
                                        .clipShape(Circle())
                                        .foregroundColor(Color(red: 222/255, green: 222/255, blue: 222/255))
                                }
                            }
                            .overlay(
                                setMenuItems()
                                ,alignment: .bottomTrailing
                            )
                             
                        }
                        .sheet(isPresented: $isShowPhotoLibrary) {
                            PhotoPicker(isPresented: $isShowPhotoLibrary, selectedImage: $viewModel.profile)
                        }
                        
                        //닉네임
                        VStack{
                            HStack{
                                Text("별명")
                                TextField("3-6자 내외의 글자,이모티콘", text: $viewModel.nickname)
                                    .autocorrectionDisabled(true)
                                    .multilineTextAlignment(.trailing)
                                    .focused($focusField,equals: .nickname)
                                
                            }
                            Divider()

                            Text(focusField == .nickname ? viewModel.nicknameIsAvailableNotifyMessage : "")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(Color.red)
                                .padding(.horizontal)
                                .font(.system(size: 15))
                                .modifier(Shake(animatableData: CGFloat(attempts)))
                        
                            
                        }
                        .padding(.horizontal)
                        
                        //생년월일
                        VStack {
                            HStack{
                                Text("생년월일")
                                TextField("yyyymmdd", text: $viewModel.birthday)
                                    .autocorrectionDisabled(true)
                                    .multilineTextAlignment(.trailing)
                                    .focused($focusField, equals: .birthday)
                                    .keyboardType(.numberPad)
                            }
                            Divider()
                            
                            Text(focusField == .birthday ? viewModel.birthdayIsAvailableNotifyMessage : "")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(Color.red)
                                .padding(.horizontal)
                                .font(.system(size: 15))
                                .modifier(Shake(animatableData: CGFloat(attempts)))
                        }
                        .padding(.horizontal)
                        
                        //벨트 정보
                        BeltView()
                            .environmentObject(viewModel.controller)
                        
                        VStack(alignment: .leading, spacing: 20){
                            Button {
                                withAnimation {
                                    //viewModel.isSignOutUser.toggle()
                                    isLogout.toggle()
                                }
                            } label: {
                                Text("로그아웃")
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                            
                            Button {
                                //isDeleteUser.toggle()
                                isDeleteUser.toggle()
                            } label: {
                                Text("회원탈퇴")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("정보수정")
                .toolbar(.hidden, for: .tabBar)
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if !viewModel.isNicknameValid || !viewModel.isBirthdayValid {
                                if !viewModel.isBirthdayValid {
                                    focusField = .birthday
                                } else if !viewModel.isNicknameValid {
                                    focusField = .nickname
                                }
                                withAnimation(.easeInOut(duration: 0.5)){
                                    attempts += 1
                                }
                            } else {
                                viewModel.checkIsUserInfoChanged()
                                if viewModel.isEdit {
                                    isEditAlertPresented = true
                                }
                            }
                        } label: {
                            Text("저장")
                        }
                    }
                }
            }
        }
        .alert(isPresented: $isEditAlertPresented,
               alert:
                DefaultAlertView( alertType: .custom(title: "확인", message: "저장 하시겠습니까?", image: "person.fill.checkmark")){
            ButtonView(title: "확인") {
                focusField = nil
                UIApplication.shared.endEditing()
                isReadyLoadingView = true
                isEditAlertPresented = false
            }
        } secondButton: {
            ButtonView(title: "잘 모르겠어요", color: Color(red: 190/255, green: 190/255, blue: 190/255), role: .destructive){
                isEditAlertPresented = false
            }
        })
        .alert(isPresented: $isLogout, alert:DefaultAlertView( alertType: .custom(title: "로그아웃", message: "로그아웃 하시겠습니까?", image: "person.fill.checkmark")){
            ButtonView(title: "확인") {
                focusField = nil
                UIApplication.shared.endEditing()
                withAnimation {
                    viewModel.isSignOutUser = true
                    isLogout = false
                }
            }
        } secondButton: {
            ButtonView(title: "잘 모르겠어요", color: Color(red: 190/255, green: 190/255, blue: 190/255), role: .destructive){
                isLogout = false
            }
        })
        .alert(isPresented: $isDeleteUser, alert:DefaultAlertView(alertType: .custom(title: "회원탈퇴", message: "회원탈퇴를 하시겠습니까?", image: "person.fill.checkmark")){
            ButtonView(title: "확인") {
                focusField = nil
                UIApplication.shared.endEditing()
                withAnimation {
                    viewModel.isDeleteUser = true
                    isDeleteUser = false
                }
            }
        } secondButton: {
            ButtonView(title: "잘 모르겠어요", color: Color(red: 190/255, green: 190/255, blue: 190/255), role: .destructive){
                isDeleteUser = false
            }
        })
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onChange(of: isEditSucceeded){
            if isEditSucceeded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onChange(of: isReadyLoadingView){
            if isReadyLoadingView {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    DispatchQueue.main.async {
                        UIApplication.shared.endEditing()
                        viewModel.isLoadingViewPresented = true
                        viewModel.updateUser_{ _ in
                            viewModel.isLoadingViewPresented = false
                            viewModel.isProfileInfoEdit = false
                            viewModel.isProfileImageEdit = false
                        }
                        
                        isReadyLoadingView = false
                    }
                    
                }
            }
        }
        .showLoadingView(isPresented: $viewModel.isLoadingViewPresented,
                         view: LoadingView(isShowing: $viewModel.isLoadingViewPresented, text: "정보를 수정 하는 중 입니다."))

    }
}

extension UserEditView {
    func setMenuItems() -> some View {
        Menu {
            Button {
                self.isShowPhotoLibrary = true
            } label: {
                Label("이미지 편집", systemImage: "photo.fill.on.rectangle.fill")
            }
            
            Button(role: .destructive) {
                viewModel.profile = nil
            } label: {
                Label("기본 이미지로 변경", systemImage: "trash.fill")
            }
            
        } label: {
            Image(systemName: "plus.app.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.black)
        }
    }
}


struct UserEditView_Previews: PreviewProvider {
    static var previews: some View {
        UserEditView()
            .environmentObject(UserEditViewModel())
    }
}
