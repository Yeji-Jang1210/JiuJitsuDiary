//
//  SigninView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/06.
//

import SwiftUI
import PhotosUI

struct SignUpView: View {
    
    @StateObject var viewModel = SignUpViewModel()
    @Environment(\.presentationMode) var presentationMode
   
    @State var isAnimating: Bool = false
    @State var isSignUpValid: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                switch viewModel.onboardingState {
                case 0:
                    withAnimation{
                        SignUpIdView()
                            .transition(.slide)
                    }
                case 1:
                    withAnimation {
                        SignUpPasswordView()
                            .transition(.slide)
                    }
                case 2:
                    withAnimation {
                        SignUpUserInfoView()
                            .transition(.slide)
                    }
                case 3:
                    withAnimation{
                        SignUpCompleteView()
                    }
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
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onReceive(viewModel.$dismissSignUpPage) { isDismiss in
            if isDismiss
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    withAnimation(.easeInOut){
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
