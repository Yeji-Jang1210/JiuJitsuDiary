//
//  JiuJitsuDiaryApp.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/02/01.
//

import UIKit
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct JiuJitsuDiaryApp: App {
    
    // register app delegate for Firebase app
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel: AuthViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                VStack{
                    switch viewModel.onboardingState {
                    case 0:
                        LoginView()
                            .transition(.move(edge: .bottom).animation(.spring().delay(0.5)))
                    case 1:
                        MainTabView()
                            .transition(.move(edge: .trailing).animation(.easeInOut))
                    default:
                        Text("")
                    }
                }
                .environmentObject(viewModel)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
    return true
  }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
