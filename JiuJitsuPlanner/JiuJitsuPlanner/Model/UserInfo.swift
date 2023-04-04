//
//  UserInfo.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/08.
//

import Foundation
import UIKit

struct UserInfo {
    var userId: String = ""
    var userPwd: String = ""
    var userImg: UIImage?
    var userNickname: String = ""
    var userBirthday: String = ""
    var userBeltInfo: Belt = Belt()
    
    init(){
        self.userBirthday = convertDateToString(date: Date.now)
    }
    
    func convertDateToString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }

    func convertStringToDate(strDate: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.date(from: strDate) ?? Date.now
    }
}
