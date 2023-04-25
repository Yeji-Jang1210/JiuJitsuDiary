//
//  MainView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/04/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct MainView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        
        Button {
            withAnimation {
                viewModel.signOut()
            }
        } label: {
            Text("로그아웃")
        }

    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthViewModel())
    }
}
