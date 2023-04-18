//
//  ContentView.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/01.
//

import SwiftUI

struct ContentView: View {
    
    @State var viewModel: AuthViewModel = AuthViewModel()
    
    var body: some View {
        if let user = viewModel.currentUser {
            Text("Hello \(user.uid)")
        } else {
            LoginView()
                .environmentObject(viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 13 Pro")
    }
}
