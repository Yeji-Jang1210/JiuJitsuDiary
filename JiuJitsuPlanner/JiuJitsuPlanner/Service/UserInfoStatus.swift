//
//  UserInfoStatus.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/03/10.
//

import Foundation
import SwiftUI

enum PasswordStatus {
    case EmptyPassword
    case EmptyRecheckedPassword
    case WrongPassword
    case IncorrectPassword
    case CorrectPassword
    
    var errorMessage: String {
        switch self {
        case .EmptyPassword:
            return "⚠️ 비밀번호를 입력해 주세요."
        case .EmptyRecheckedPassword:
            return "⚠️ 비밀번호를 다시 입력해 주세요."
        case .WrongPassword:
            return "⚠️ 잘못된 비밀번호 형식입니다."
        case .IncorrectPassword:
            return "⚠️ 일치하지 않는 비밀번호 입니다."
        case .CorrectPassword:
            return ""
        }
    }
    
    var isError: Bool {
        switch self {
        case .EmptyPassword:
            return true
        case .EmptyRecheckedPassword:
            return true
        case .WrongPassword:
            return true
        case .IncorrectPassword:
            return true
        case .CorrectPassword:
            return false
        }
    }
}

enum IdStatus {
    case EmptyEmail
    case IncorrectEmail
    case NotValidateEmail
    case DuplicateEmail
    case CorrectEmail
    
    var message: String {
        switch self {
        case .EmptyEmail:
            return "⚠️ 아이디를 입력해 주세요."
        case .IncorrectEmail:
            return "⚠️ 잘못된 이메일 형식 입니다."
        case .DuplicateEmail:
            return "⚠️ 중복된 이메일 입니다."
        case .NotValidateEmail:
            return "⚠️ 중복확인을 눌러 이메일을 검증해 주세요."
        case .CorrectEmail:
            return "사용가능한 이메일 입니다."
        }
    }
    
    var isError: Bool {
        switch self {
        case .EmptyEmail, .IncorrectEmail, .NotValidateEmail, .DuplicateEmail:
            return true
        case .CorrectEmail:
            return false
        }
    }
    
    var messageColor: Color {
        switch self {
        case .EmptyEmail, .IncorrectEmail, .NotValidateEmail, .DuplicateEmail:
            return Color.red
        case .CorrectEmail:
            return Color.green
        }
    }
    
    var disabledDuplicationButton: Bool {
        switch self {
        case .EmptyEmail, .IncorrectEmail, .DuplicateEmail, .CorrectEmail:
            return true
        case .NotValidateEmail:
            return false
        }
    }
}
