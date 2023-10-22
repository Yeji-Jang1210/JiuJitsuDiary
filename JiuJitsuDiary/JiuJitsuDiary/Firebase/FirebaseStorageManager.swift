//
//  FirebaseStorageManager.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/04/07.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import AVFoundation

enum PostContentType {
    case image, video, unknown
}

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
    
    static func uploadPostImages(medias: [MediaData], email: String, postId: String, completion: @escaping (Error?) -> Void ){
        let postRef = Storage.storage().reference()
        var uploadTasks: [StorageUploadTask] = []
  
        var count = 0
        
        for media in medias {

            let metaData = StorageMetadata()
            switch media.dataType {
            case .image:
                metaData.contentType = "image/jpeg"
            case .video:
                metaData.contentType = "video/mp4"
            case .unknown:
                metaData.contentType = ""
            }
            
            let imagePath = "\(email)/\(postId)/\(postId)_\(count)"
            let postFileRef = postRef.child("\(imagePath)")
            
            let uploadTask = postFileRef.putData(media.data,metadata: metaData)
            uploadTasks.append(uploadTask)
            
            print(uploadTask.snapshot.description)
            
            count += 1
        }
        
        // 모든 업로드 작업 완료 여부를 관찰
        let uploadGroup = DispatchGroup()
        
        for uploadTask in uploadTasks {
            uploadGroup.enter()
            
            uploadTask.observe(.success) { snapShot in
                print(snapShot.description)
                uploadGroup.leave()
            }
            
            uploadTask.observe(.failure) { snapshot in
                if let error = snapshot.error as? NSError {
                    switch (StorageErrorCode(rawValue: error.code)!) {
                    case .objectNotFound:
                        print("File doesn't exist")
                        completion(error)
                        break
                    case .unauthorized:
                        print("User doesn't have permission to access file")
                        completion(error)
                        break
                    case .cancelled:
                        print("User canceled the upload")
                        completion(error)
                        break
                    case .unknown:
                        print("Unknown error occurred, inspect the server response")
                        completion(error)
                        break
                    default:
                        print("error")
                        completion(error)
                        break
                    }
                }
                
                uploadGroup.leave()
            }
        }
        
        //모든 업로드 작업 후 실행
        uploadGroup.notify(queue: .main){
            completion(nil)
        }
    }
    
    static func downloadProfileImage(url email: String, completion: @escaping (UIImage?) -> Void) {
        let urlString = "\(email)/profile"
        
        Storage.storage().reference().child(urlString).downloadURL { url, error in
            if error != nil {
                completion(nil)
                return
            }
            
            guard let url = url else {
                completion(nil)
                return
            }
            
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    }
                }
            }
            
            completion(nil)
            
        }
    }
    
    static func getContentTypeAndUrls(url: String, completion: @escaping (PostContentType) -> Void){
        let urlReference = Storage.storage().reference(forURL: url)
        urlReference.getMetadata { metadata, error in
            if error != nil {
                print("error")
            } else {
                if let contentType = metadata?.contentType{
                    // MIME 유형을 기반으로 파일 유형을 결정합니다.
                    if contentType.contains("image") {
                        completion(.image)
                    } else if contentType.contains("video") {
                        completion(.video)
                    } else {
                        completion(.unknown)
                    }
                }
            }
        }
    }
    
    static func deleteImage(email: String, id: String, completion: @escaping (Error?) -> Void){
        let fileRef = Storage.storage().reference().child("\(email)/\(id)")
        fileRef.listAll { result, error in
            if let error = error {
                completion(error)
            } else {
                guard let items = result?.items else {
                    completion(StorageErrorCode.bucketNotFound)
                    return
                }
                for item in items {
                    item.delete { error in
                        if error != nil {
                            completion(error)
                        }
                    }
                }
            }
        }
        completion(nil)
    }
    
    static func deleteProfileStroage(email: String, completion: @escaping (Bool) -> Void){
        let imageRef = Storage.storage().reference()
        imageRef.child("\(email)/profile").delete { error in
            if let err = error {
                print(err)
                completion(false)
            }
        }
        completion(true)
    }
    
    static func deleteStroage(path: String, completion: @escaping (Bool) -> Void){
        let imageRef = Storage.storage().reference()
        imageRef.child(path).delete { error in
            if let err = error {
                print(err)
                completion(false)
            }
        }
        completion(true)
    }
    
    static func extractImageFromVideo(url: URL) -> UIImage {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let thumbnailTime = CMTimeMake(value: 7, timescale: 1)
        do{
            let cgThumbImage = try imageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
            let thumbImage = UIImage(cgImage: cgThumbImage)
            return thumbImage
        } catch{
            print(error.localizedDescription)
        }
        return UIImage(systemName: "exclamationmark.triangle")!
    }
    
    static func extractImageFromVideo(data: Data) -> UIImage {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempVideo.mp4")
        do {
            try data.write(to: url)
        } catch {
            print("Error writing video data to file: \(error.localizedDescription)")
        }
        
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let thumbnailTime = CMTimeMake(value: 7, timescale: 1)
        do{
            let cgThumbImage = try imageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
            let thumbImage = UIImage(cgImage: cgThumbImage)
            return thumbImage
        } catch{
            print(error.localizedDescription)
        }
        return UIImage(systemName: "exclamationmark.triangle")!
    }
    
    static func createAVAsset(fromData data: Data) -> AVAsset? {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent("tempVideo.mp4")
        
        do {
            try data.write(to: temporaryFileURL)
            
            // 임시 파일을 사용하여 AVAsset 초기화
            let asset = AVAsset(url: temporaryFileURL)
            
            // 임시 파일 삭제 (더 이상 필요하지 않을 경우)
            //try FileManager.default.removeItem(at: temporaryFileURL)
            
            return asset
        } catch {
            print("Error writing or initializing AVAsset: \(error.localizedDescription)")
            return nil
        }
    }
}
