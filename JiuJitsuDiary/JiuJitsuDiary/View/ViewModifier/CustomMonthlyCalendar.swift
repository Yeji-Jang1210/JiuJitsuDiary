//
//  CustomMonthlyCalendar.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/06/27.
//

import SwiftUI
import UIKit
import FSCalendar
import Combine

struct Day: Hashable {
    let name: String
    let color: Color
}

struct CustomMonthlyCalendar: View {
    
    @EnvironmentObject var viewController: CustomCalendarViewController
    @State var height: CGFloat
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    init(height: CGFloat){
        self.height = height
    }
    
    var body: some View {
        VStack(spacing: 0){
            //header
            HStack(spacing: 20){
                VStack{
                    Text("\(viewController.extractDate()[0])")
                    HStack{
                        Text("\(viewController.extractDate()[1])")
                            .font(.system(size: 45).bold())
                    }
                }
                
                Spacer()
                
                Button {
                    viewController.scrollCurrentPage(isPrev: true)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title)
                }
                .foregroundColor(.primary)

                Button {
                    viewController.scrollCurrentPage(isPrev: false)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title)
                }
                .foregroundColor(.primary)

            }
            .padding(.horizontal)
            
            CalendarView()
                .environmentObject(viewController)
                .frame(height: height)
                .frame(maxWidth: .infinity)
        }
    }
}

struct CustomDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomMonthlyCalendar(height: .infinity)
            .environmentObject(CustomCalendarViewController())
    }
}

struct CalendarView: UIViewRepresentable {
    
    @EnvironmentObject var viewController: CustomCalendarViewController
    
    typealias UIViewType = FSCalendar
    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        
        //swiftUI에서도 delegate를 사용할 수 있도록
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        
        //header 값 설정
        //        calendar.appearance.headerDateFormat = "MM월"
        //        calendar.appearance.headerTitleColor = UIColor.label
        //        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 22)
        //        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.calendarHeaderView.isHidden = true
        calendar.headerHeight = 0
        calendar.appearance.weekdayTextColor = UIColor.label
        calendar.appearance.titleDefaultColor = UIColor.label
        calendar.appearance.todayColor = UIColor.label
        calendar.allowsMultipleSelection = false
        viewController.calendar = calendar
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        
        var parent: CalendarView
        var viewController: CustomCalendarViewController
        
        init(_ parent: CalendarView){
            self.parent = parent
            self.viewController = parent.viewController
            
        }
        
        // 선택된 날짜의 채워진 색상 지정
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
            return UIColor.secondaryLabel
        }
        
        //캘린더 이벤트 갯수 설정
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            let count = viewController.eventDatas.filter {
                areDatesOnSameDay(datel: date, dater: $0.date)
            }.count
            
            return count
        }
        
        //default event dot color
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]?{
            
            return changedEventsColors(date: date)
        }
        
        //select event dot color
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]?{
            return changedEventsColors(date: date)
        }
        
        // 날짜 선택 시 콜백 메소드
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            self.viewController.selectedDate = date
        }
        
        // 날짜 선택 해제 콜백 메소드
        func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
            self.parent.viewController.selectedDate = date
        }
        
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            viewController.currentPage = calendar.currentPage
        }
        
        func changedEventsColors(date: Date) -> [UIColor] {
            let events = viewController.eventDatas.filter{
                areDatesOnSameDay(datel: date, dater: $0.date)
            }
            
            return events.map{ $0.category.color }
        }
        
        func areDatesOnSameDay(datel: Date, dater: Date) -> Bool{
            let calendar = Calendar.current
            let dateComponents1 = calendar.dateComponents([.year, .month, .day], from: datel)
            let dateComponents2 = calendar.dateComponents([.year, .month, .day], from: dater)
            
            return dateComponents1.year == dateComponents2.year &&
            dateComponents1.month == dateComponents2.month &&
            dateComponents1.day == dateComponents2.day
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
}

class CustomCalendarViewController: ObservableObject {
    
    @Published var currentPage: Date?
    @Published var selectedDate = Date.now
    @Published var eventDataSubject = PassthroughSubject<[Post],Never>()
    @Published var eventDatas: [Post] = []
    
    var selectDateString: String {
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            return dateFormatter.string(from: selectedDate)
        }
    }
    
    var today: Date = {
        return Date()
    }()
    
    var calendar: FSCalendar?
    
    func extractDate() -> [String] {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "YYYY MM"
        
        let date = formatter.string(from: currentPage ?? self.today)
        
        return date.components(separatedBy:  " ")
    }
    
    func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
            
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        
        self.calendar?.setCurrentPage(self.currentPage!, animated: true)
    }
    
}
