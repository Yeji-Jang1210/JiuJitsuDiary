//
//  MainViewModel.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/08/15.
//

import Foundation
import Combine

import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import AVFoundation

struct MediaData:Hashable {
    var name: String
    var data: Data
    var dataType: PostContentType
}

extension Notification.Name {
    //선택한 포스트의 이미지 데이터가 바뀔 때 이벤트를 보내는
    static let isUpdatedSelectedPostsMediaNotification = Notification.Name("isUpdatedPostsNotification")
}

class MainViewModel: ObservableObject {

    var postViewModel: AddPostViewModel = AddPostViewModel()
    var calendarViewController: CustomCalendarViewController = CustomCalendarViewController()
    var weekcalendarViewController: WeeklyCalendarViewController = WeeklyCalendarViewController()
    
    private var email: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    let db = Firestore.firestore()
    
    @Published var posts: [Post] = []
    @Published var currentMonthlyPosts: [Post] = []
    @Published var currentWeeklyPosts: [Post] = []
    @Published var today: Date = Date.getCurrentDate()
    @Published var mainCalendarViewSelectedDateString: String?
    @Published var postsMediaContentData: [String: [MediaData]] = [:]

    @Published var filteredPosts: [Post] = []
    @Published var selectedOrderedValue: String = "최신순"
    @Published var selectedCategoryValue: String = "전체"
    @Published var sortedOptions = ["최신순", "오래된순"]
    @Published var categoryOptions: [String] = []
    @Published var isModified: Bool = false
    @Published var selectedPost: Post?
    @Published var monthlyStatics: [MonthlyCount] = []
    @Published var currentMonthCategoryStatics: [CategoryStatic] = []
    
    let selectedPostSubject = PassthroughSubject<Post, Never>()
    let completeLoadSubject = PassthroughSubject<Bool, Never>()
    let subject1 = CurrentValueSubject<String,Never>("최신순")
    let subject2 = CurrentValueSubject<String,Never>("전체")
    
    var todayString : [String]{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: today).components(separatedBy: " ")
    }
    
    var monthlyPostingCount: Int {
        var uniqueDates: Set<Date> = []
        var count = 0
        
        for post in currentMonthlyPosts {
            if !uniqueDates.contains(post.date) {
                uniqueDates.insert(post.date)
                count += 1
            }
        }
        
        return count
    }

    init(){
        if let user = Auth.auth().currentUser {
            guard let email = user.email else {
                NotificationCenter.default.post(name: .signOutNotification, object: nil)
                return
            }
            self.email = email
            loadPosts()
        } else {
            NotificationCenter.default.post(name: .signOutNotification, object: nil)
        }
        
        calendarViewController.$selectedDate
            .sink { date in
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ko_KR")
                dateFormatter.dateFormat = "yyyy-MM-dd"
                self.mainCalendarViewSelectedDateString = dateFormatter.string(from:date)
            }
            .store(in: &cancellables)
        
        $posts
            .dropFirst()
            .sink { posts in
//                self.currentMonthlyPosts = posts.filter { $0.date.isInThisMonth }
//                self.currentWeeklyPosts = posts.filter { $0.date.isInThisWeek }
//                self.filteredPosts = posts.sorted(by: { postl, postr in
//                    postl.date > postr.date
//                })
//                self.calendarViewController.eventDatas = posts
//                self.monthlyStatics = self.monthlyPostStatics()
            }
            .store(in: &cancellables)
        
        $currentWeeklyPosts
            .sink { posts in
                self.weekcalendarViewController.posts = posts
            }
            .store(in: &cancellables)
        
        $selectedOrderedValue
            .sink { newValue in
                self.subject2.send(newValue)
            }
            .store(in: &cancellables)
        
        categoryOptions.append("전체")
        
        for category in Category.allCases {
            categoryOptions.append(category.title)
        }
        
        $selectedCategoryValue
            .sink { newValue in
                self.subject1.send(newValue)
            }
            .store(in: &cancellables)
        
        subject1.combineLatest(subject2)
            .sink { sub1, sub2 in
                self.filteredPosts = self.posts
                
                if let category = Category.convertStringToCategory(sub1){
                    self.filteredPosts = self.posts.filter { $0.category == category}
                } else {
                    self.filteredPosts = self.posts
                }
                
                if sub2 == "최신순" {
                    self.filteredPosts.sort { postl, postr in
                        postl.date > postr.date
                    }
                } else if sub2 == "오래된순" {
                    self.filteredPosts.sort { postl, postr in
                        postl.date < postr.date
                    }
                }
            }
            .store(in: &cancellables)
        
        selectedPostSubject
            .sink { post in
                self.postViewModel.oldPost = post
                self.postViewModel.mediaViewController.images = []
                if let oldPostMedia = self.postsMediaContentData[post.id] {
                    self.postViewModel.mediaViewController.selectedPostContentMedia = oldPostMedia
                    for media in oldPostMedia {
                        self.postViewModel.mediaViewController.getThumbnailImage(media: media) { image in
                            self.postViewModel.mediaViewController.images.append(image)
                        }
                    }
                    
                }
                self.postViewModel.postMode = .edit
            }
            .store(in: &cancellables)
        
        completeLoadSubject
            .sink { result in
                self.currentMonthlyPosts = self.posts.filter { $0.date.isInThisMonth }
                self.currentWeeklyPosts = self.posts.filter { $0.date.isInThisWeek }
                self.filteredPosts = self.posts.sorted(by: { postl, postr in
                    postl.date > postr.date
                })
                self.calendarViewController.eventDatas = self.posts
                self.getMonthlyPostStatics()
                self.getCurrentMonthCategoryStatics()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatedSelectedPostMedia(notification: )), name: .isUpdatedSelectedPostsMediaNotification, object: nil)
        
    }
    
    @objc func updatedSelectedPostMedia(notification: Notification){
        guard let result = notification.object as? Post else { return }
        print("isModified")
        selectedPost = result
    }
    
    func loadPosts(){
        Firestore.firestore().collection("users").document(email).collection("posts").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print(String(describing: error))
            } else {
                guard let snapshot = querySnapshot else {
                    print("error")
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        print("Added")
                        do {
                            let data = try diff.document.data(as: Post.self)
                            self.posts.append(data)
                            self.getPostsMediaData(id: data.id)
                        } catch {
                            print(String(describing: error))
                        }
                        
                        
                    }
                    
                    if (diff.type == .modified) {
                        do {
                            let data = try diff.document.data(as: Post.self)
                            if let index = self.posts.firstIndex(where: { $0.id == data.id }){
                                self.posts[index] = data
                            }
                            
                        } catch {
                            print(String(describing: error))
                        }
                    }
                    
                    if (diff.type == .removed) {
                        do {
                            let data = try diff.document.data(as: Post.self)
                            self.posts = self.posts.filter{ $0.id != data.id }
                            
                        } catch {
                            print(String(describing: error))
                        }
                    }
                }
                
                self.completeLoadSubject.send(true)
                
            }
        }
    }
    
    func loadCurrentMonthPosts()->[Post]{
        return posts.filter{ $0.date.isInThisMonth }
    }
    
    func extractDayPostFromPosts(date: Date)-> [Post]{
        return posts.filter{ $0.date.isInSameDay(as: date)}
    }
    
    func getPostsMediaData(id : String){
        let storage = Storage.storage()
        let postRef = storage.reference().child("\(email)").child("\(id)")
        
        postRef.listAll { result , error in
            if let error = error {
                print(error)
            } else {
                if let result = result {
                    
                    for item in result.items {
                        let path = item.fullPath
                        print(path.description)
                        
                        item.getData(maxSize: 100 * 1024 * 1024) { data, error in
                            if let error = error {
                                print(error)
                            }
                                
                            if let data = data {
                                item.getMetadata { metadata, error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    }
                                    
                                    if let contentType = metadata?.contentType{
                                        // MIME 유형을 기반으로 파일 유형을 결정합니다.
                                        if contentType.contains("image") {
                                            self.addMediaContent(MediaData(name: path.components(separatedBy: "/").last ?? "Unknown", data: data, dataType: .image), forKey: id)
                                        } else if contentType.contains("video") {
                                            self.addMediaContent(MediaData(name: path.components(separatedBy: "/").last ?? "Unknown", data: data, dataType: .video), forKey: id)
                                        } else {
                                            self.addMediaContent(MediaData(name: path.components(separatedBy: "/").last ?? "Unknown", data: data, dataType: .unknown), forKey: id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addMediaContent(_ media: MediaData, forKey key: String) {
        // 특정 키에 대한 값이 이미 딕셔너리에 존재하는 경우
        if var existingContent = postsMediaContentData[key] {
            // 새로운 MediaContentType을 추가
            existingContent.append(media)
            postsMediaContentData[key] = existingContent
        } else {
            // 특정 키에 대한 값이 아직 없는 경우, 새로운 배열을 생성하고 추가
            postsMediaContentData[key] = [media]
        }
        
        self.postsMediaContentData = self.postsMediaContentData.mapValues { $0.sorted { $0.name < $1.name } }
        
        print("append postsMediaContentData: \(key)")
    }
    
    func deletePost(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            if let post = self.selectedPost {
                FirebaseStorageManager.deleteImage(email: self.email, id: post.id){ error in
                    if error != nil {
                        print("file delete error")
                        completion(false)
                    }
                    
                    self.db.collection("users").document(self.email).collection("posts").document(post.id).delete()
                    print("delete post succeessfully")
                    completion(true)
                }
            }
        }
    }
    
    func getMonthlyPostStatics(){
        let calendar = Calendar.current
        var monthlyStatics: [MonthlyCount] = []
        
        for month in 1...12{
            var dateComponent = DateComponents()
            dateComponent.day = 1
            dateComponent.month = month
            dateComponent.year = Int(Date.extractDate(date: Date.now, format: "YYYY"))
            
            guard let date = calendar.date(from: dateComponent) else { return }
            
            let uniqueMonth = Set(self.posts.map{$0.date})
            
            let monthlyCount = MonthlyCount(date: date, count: uniqueMonth.filter{ $0.isInSameMonth(as: date) }.count )
            print("\(monthlyCount.date): monthlyCount: \(monthlyCount.count)")
            monthlyStatics.append(monthlyCount)
            
        }
        
        self.monthlyStatics = monthlyStatics
    }
    
    func getCurrentMonthCategoryStatics(){
        var categoryStatics: [CategoryStatic] = []
        for category in Category.allCases {
            let count = self.posts.filter{ $0.category == category && $0.date.isInThisMonth }.count
            categoryStatics.append(CategoryStatic(category: category, count: count))
            print("\(category): \(count)")
        }
        
        self.currentMonthCategoryStatics = categoryStatics
    }
}

struct MonthlyCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct CategoryStatic: Identifiable {
    var id: String {
        category.title
    }
    var category: Category
    let count: Int
}
