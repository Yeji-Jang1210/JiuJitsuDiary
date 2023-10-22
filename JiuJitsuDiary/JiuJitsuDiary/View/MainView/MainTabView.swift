//
//  MainTabView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/07/18.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var mainViewModel: MainViewModel = MainViewModel()
    @State var isPresrented: Bool = false
    @State var selectedTab: Int = 0

    
    var body: some View {
        TabView(selection: $selectedTab){
           MainView()
                .environmentObject(mainViewModel)
                .tabItem {
                    Image(systemName: "house")
                }
                .tag(0)
            
           MainCalendarView()
                .environmentObject(mainViewModel)
                .tabItem {
                    Image(systemName: "calendar")
                }
                .tag(1)
            
            MainPostsView()
                .environmentObject(mainViewModel)
                .tabItem {
                    Image(systemName: "square.filled.on.square")
                }
                .tag(2)
            
           UserInfoView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "person")
                }
                .tag(3)
       }
        .transition(.move(edge: .trailing).animation(.easeInOut))
    }
    
    
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
}
