//
//  SignUpUserInfoView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/13.
//

import SwiftUI
//import PhotosUI
import UIKit
import PhotosUI

struct SignUpUserInfoView: View {
    
    @EnvironmentObject var viewModel: SignUpViewModel
    
    @State var isPresented: Bool = false
    @State var isReadyLoadingView: Bool = false
    @State var isLoadingPresented: Bool = false
    @State private var isShowPhotoLibrary = false
    @State var attempts: Int = 1
    
    @FocusState var nickNameFocused: Bool
    @FocusState var birthdayFocused: Bool
    
    @ViewBuilder
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10){
                    Text("이제 거의 다 왔습니다!")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("회원님의 정보를 알고 싶어요")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity,alignment: .leading)
                }
                .padding(.horizontal)
                
                VStack(spacing: 40){
                    VStack {
                        //프로필 이미지
                        ZStack {
                            if let image = viewModel.img {
                                Image(uiImage: image)
                                    .resizable()
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
                        PhotoPicker(isPresented: $isShowPhotoLibrary, selectedImage: $viewModel.img)
                    }
                    
                    //닉네임
                    VStack{
                        HStack{
                            Text("별명")
                            TextField("", text: $viewModel.nickname)
                                .multilineTextAlignment(.trailing)
                                .focused($nickNameFocused)
                            
                        }
                        Divider()
                        
                        
                        Text(viewModel.validateNickname())
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
                                .multilineTextAlignment(.trailing)
                                .focused($birthdayFocused)
                                .keyboardType(.numberPad)
                        }
                        Divider()
                        
                        Text(viewModel.validateBirthday().description)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(Color.red)
                            .padding(.horizontal)
                            .font(.system(size: 15))
                            .modifier(Shake(animatableData: CGFloat(attempts)))
                    }
                    .padding(.horizontal)
                    
                    //벨트 정보
                    BeltView()
                        .environmentObject(viewModel)
                }
                
                VStack {
                    ButtonView(title: "확인") {
                        if !viewModel.isNicknameValid || !viewModel.isBirthdayValid{
                            if !viewModel.isBirthdayValid {
                                nickNameFocused = true
                            } else {
                                birthdayFocused = true
                            }
                            withAnimation(.easeInOut(duration: 0.5)){
                                attempts += 1
                            }
                        } else {
                            isPresented.toggle()
                        }
                    }
                    
                    ButtonView(title: "이전으로", color: Color(red: 190/255, green: 190/255, blue: 190/255)) {
                        withAnimation(.easeInOut(duration: 0.5)){
                            viewModel.onboardingState = 1
                        }
                    }
                }
                .padding()
            }
        }
        .alert(isPresented: $isPresented,
               alert:
                DefaultAlertView( alertType: .custom(title: "확인", message: "회원가입을 완료하시겠습니까?", image: "person.fill.checkmark")){
            ButtonView(title: "확인") {
                nickNameFocused = false
                birthdayFocused = false
                
                isReadyLoadingView = true
                isPresented = false
            }
        } secondButton: {
            ButtonView(title: "잘 모르겠어요", color: Color(red: 190/255, green: 190/255, blue: 190/255), role: .destructive){
                isPresented = false
            }
        })
        .onChange(of: viewModel.isSignUpSucceeded) { newValue in
            viewModel.onboardingState = 3
        }
        .onChange(of: isReadyLoadingView, perform: {
            if $0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    DispatchQueue.main.async{
                        viewModel.isLoadingViewPresented = true
                        viewModel.registerUser()
                    }
                }
            }
        })
        .showLoadingView(isPresented: $viewModel.isLoadingViewPresented,
                         view: LoadingView(isShowing: $viewModel.isLoadingViewPresented, text: "회원가입을 처리 중 입니다."))
    }
}



extension SignUpUserInfoView {
    func setMenuItems() -> some View {
        Menu {
            Button {
                self.isShowPhotoLibrary = true
            } label: {
                Label("이미지 편집", systemImage: "photo.fill.on.rectangle.fill")
            }
            
            Button(role: .destructive) {
                viewModel.image = nil
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

struct SignUpUserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpUserInfoView()
            .environmentObject(SignUpViewModel())
    }
}
