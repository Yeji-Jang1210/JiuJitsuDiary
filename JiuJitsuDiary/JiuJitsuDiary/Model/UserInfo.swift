//
//  UserInfo.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/02/08.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct UserInfo {
    var email: String?
    var profile: UIImage?
    var nickname: String?
    var birthday: String?
    var beltInfo: Belt?
    var achievements: [Achievement]?
}

struct Achievement: Codable, Hashable, Comparable {

    let uuid: String
    let state: String
    let title: String
    let date: String
    
    static func > (lhs: Achievement, rhs: Achievement) -> Bool{
        return lhs.date > rhs.date
    }
    
    static func < (lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.date < rhs.date
    }
}

enum AchievementStatus: Int, CaseIterable {
    case start = 0
    case promotion = 1
    case participation = 2
    case gold = 3
    case silver = 4
    case bronze = 5
    case etc = 6
    
    var message: String {
        switch self {
        case .start:
            return "start"
        case .promotion:
            return "promotion"
        case .participation:
            return "participation"
        case .gold:
            return "gold"
        case .silver:
            return "silver"
        case .bronze:
            return "bronze"
        case .etc:
            return "etc"
        }
    }
}

extension AchievementStatus {
    static subscript(state: String) -> AchievementStatus {
        switch state {
        case "start":
            return .start
        case "promotion":
            return .promotion
        case "participation":
            return .participation
        case "gold":
            return .gold
        case "silver":
            return .silver
        case "bronze":
            return .bronze
        case "etc":
            return .etc
        default:
            return .etc
        }
    }
    
    static func getStatusImage(status: AchievementStatus, size: CGFloat) -> UIImage? {
        switch status {
        case .start:
            return "🐥".textToImage(size)
        case .promotion:
            return "🥳".textToImage(size)
        case .participation:
            return "🤼".textToImage(size)
        case .gold:
            return "🥇".textToImage(size)
        case .silver:
            return "🥈".textToImage(size)
        case .bronze:
            return "🥉".textToImage(size)
        case .etc:
            return "🥋".textToImage(size)
        }
    }
    
    static func getStatusImage(string: String, size: CGFloat) -> UIImage? {
        switch string {
        case "start" :
            return "🐥".textToImage(size)
        case "promotion":
            return "🥳".textToImage(size)
        case "participation":
            return "🤼".textToImage(size)
        case "gold":
            return "🥇".textToImage(size)
        case "silver":
            return "🥈".textToImage(size)
        case "bronze":
            return "🥉".textToImage(size)
        case "etc":
            return "🥋".textToImage(size)
        default:
            return "⚠️".textToImage(40)
        }
    }
    
    static func getStatusMessage(status: AchievementStatus) -> String {
        switch status {
        case .start:
            return "시작"
        case .promotion:
            return "승급"
        case .participation:
            return "대회"
        case .gold:
            return "금메달"
        case .silver:
            return "은메달"
        case .bronze:
            return "동메달"
        case .etc:
            return "기타"
        }
    }
}

extension Date {
    static func convertDateToString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
    
    static func convertStringToDate(strDate: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.date(from: strDate) ?? Date.getCurrentDate()
    }
    
    static func convertTimeToString(time: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: time)
    }
    
    static func convertStringToTime(strTime: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.date(from: strTime) ?? Date.getCurrentDate()
    }
    
    static func fetchCurrentWeek()->[Date]{
        var calendar = Calendar(identifier: .gregorian)
        let currentDay = Date.getCurrentDate()
        var currentWeek:[Date] = []
        // 주의 시작을 일요일(1)로 설정
        calendar.firstWeekday = 1
        
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDay))!
        
        (0..<7).forEach{ day in
            //byAdding: 연산단위
            //value: 날짜에 더하거나 뺄 일의 수
            //to: 대상이 되는 기준 날짜
            if let weekday = calendar.date(byAdding: .day, value: day, to: startOfWeek){
                currentWeek.append(weekday)
            }
        }
        
        return currentWeek
    }
    
    static func extractDate(date: Date, format: String)-> String{
        let formatter =  DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
}

extension Date {
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
    
    func getDaysInMonth() -> Int{
        let calendar = Calendar.current

        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count

        return numDays
    }
    
    static func getCurrentDate() -> Date {
        let today = Date()
        let timezone = TimeZone.autoupdatingCurrent
        let secondsFromGMT = timezone.secondsFromGMT(for : today)
        return today.addingTimeInterval(TimeInterval(secondsFromGMT))
    }
}

