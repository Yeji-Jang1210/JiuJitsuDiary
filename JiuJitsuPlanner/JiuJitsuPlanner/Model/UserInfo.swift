////
////  UserInfo.swift
////  JiuJitsuPlanner
////
////  Created by 장예지 on 2023/02/08.
////
//
//import Foundation
//import Firebase
//import FirebaseAuth
//import FirebaseFirestore
//import UIKit
//
//struct UserInfo{
//
//    var userUid: String = ""
//    var id: String = ""
//    var password: String = ""
//    var profile: UIImage?
//    var nickname: String = ""
//    var birthday: String = ""
//    var belfInfo: Belt = Belt()
//    var isCurrentUser: Bool {
//            return Auth.auth().currentUser?.uid == userUid
//        }
//
//    init(){
//        self.birthday = convertDateToString(date: Date.now)
//    }
//
//    func convertDateToString(date: Date) -> String{
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "ko_KR")
//        dateFormatter.dateFormat = "yyyyMMdd"
//        return dateFormatter.string(from: date)
//    }
//
//    func convertStringToDate(strDate: String) -> Date{
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "ko_KR")
//        dateFormatter.dateFormat = "yyyyMMdd"
//        return dateFormatter.date(from: strDate) ?? Date.now
//    }
//}
