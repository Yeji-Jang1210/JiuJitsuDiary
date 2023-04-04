//
//  BeltController.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/24.
//

import Foundation
import SwiftUI

class BeltUIController: ObservableObject{
    
    @Published var belt = Belt()
    @Published var maxGraus: Double = 4
    @Published var pretaWidth: CGFloat = 60
    @Published var pretaColor: Color = Color.black
    
    func changeToBlackBeltOption(){
        if belt.color == Color.black {
            maxGraus = 6
            pretaWidth = 85
            pretaColor = Color.red
        }
        else {
            if belt.graus >= maxGraus - 1 {
                belt.graus = 4
            }
            maxGraus = 4
            pretaWidth = 60
            pretaColor = Color.black
        }
    }
    
    
}
