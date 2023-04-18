//
//  FirebaseAuthManager.swift
//  JiuJitsuPlanner
//
//  Created by 장예지 on 2023/04/07.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


//final class FirebaseAuthManager {
//
//    static let shared = FirebaseAuthManager()
//
//    private init() {}
//
//    func createUser(email: String, password: String){
//        Auth.auth().createUser(withEmail: email, password: password){ [weak self] authResult, error in
//
//        }
//    }
//
//    func signIn(){}
//
//    func signOut(){}
//}

class FirebaseStorageManager {
    
    //FirebaseStorage사용
    //Storage에 imageName과 imageData를 파라미터로 넘겨서 저장 요청
    static func uploadProfileImage(_ image: UIImage, id: String, completion: @escaping ((_ url: String?)->())) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let filePath = "profile"

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"

        let storageRef = Storage.storage().reference().child("\(id)/\(filePath)")
        storageRef.putData(imageData, metadata: metaData){ metaData, error in
            storageRef.downloadURL { url, error in
                if let _url = url?.absoluteString {
                    completion(_url)
                    print(_url)
                    return
                }
            }
        }
    }
}
