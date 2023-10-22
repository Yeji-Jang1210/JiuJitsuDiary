//
//  AddPostViewModel.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/08/15.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import Combine

enum PostMode {
    case add, edit
}

class AddPostViewModel: ObservableObject {
    
    var mediaViewController: MediaViewController = MediaViewController()
    
    private var email: String = ""
    
    @Published var id: String = UUID().uuidString
    @Published var date: Date = Date.now
    @Published var times: [PostTimes] = []
    @Published var updatedDatas: [String:Any] = [:]
    
    @Published var title: String = "" {
        didSet{
            if self.title.count > 20 && oldValue.count <= 20 {
                self.title = oldValue
                self.maximumTitleMessage = "20자 이내로 입력해 주세요."
            } else {
                self.maximumTitleMessage = ""
            }
        }
    }
    
    @Published var content: String = "" {
        didSet {
            if content.count > 500 && oldValue.count <= 500 {
                content = oldValue
                maximumContentMessage = "500자 이내로 입력해 주세요."
            } else {
                maximumContentMessage = ""
            }
        }
    }
    
    @Published var satisfactionRate: Int = 5
    @Published var category: Category = .practice
    @Published var postMode: PostMode = .add
    @Published var maximumTitleMessage: String = ""
    @Published var maximumContentMessage: String = ""
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var firebaseSetDataError: Bool = false
    @Published var oldPost: Post?
    @Published var isPostImagesUpdated: Bool = false
    
    init(){
        
        if let user = Auth.auth().currentUser {
            guard let email = user.email else {
                NotificationCenter.default.post(name: .signOutNotification, object: nil)
                return
            }
            self.email = email
        } else {
            NotificationCenter.default.post(name: .signOutNotification, object: nil)
        }
        
        $postMode
            .sink { postMode in
                if postMode == .add {
                    self.id = UUID().uuidString
                    self.date = Date.now
                    self.times = []
                    self.satisfactionRate = 5
                    self.title = ""
                    self.content = ""
                    self.category = .practice
                    self.mediaViewController.images = []
                    self.mediaViewController.selectedPostContentMedia = []
                    self.mediaViewController.postModeSubject.send(.add)
                } else {
                    self.mediaViewController.postModeSubject.send(.edit)
                    
                }
            }
            .store(in: &cancellables)
        
        $oldPost
            .sink { post in
                if let post = post {
                    self.id = post.id
                    self.category = post.category
                    self.content = post.content
                    self.times = post.times
                    self.date = post.date
                    self.satisfactionRate = post.satisfactionRate
                    self.title = post.title
                }
            }
            .store(in: &cancellables)
        
        mediaViewController.$isImagesUpdated
            .sink { value in
                self.isPostImagesUpdated = value
            }
            .store(in: &cancellables)
        
    }
    
    func appendTimes(){
        if times.count < 5 {
            times.append(PostTimes(startTime: Date.now, endTime: Date.now))
        }
        
    }
    
    func removeTimes(index: Int){
        times.remove(at: index)
    }
    
    func registerPost(completion: @escaping (Bool)->Void){
        
        var post = Post(id: id, date: date, times: times, satisfactionRate: satisfactionRate, title: title, content: content, category: category)
        
        if postMode == .add {
            FirebaseStorageManager.uploadPostImages(medias: mediaViewController.selectedPostContentMedia, email: email, postId: id){ [self] paths in
                do{
                    //import FirebasestoreSwift
                    try self.db.collection("users").document(email).collection("posts").document(post.id).setData(from: post)
                    DispatchQueue.main.async{
                        completion(true)
                    }
                    
                } catch {
                    DispatchQueue.main.async{
                        completion(false)
                    }
                }
                
            }
        } else {
            
            guard let oldPost = oldPost else {
                DispatchQueue.main.async{
                    completion(false)
                }
                return
            }
            
            if isPostImagesUpdated {
                post.id = UUID().uuidString
                FirebaseStorageManager.uploadPostImages(medias: self.mediaViewController.selectedPostContentMedia, email: self.email, postId: post.id) { error in
                    if error != nil {
                        print("error: \(error.debugDescription)")
                        DispatchQueue.main.async{
                            completion(false)
                        }
                    }
                    
                    FirebaseStorageManager.deleteImage(email: self.email, id: oldPost.id){ error in
                        if error != nil {
                            print("file delete error")
                            DispatchQueue.main.async{
                                completion(false)
                            }
                        }
                    }
                    
                    do {
                        try self.db.collection("users").document(self.email).collection("posts").document(post.id).setData(from: post, merge: true)
                        self.db.collection("users").document(self.email).collection("posts").document(oldPost.id).delete()
                    } catch {
                        print("post upload failed")
                        DispatchQueue.main.async{
                            completion(false)
                        }
                    }
                    
                    print("send completion: true")
                    NotificationCenter.default.post(name: .isUpdatedSelectedPostsMediaNotification, object: post)
                    DispatchQueue.main.async{
                        completion(true)
                    }
                }
            } else {
                do {
                    post.id = oldPost.id
                    try self.db.collection("users").document(self.email).collection("posts").document(oldPost.id).setData(from: post, merge: true)
                    print("send completion: true")
                    NotificationCenter.default.post(name: .isUpdatedSelectedPostsMediaNotification, object: post)
                    DispatchQueue.main.async{
                        completion(true)
                    }
                } catch {
                    print("post upload failed")
                    DispatchQueue.main.async{
                        completion(false)
                    }
                }
            }
        }
    }
}
