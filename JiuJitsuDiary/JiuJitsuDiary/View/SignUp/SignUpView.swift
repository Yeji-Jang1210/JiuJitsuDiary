//
//  SigninView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/02/06.
//

import SwiftUI
import PhotosUI

struct SignUpView: View {
    
    @StateObject var viewModel = SignUpViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
   
    @State var isAnimating: Bool = false
    @State var isSignUpValid: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                switch viewModel.onboardingState {
                case 0:
                    SignUpIdView()
                        .transition(.slide)
                case 1:
                    SignUpPasswordView()
                        .transition(.slide)
                case 2:
                    SignUpUserInfoView()
                        .transition(.slide)
                case 3:
                    SignUpCompleteView()
                default:
                    Text("No Title")
                }
            }
            .environmentObject(viewModel)
            .navigationTitle(viewModel.onboardingState != 3 ? "회원가입" : "")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.vertical)
            .toolbar {
                if viewModel.onboardingState != 3 {
                    ToolbarItem(placement: .navigationBarLeading){
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .onAppear{
            authViewModel.removeStateDidChangeHandler()
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onReceive(viewModel.$dismissSignUpPage) { isDismiss in
            if isDismiss
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    withAnimation(.easeInOut){
                        presentationMode.wrappedValue.dismiss()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            withAnimation(.easeInOut){
                                authViewModel.addStateDidChangeHandler()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
