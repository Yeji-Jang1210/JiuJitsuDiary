//
//  JiuJitsuNavigationView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/07/26.
//

import SwiftUI

//네비게이션 뷰 타이틀 폰트 크기 변경
struct JiuJitsuNavigationView<Content>: View where Content: View  {
    
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.bold)]

        //Use this if NavigationBarTitle is with displayMode = .inline
        //UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 20)!]
        
        self.content = content
    }
    
    var body: some View {
        content()
    }
}

struct JiuJitsuNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        JiuJitsuNavigationView{
            NavigationView {
                Text("Hello World")
                    .navigationTitle("hello")
            }
        }
    }
}
