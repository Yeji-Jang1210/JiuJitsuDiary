//
//  Post.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/06/27.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    //convenience init(보조 이니셜라이져)
    //convenience init을 사용하려면 Designated init이 꼭 먼저 선언 같은 클래스에서 다른 생성자를 호출해야한다.
    //Designated init: 모든 프로퍼티를 초기화 시키는 생성자
    
    //UIColor 클래스에서 보조 생성자를 만들어 rgb를 매번 호출하기 때문에 나누지 않아도 됨
    convenience init(r: CGFloat, g: CGFloat, b:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
           var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
           
           if hexFormatted.hasPrefix("#") {
               hexFormatted = String(hexFormatted.dropFirst())
           }
           
           assert(hexFormatted.count == 6, "Invalid hex code used.")
           
           var rgbValue: UInt64 = 0
           Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
           
           self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                     green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                     blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                     alpha: alpha)
       }
}

enum Category: CaseIterable, Hashable{
    //기술연습
    case practice
    //오픈매트
    case openMat
    //승급
    case promotion
    //대회
    case participation
    //노기
    case nogi
    
    var color: UIColor {
        switch self {
        case .practice:
            //convenience init 적용
            return UIColor(hexCode: "B3D3B8")
        case .openMat:
            return UIColor(hexCode: "80A5B2")
        case .promotion:
            return UIColor(hexCode: "6B6282")
        case .participation:
            return UIColor(hexCode: "CF7277")
        case .nogi:
            return UIColor(hexCode: "E8B558")
        }
    }
    
    var title: String {
        switch self {
        case .practice:
            return "기술연습"
        case .openMat:
            return "오픈매트"
        case .promotion:
            return "승급"
        case .participation:
            return "대회 출전"
        case .nogi:
            return "노기"
        }
    }
    
    var engTitle: String {
        switch self {
        case .practice:
            return "practice"
        case .openMat:
            return "openMat"
        case .promotion:
            return "promotion"
        case .participation:
            return "participation"
        case .nogi:
            return "nogi"
        }
    }
    
    var icon: UIImage {
        var image: UIImage?
        switch self {
        case .practice:
            image = UIImage(named: "practice.png")
        case .openMat:
            image = UIImage(named: "openMat.png")
        case .promotion:
            image = UIImage(named: "promotion.png")
        case .participation:
            image = UIImage(named: "participation.png")
        case .nogi:
            image = UIImage(named: "nogi.png")
        }
        
        return image ?? UIImage(systemName: "exclamationmark.triangle.fill")!
    }
    
    static var categoryColors : [Color] {
        return Category.allCases.map{Color(uiColor: $0.color)}
    }
    
    static func convertEngStringToCategory(_ str: String) -> Category? {
        switch str {
        case "practice":
            return .practice
        case "openMat":
            return .openMat
        case "promotion":
            return .promotion
        case "participation":
            return .participation
        case "nogi":
            return .nogi
        default:
            return nil
        }
    }
    
    static func convertStringToCategory(_ str: String) -> Category? {
        switch str {
        case "기술연습":
            return .practice
        case "오픈매트":
            return .openMat
        case "승급":
            return .promotion
        case "대회 출전":
            return .participation
        case "노기":
            return .nogi
        default:
            return nil
        }
    }
}

struct Post: Codable {
    
    var id: String
    var date: Date
    var times: [PostTimes]
    var satisfactionRate: Int
    var title: String
    var content: String
    var category: Category
    
    enum CodingKeys: String,CodingKey {
        case id
        case date
        case times
        case satisfactionRate
        case title
        case content
        case category
   }
    
    init(id: String, date: Date, times: [PostTimes], satisfactionRate: Int, title: String, content: String, category: Category){
        self.id = id
        self.date = date
        self.times = times
        self.satisfactionRate = satisfactionRate
        self.title = title
        self.content = content
        self.category = category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        satisfactionRate = try container.decode(Int.self, forKey: .satisfactionRate)
        
        let categoryString = try container.decode(String.self, forKey: .category)
        if let category = Category.convertEngStringToCategory(categoryString) {
            self.category = category
        } else {
            throw DecodingError.dataCorruptedError(forKey: .category, in: container, debugDescription: "Invaild Category Error")
        }
        
        let dateString = try container.decode(String.self, forKey: .date)
        self.date = Date.convertStringToDate(strDate: dateString)
        
        var timesContainer = try container.nestedUnkeyedContainer(forKey: .times)
        var decodedTimes: [PostTimes] = []
        
        while !timesContainer.isAtEnd {
            let time = try timesContainer.decode(PostTimes.self)
            decodedTimes.append(time)
        }
        times = decodedTimes
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(Date.convertDateToString(date: date), forKey: .date)
        try container.encode(satisfactionRate, forKey: .satisfactionRate)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(category.engTitle, forKey: .category)
        
        var timesContainer = container.nestedUnkeyedContainer(forKey: .times)
        for time in times{
            try timesContainer.encode(time)
        }
    }
}

struct PostTimes: Codable, Hashable{
    var startTime: Date
    var endTime: Date
    
    enum CodingKeys: String, CodingKey {
        case startTime
        case endTime
    }
    
    init(startTime: Date, endTime: Date){
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Date.convertTimeToString(time: startTime), forKey: .startTime)
        try container.encode(Date.convertTimeToString(time: endTime), forKey: .endTime)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let startTimeString = try container.decode(String.self, forKey: .startTime)
        self.startTime = Date.convertStringToTime(strTime: startTimeString)
        
        let endTimeString = try container.decode(String.self, forKey: .endTime)
        self.endTime = Date.convertStringToTime(strTime: endTimeString)
    }
    
}
