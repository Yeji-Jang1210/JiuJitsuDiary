# JiuJitsuPlanner

## 목차
1. [SignUp](#signup)
2. [MainView](#mainview)

## SignUp

---

![1](https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/df5f1f91-a9d3-4b0a-a8d9-6f96d101d90a)

- 이메일과 패스워드를 입력하는 View이다.
- 이메일과 패스워드의 정규식 검사를 통해 사용가능한 형식이면 View가 넘어갈 수 있도록 구현하였다.

![2](https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/3422a2bd-90dc-43f4-a0de-54711a8215d5)

- 사진 앱에서 이미지를 추가 할 수 있도록 UIKit의 PHPickerView를 SwiftUI에서도 사용할 수 있도록 재구성하였다.
- 벨트 시스템을 구현하였다.


![3](https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/7189202c-f05d-4fce-b700-a22bc52fb5d7)

- 회원가입이 정상적으로 이루어졌을 경우 바로 로그인 되어 어플을 사용할 수 있다.
- Comfetti 효과를 사용하여 클릭했을 때 이모티콘들이 터지는재미있는 효과를 넣어보았다.
    
    ![Oct-17-2023 17-24-27](https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/7e041a2e-e0f3-428a-8c43-ded25e706bd4)


    
![4](https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/a6ffcfd5-1e9e-4fe5-8de5-d4ed6966afd1)

- 로그인 시 나타나는 오류에 따라 다른 메세지가 나오도록 구현하였다.


![5](https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/1e20ed0d-706a-4a80-9c42-fd9a0288ec16)

- 사용자가 패스워드를 잊어버렸을 경우 입력한 이메일로 재설정 할 수 있는 메일을 전송한다.
- 사용자는 메일을 통해 비밀번호를 재설정 한 후 로그인 창을 다시 이용할 수 있다.

## MainView

---


![9](https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/7b47eac7-4381-46f9-9250-2751ae5191b4)

- 앞서 FirebaseStorage와 FirebaseStore에 있는 모든 데이터들을 load 한 후 각 형식에 맞게 필터링 한다.
- 첫번째 Tab에서는 FSCalendar를 weekday만 표시 할 수 있게 수정
- 이번주에 해당하는 포스트들 필터링, 비디오를 포스트의 제일 첫번째로 올렸을 경우 이미지만 띄울 수 있도록 영상 데이터에서 이미지만 추출
    - 영상데이터에서 이미지만 추출하는 코드 보기
        
        ```swift
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
        ```
        
- 바로 추가 할 수 있도록 + 버튼을 통해 게시물 작성 View로 넘어가게 구현

![10](https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/2fa2208f-dc6a-41d2-aabb-3d549b616390)

- 작성했던 포스트들을 통계로 내어 얼마나 운동 했는지 확인 할 수 있도록 구현(import Chart)
- FSCalendar를 사용해 달력에 작성한 날짜와 카테고리별 이벤트를 표시할 수 있도록 구현
- 클릭 시 작성했던 포스트들의 정보가 나오고 클릭했을 때 작성한 포스트를 디테일 하게 볼 수 있음
- 수정과 삭제도 바로 할 수 있도록 구현하였다.


![11](https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/d94bf04b-2126-462e-af1b-39558128f593)

- 작성했던 포스트들을 정렬하거나 필터링 하여 확인할 수 있다.
- 이미지 클릭 시 각 포스트들을 디테일 하게 확인 할 수 있으며, 수정과 삭제도 가능하다.

![8](https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/806f89f3-3452-4582-99b9-4417957f4651)

![7](https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/d213d78d-d0e4-478b-9639-cbd9c64c615f)

- 사용자의 정보를 확인 할 수 있다.
- 운동하면서 있었던 일들을 한눈에 볼 수 있도록 업적 리스트를 구현하였다.
    - 업적의 CRUD도 관리할 수 있도록 구현
- 로그인 후 내정보 View에 들어가면 사용자가 입력한 정보들을 확인 할 수 있다.
    - 처음 사용자 정보를 등록했을 때와 같이 사진 앱에서 사진을 불러올 수 있고, 다른 정보들 또한 처음 처럼 수정이 가능하다.(단 생성한 이메일의 변경은 제외)
    - 이미지는 FirebaseStoreage로 처리하고 사용자 정보는 FirebaseStore로 처리해야 되기 때문에 두개를 전부 처리하는동안 사용자의 터치 제어를 막기 위해 로딩 뷰를 alert로 띄웠다.
    - 코드 전체보기
- 사용자의 정보를 수정하거나 로그아웃 및 회원 탈퇴 기능도 구현하였다.

  <img width="350" alt="13" src="https://github.com/Yeji-Jang1210/JiuJitsuPlanner/assets/62092491/24ca8fe7-2ee7-4fda-b6cb-bcd626319dfa">

    
