//
//  AchievementViewModel.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/05/09.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import Combine


//Achievement CRUD구현하기
class AchievementViewModel: ObservableObject {
    
    @Published private var uuid: String = ""
    @Published var email: String = ""
    @Published var title: String = ""
    @Published var date: Date = Date.getCurrentDate()
    @Published var dateString: String = ""
    @Published var selectedStatus: AchievementStatus = AchievementStatus.start
    @Published var isAchievementAddClick: Bool = false
    @Published var isAchievementEditClick: Bool = false
    
    @Published var achievements: [Achievement]?
    @Published var selectedAchievement: Achievement?
    @Published var selectedAchievementIndex: Int?
    
    @Published var isDelete: Bool = false
    @Published var isUpdate: Bool = false
    
    
    private var cancellables = Set<AnyCancellable>()
    
    var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY년 MM월 dd일"
            return formatter
    }
    
    private var db = Firestore.firestore()
    
    init(){

        $date
            .map { (date) -> String in
                return self.dateFormatter.string(from: date)
            }
            .sink { value in
                self.dateString = value
            }
            .store(in: &cancellables)
        
        $isAchievementAddClick
            .sink { isActive in
                if isActive {
                    self.uuid = ""
                    self.title = ""
                    self.dateString = self.dateFormatter.string(from: Date.getCurrentDate())
                    self.date = Date.getCurrentDate()
                    self.selectedStatus = AchievementStatus.start
                    self.selectedAchievement = nil
                }
            }
            .store(in: &cancellables)
        
        $isAchievementEditClick
            .sink { isActive in
                if isActive {
                    self.uuid = self.selectedAchievement?.uuid ?? ""
                    self.title = self.selectedAchievement?.title ?? ""
                    self.dateString = self.selectedAchievement?.date ?? self.dateFormatter.string(from: Date.getCurrentDate())
                    self.date = self.dateFormatter.date(from: self.dateString) ?? Date.getCurrentDate()
                    self.selectedStatus = AchievementStatus[self.selectedAchievement?.state ?? "etc"]
                } else {
                    self.title = ""
                    self.dateString = self.dateFormatter.string(from: Date.getCurrentDate())
                    self.date = Date.getCurrentDate()
                    self.selectedStatus = AchievementStatus.start
                    self.selectedAchievement = nil
                }
            }
            .store(in: &cancellables)
    }

    func createAchievement() {
        
        let data: [String: Any] = [
            "uuid" : UUID().uuidString,
            "title" : self.title,
            "date" : self.dateString,
            "state" : self.selectedStatus.message
        ]
        
        Just(data)
            .tryMap { data in
                db.collection("users").document(self.email).setData([
                    "achievements": FieldValue.arrayUnion([data])
                ], merge: true)
            }
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error writing achievement to Firestore: \(error.localizedDescription)")
                    } else {
                        print("Document updated successfully")
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func updateAchievement(){

        let dRef = db.collection("users").document(self.email)
        let newData: [String: Any] = [
            "uuid" :  UUID().uuidString,
            "title" : self.title,
            "date" : self.dateString,
            "state" : self.selectedStatus.message
        ]
        
        Just(newData)
            .tryMap { data in
                dRef.getDocument { document, error in
                    if let document = document, document.exists {
                        var achievements = document.get("achievements") as? [[String: Any]] ?? []
                        
                        achievements = achievements.filter { $0["uuid"] as? String != self.uuid }
                        
                        dRef.updateData(["achievements": achievements]){ error in
                            if let error = error {
                                print("Error deleting document: \(error)")
                            } else {
                                dRef.updateData(["achievements": FieldValue.arrayUnion([newData])
                                                ]) { error in
                                    if let error = error {
                                        print("Error updating document: \(error)")
                                    } else {
                                        print("Document updated successfully")
                                    }
                                }
                            }
                        }
                    }
                }
            }.sink(
                receiveCompletion: { completion in
                    DispatchQueue.main.async{
                        if case let .failure(error) = completion {
                            print("Error writing achievement to Firestore: \(error.localizedDescription)")
                        } else {
                            print("Document updated successfully")
                        }
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
    }
    
    func deleteAchievement(){
        let data: [String: Any] = [
            "uuid" :  self.uuid,
            "title" : self.title,
            "date" : self.dateString,
            "state" : self.selectedStatus.message
        ]
        
        let docRef = db.collection("users").document(self.email)
        
        Just(data)
            .tryMap { data in
                docRef.updateData(["achievements": FieldValue.arrayRemove([data])])
            }
            .sink(
                receiveCompletion: { completion in
                    DispatchQueue.main.async{
                        if case let .failure(error) = completion {
                            print("Error writing achievement to Firestore: \(error.localizedDescription)")
                        } else {
                            print("Document updated successfully")
                        }
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
