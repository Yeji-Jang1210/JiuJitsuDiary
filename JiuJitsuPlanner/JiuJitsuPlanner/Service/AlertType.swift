//
//  AlertType.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/28.
//

import Foundation
import UIKit
import SwiftUI

enum AlertType {
    case success(title: String = "완료되었습니다!", message: String = "")
    case error(title: String, message: String = "")
    case warning(title: String, message: String = "")
    case custom(title: String, message: String = "", image: String = "info")
    
    func title() -> String {
        switch self {
        case .success(_: let title, _):
            return title
        case .error(_: let title, _):
            return title
        case .warning(_: let title, _):
            return title
        case .custom(_: let title, _, _):
            return title
        }
    }
    
    func message() -> String {
        switch self {
        case .success(_, _: let message):
            return message
        case .error(_, _: let message):
            return message
        case .warning(_, _: let message):
            return message
        case .custom(_, _: let message, _):
            return message
        }
    }
    
    var alertImage: Image {
        switch self {
        case .success(_, _):
            return Image(systemName: "checkmark")
        case .error(_, _):
            return Image(systemName: "xmark")
        case .warning(_, _):
            return Image(systemName: "exclamationmark.triangle")
        case .custom(_, _, _: let image):
            return Image(systemName: image)
        }
    }
}

extension UIWindow {
    func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}

extension View {
    func alert(isPresented:Binding<Bool>, alert: DefaultAlertView) -> some View {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter ({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap {$0}
            .first?.windows
            .filter { $0.isKeyWindow }.first!
        
        let vc = UIHostingController(rootView: alert)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = .clear
        vc.definesPresentationContext = true
        
        return self.onChange(of: isPresented.wrappedValue, perform: {
            if $0{
                keyWindow?.topViewController()?.present(vc, animated: true)
            }
            else{
                keyWindow?.topViewController()?.dismiss(animated: true)
            }
        })
    }
    
    func showLoadingView(isPresented:Binding<Bool>, view: LoadingView) -> some View {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter ({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap {$0}
            .first?.windows
            .filter { $0.isKeyWindow }.first!
        
        let vc = UIHostingController(rootView: view)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = .clear
        vc.definesPresentationContext = true
        
        return self.onChange(of: isPresented.wrappedValue, perform: {
            if $0{
                keyWindow?.topViewController()?.present(vc, animated: true)
            }
            else{
                keyWindow?.topViewController()?.dismiss(animated: true)
            }
        })
    }
}
