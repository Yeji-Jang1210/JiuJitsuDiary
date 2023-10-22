//
//  CustomWeeklyCalendarView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/07/18.
//

import SwiftUI
import UIKit
import FSCalendar

struct CustomWeeklyCalendarView: View {
    @EnvironmentObject var controller: WeeklyCalendarViewController
    
    let today = Date()
    var calendar = Calendar.current
    
    @State var selectDate: Date?

    var body: some View {
        
        VStack(spacing: 20){
            HStack(alignment: .top){
                ForEach(controller.currentWeek, id: \.self){ day in
                    VStack(spacing: 20){
                        Text(Date.extractDate(date: day, format: "EEE"))
                        
                        Text(Date.extractDate(date: day, format: "dd"))
                            .foregroundColor(controller.isToday(date: day) ? .white : .black)
                            .bold()
                            .background{
                                Circle()
                                    .fill(controller.isToday(date: day) ? .black : .clear)
                                    .frame(width: 45, height: 45)
                            }
                        
                        HStack{
                            ForEach(controller.isEqualEventDay(day).indices, id: \.self){ index in
                                if index < 2 {
                                    Circle()
                                        .fill(Color(uiColor: controller.isEqualEventDay(day)[index].category.color))
                                        .frame(width: 5, height: 5)
                                } else {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10, height: 10)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth:. infinity)
        
    }
}

struct CustomWeeklyCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CustomWeeklyCalendarView()
            .environmentObject(WeeklyCalendarViewController())
    }
}

class WeeklyCalendarViewController: ObservableObject {
    @Published var currentWeek: [Date] = []
    @Published var posts: [Post] = []
    
    var calendar = Calendar(identifier: .gregorian)
    
    init(){
        self.currentWeek = Date.fetchCurrentWeek()
    }
    
    func isToday(date: Date) -> Bool{
        return date.isInToday
    }
    
    func isEqualEventDay(_ day: Date)->[Post]{
        return Array(posts.filter({$0.date.isInSameDay(as: day)}).prefix(3))
    }
}
