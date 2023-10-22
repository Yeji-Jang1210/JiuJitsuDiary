//
//  Belt.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/02/24.
//

import Foundation
import SwiftUI


enum BeltType: String {
    case Adult = "Adult"
    case Youth = "Youth"
}

struct Belt {
    var color: Color = Color.white
    var graus: Double = 0
    var type: BeltType = BeltType.Adult
}

extension Color {
    static subscript(name: String) -> Color {
        switch name {
        case "white":
            return Color.white
        case "blue":
            return Color.blue
        case "purple":
            return Color.purple
        case "brown":
            return Color.brown
        case "black":
            return Color.black
        case "gray":
            return Color.gray
        case "yellow":
            return Color.yellow
        case "orange":
            return Color.orange
        case "green":
            return Color.green
        default:
            return Color.accentColor
        }
    }
}
