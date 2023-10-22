//
//  CalendarTestView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/07/13.
//

import SwiftUI

struct CalendarTestView: View {
    
    @State var date: Date = Date.getCurrentDate()
    var body: some View {
        VStack{
            DatePicker("", selection: $date)
                .datePickerStyle(.graphical)
                
            Text("\(date)")
        }
    }
}

struct CalendarTestView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarTestView()
    }
}
