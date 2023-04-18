//
//  BeltController.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/02/24.
//

import Foundation
import Combine
import SwiftUI

class BeltUIController: ObservableObject{
    
    @Published var maxGraus: Double = 4
    @Published var pretaWidth: CGFloat = 60
    @Published var pretaColor: Color = Color.black
    
    @Published var belt = Belt()
    
    //private var cancellables = Set<AnyCancellable>()
    
    init(){
//        $belt.sink { newValue in
//            NotificationCenter.default.post(name: .beltInfoUpdated, object: nil, userInfo: ["belt": newValue])
//        }
//        .store(in: &cancellables)
    }
    
    //let beltInfo = PassthroughSubject<Belt, Never>()
    
    let beltTypes = [
        BeltType.Adult: [Color.white, Color.blue, Color.purple, Color.brown, Color.black],
        BeltType.Youth: [Color.white, Color.gray, Color.yellow, Color.orange, Color.green]
    ]
    
    func changeToBlackBeltOption(color: Color){
        if color == Color.black {
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
    
//    func updateBeltInfo(belt: Belt){
//        beltInfo.send(belt)
//    }
}
