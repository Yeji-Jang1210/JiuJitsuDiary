//
//  Belt.swift
//  JiuJitsuPlanner
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
