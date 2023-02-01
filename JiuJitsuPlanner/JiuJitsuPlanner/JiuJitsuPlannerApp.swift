//
//  JiuJitsuPlannerApp.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/01.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


@main
struct JiuJitsuPlannerApp: App {
    
    // register app delegate for Firebase app
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
