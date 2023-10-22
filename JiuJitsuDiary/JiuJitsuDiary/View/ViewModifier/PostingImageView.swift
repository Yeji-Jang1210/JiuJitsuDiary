//
//  PostingImageView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/07/11.
//

import SwiftUI
import MediaPicker
import Combine
import AssetsLibrary
import AVFoundation
import _AVKit_SwiftUI

struct PostingImageView: View {
    
    @EnvironmentObject var viewController: MediaViewController
    
    let rows = [
        GridItem(.flexible())
    ]
    
    @State var clickedindex: Int = 0
    @State var isShowPhotoLibrary: Bool = false
    @State var isMediaPickerPresented: Bool = false
    
    @State var selectedImage: UIImage?
    @State var selectedImageIndex: Int?
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Text("📸 사진")
            
            GeometryReader{ geometryReader in
                TabView{
                    if viewController.selectedPostContentMedia.isEmpty {
                        Text("사진을 추가해 주세요.")
                    } else {
                        ForEach(viewController.selectedPostContentMedia.indices, id: \.self){ index in
                            switch viewController.selectedPostContentMedia[index].dataType {
                            case .image:
                                if let image = UIImage(data: viewController.selectedPostContentMedia[index].data){
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .ignoresSafeArea()
                                        
                                } else { Text("can't display image") }
                            case .video:
                                if let asset = FirebaseStorageManager.createAVAsset(fromData: viewController.selectedPostContentMedia[index].data){
                                    VideoPlayer(player: AVPlayer(playerItem: AVPlayerItem(asset: asset)))
                                        .aspectRatio(CGSize(width: geometryReader.size.width, height: ((geometryReader.size.width)/3) * 4), contentMode: .fill)
                                        .ignoresSafeArea()
                                } else {
                                    VStack(spacing: 20){
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60)
                                        
                                        Text("영상을 불러오는데 오류가 생겼습니다.")
                                    }
                                    .foregroundColor(.gray)
                                }
                            case .unknown:
                                Text("unknown: Can't display")
                            }
                        }
                    }
                    
                }
                .background(.gray.opacity(0.1))
                .frame(width: geometryReader.size.width, height: ((geometryReader.size.width)/3) * 4)
                .tabViewStyle(.page)
            }
            .frame(height: (UIScreen.main.bounds.width / 3) * 4 - 30)
            
            ScrollView(.horizontal){
                LazyHGrid(rows: rows){
                    Button {
                        isMediaPickerPresented.toggle()
                    } label: {
                        Rectangle()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray.opacity(0.3))
                            .overlay {
                                Image(systemName: "plus")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                                
                            }
                    }
                    .mediaImporter(isPresented: $isMediaPickerPresented, allowedMediaTypes: .all, allowsMultipleSelection: true) { result in
                        switch result {
                        case .success(let urls):
                            DispatchQueue.main.async {
                                for url in urls {
                                    viewController.appendMedia(url: url)
                                }
                            }
                        case.failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    
                    if !viewController.images.isEmpty {
                        ForEach(viewController.images.indices, id: \.self){ index in
                            let image = Image(uiImage: viewController.images[index])
                            image
                                .resizable()
                                .frame(width: 120, height: 120)
                                .overlay {
                                    if index == selectedImageIndex {
                                        Rectangle()
                                            .fill(.white.opacity(0.5))
                                            .overlay(alignment: .topTrailing) {
                                                Button {
                                                    viewController.selectedPostContentMedia.remove(at: index)
                                                    viewController.images.remove(at: index)
                                                } label: {
                                                    Image(systemName: "xmark")
                                                        .foregroundColor(.black)
                                                }
                                                .padding(5)
                                                
                                            }
                                    }
                                }
                                .onTapGesture {
                                    DispatchQueue.main.async {
                                        self.selectedImageIndex = index
                                    }
                                }
                            
                        }
                    }
                }
            }
            .frame(height: 120)
            .onAppear{
                viewController.addSubject()
            }
        }
    }
}

class MediaViewController: ObservableObject{
    @Published var images: [UIImage] = []
    @Published var postModeSubject = PassthroughSubject<PostMode, Never>()
    @Published var cancellables = Set<AnyCancellable>()
    @Published var isEditMode: Bool = false
    @Published var selectedPostContentMedia: [MediaData] = []
    @Published var isImagesUpdated: Bool = false
    
    @Published var appendingThumbnailImagesSubject = PassthroughSubject<MediaData, Never>()
    
    init(){

        postModeSubject
            .sink { postMode in
                if postMode == .add {
                    self.isEditMode = false
                } else {
                    self.isEditMode = true
                }
            }
            .store(in: &cancellables)
        
        appendingThumbnailImagesSubject
            .sink { media in
                self.getThumbnailImage(media: media) { image in
                    self.images.append(image)
                }
            }
            .store(in: &cancellables)
    }
    
    func addSubject(){
        $selectedPostContentMedia
            .sink { mediaData in
                // if added
                if mediaData.isEmpty {
                    self.isImagesUpdated = false
                } else {
                    
                    //if added
                    let isAdded = mediaData.filter{ !self.selectedPostContentMedia.map { $0.name }.contains($0.name)}
                    
                    //if removed
                    let isRemoved = self.selectedPostContentMedia.filter { !mediaData.map{ $0.name }.contains($0.name)}
                    
                    if !isAdded.isEmpty || !isRemoved.isEmpty {
                        self.isImagesUpdated = true
                    } else {
                        self.isImagesUpdated = false
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func convertContentTypeToString(_ type: PostContentType) -> String{
        switch type {
        case .image:
            return "image"
        case .video:
            return "video"
        case .unknown:
            return "unknown"
        }
    }
    
    func extractImageFromVideo(url: URL, completion: @escaping(_ image: UIImage?)->Void){
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let thumbnailTime = CMTimeMake(value: 7, timescale: 1)
            do{
                let cgThumbImage = try imageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func extractImageFromVideo(data: Data, completion: @escaping(_ image: UIImage?)->Void){
        DispatchQueue.global().async {
            guard let asset = FirebaseStorageManager.createAVAsset(fromData: data) else { return }
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let thumbnailTime = CMTimeMake(value: 7, timescale: 1)
            do{
                let cgThumbImage = try imageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func urlToUIImage(url: URL){
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                print("error")
                return
            }
            
            DispatchQueue.main.async {
                self.images.append(image)
            }
        }
        
        dataTask.resume()
    }
    
    func getPostContentType(url: URL)->PostContentType {
        guard let contentType = try! url.resourceValues(forKeys: [.contentTypeKey]).contentType else { return .unknown }
        switch contentType  {
        case let contentType where contentType.conforms(to: .image):
            return .image
        case let contentType where contentType.conforms(to: .audiovisualContent):
            return .video
        default:
            return .unknown
        }
    }
    
    func appendMedia(url: URL){
        do {
            let data = try Data(contentsOf: url)
            let content = MediaData(name: url.lastPathComponent, data: data, dataType: getPostContentType(url: url))
            selectedPostContentMedia.append(content)
            appendingThumbnailImagesSubject.send(content)
        }
        catch {
            print("can't append to selectedPostContentMedia[]: error")
        }
    }
    
    func getThumbnailImage(media: MediaData, completion: @escaping (UIImage) -> Void){
        switch media.dataType {
        case .image:
            if let image = UIImage(data: media.data) {
                completion(image)
            }
        case .video:
            extractImageFromVideo(data: media.data) { image in
                if let image = image{
                    completion(image)
                }
            }
        case .unknown:
            completion(UIImage(systemName: "exclamationmark.triangle.fill")!)
        }
    }
}

struct PostingImageViewTest: View {
    
    @State var images: [UIImage] = []
    
    var body: some View{
        PostingImageView()
            .environmentObject(MediaViewController())
    }
}

struct PostingImageView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        PostingImageViewTest()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
