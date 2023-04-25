//
//  ContentView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/01.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel: AuthViewModel = AuthViewModel()
    
    var body: some View {
        VStack{
            if viewModel.isLoggedIn {
                MainView()
                    .transition(AnyTransition.slide.animation(.easeInOut))
                
            } else {
                LoginView()
                    .transition(AnyTransition.slide.animation(.easeInOut))
                
            }
        }
        .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 13 Pro")
    }
}
