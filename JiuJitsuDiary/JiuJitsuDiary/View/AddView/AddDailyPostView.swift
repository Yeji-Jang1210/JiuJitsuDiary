//
//  AddDailyPostView.swift
//  JiuJitsuDiary
//
//  Created by 장예지 on 2023/06/28.
//

import SwiftUI
import FSCalendar

struct AddDailyPostView: View {
    
    enum Field: Hashable {
        case title, content
    }
    
    @EnvironmentObject var viewModel: AddPostViewModel
    @Environment(\.presentationMode) var presentationMode
    @FocusState var focusField: Field?
    
    @State var isCalendarPresented: Bool = true
    @State var maxRating: Int = 5
    
    @State var columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State var hashtagRows: [GridItem] = [GridItem(.flexible())]
    @State var clickedindex: Int = 0
    @State var isRegisterAlertPresented: Bool = false
    @State var isReadyLoadingView: Bool = false
    @State var isLoadingViewPresented: Bool = false
    
    let categoryRows = [
        GridItem(.flexible()),
    ]
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(spacing: 40){
                        VStack(alignment: .leading){
                            HStack{
                                Text("🗓 날짜")
                                
                                HStack{
                                    Button {
                                        withAnimation{
                                            isCalendarPresented.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "calendar")
                                                .foregroundColor(.black)
                                            
                                            Text("\(viewModel.dateString)")
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            
                            if isCalendarPresented {
                                DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                                    .environment(\.locale, Locale.init(identifier: "ko_KR"))
                                    .datePickerStyle(.graphical)
                                    .tint(.black)
                                    
                            }
                            
                            Divider()
                        }
                        
                        VStack{
                            HStack{
                                Text("⏰ 시간")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button {
                                    withAnimation{
                                        viewModel.appendTimes()
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .foregroundColor(.black)
                                }
                            }
                            
                            if viewModel.times.isEmpty {
                                Text("시간을 추가해 주세요.")
                                    .padding(.vertical)
                            }
                            
                            ForEach(viewModel.times.indices, id: \.self){ index in
                                HStack(spacing: 40){
                                    Text("\(index + 1) 타임")
                                    
                                    HStack{
                                        DatePicker(selection: $viewModel.times[index].startTime, displayedComponents: .hourAndMinute) {
                                            Text("")
                                        }
                                        .labelsHidden()
                                        
                                        Text(" ~ ")
                                        
                                        DatePicker(selection: $viewModel.times[index].endTime, displayedComponents: .hourAndMinute) {
                                            Text("")
                                        }
                                        .labelsHidden()
                                        
                                        if !viewModel.times.isEmpty {
                                            Button {
                                                withAnimation {
                                                    viewModel.removeTimes(index: index)
                                                }
                                            } label: {
                                                Image(systemName: "minus.circle")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                                                        
                            Divider()
                        }
                        .id(1)
                        
                        //별점
                        VStack{
                            Text("💪🏻 운동 만족도")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 30){
                                ForEach(1..<maxRating + 1, id: \.self){ number in
                                    
                                    RoundedStar(cornerRadius: 3)
                                        .scale(viewModel.satisfactionRate < number ? 1.0 : 1.5)
                                        .aspectRatio(1, contentMode: .fit)
                                        .foregroundColor(viewModel.satisfactionRate < number ? .gray : .yellow)
                                        .rotationEffect(Angle(degrees: 20))
                                        .onTapGesture {
                                            viewModel.satisfactionRate = number
                                        }
                                        .frame(width: 30, height: 30)
                                        .animation(.linear.speed(2.0), value: viewModel.satisfactionRate < number)
                                }
                            }.padding(.vertical)
                            Divider()
                        }

                        //이미지 및 동영상 로드 창
                        VStack{
                            PostingImageView()
                                .environmentObject(viewModel.mediaViewController)
                        }
                        .id(2)
                        
                        VStack(spacing: 20){
                            VStack{
                                VStack{
                                    HStack{
                                        Text("✏️ 제목")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("\(viewModel.title.count)/20")
                                            .foregroundColor(.gray)
                                    }
                                    
                                    TextField("제목을 입력해 주세요.", text: $viewModel.title)
                                        .focused($focusField, equals: .title)
                                        .overlay(alignment: .trailing) {
                                            Button {
                                                DispatchQueue.main.async{
                                                    viewModel.title = ""
                                                }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .onSubmit {
                                            focusField = Field.content
                                        }
                                    
                                    Text("\(viewModel.maximumTitleMessage)")
                                        .foregroundColor(.red)
                                }
                                Divider()
                            }
                            .id(3)
                            
                            VStack{
                                HStack{
                                    Text("🗒 설명")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("\(viewModel.content.count)/500")
                                        .foregroundColor(.gray)
                                }
                                
                                TextEditor(text: $viewModel.content)
                                    .focused($focusField, equals: .content)
                                    .lineSpacing(5)
                                    .frame(height: 400)
                                    .overlay(alignment: .topLeading) {
                                        if viewModel.content.count < 1 {
                                            Text("500자 이내로 입력해 주세요.")
                                                .foregroundColor(.gray.opacity(0.5))
                                                .padding(.top)
                                                .offset(y: -4)
                                        }
                                    }
                                
                                Text("\(viewModel.maximumContentMessage)")
                                    .foregroundColor(.red)
                            }
                            .id(4)
                            Divider()
                            
                            VStack(spacing: 10){
                                Text("📒 카테고리")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ScrollView {
                                    LazyHGrid(rows: categoryRows, alignment: .center, spacing: .maximum(25, 25)) {
                                        ForEach(Category.allCases, id: \.self){ category in
                                            Button {
                                                viewModel.category = category
                                            } label: {
                                                VStack(spacing: 10){
                                                    Image(uiImage: category.icon)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 40, height: 40)
                                                    Text("\(category.title)")
                                                        .foregroundColor(.black)
                                                }
                                            }
                                            .opacity(viewModel.category == category ? 1.0 : 0.5)
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(viewModel.postMode == .add ? "게시물 작성" : "게시물 수정")
                    .toolbar{
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                viewModel.postMode = .add
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("뒤로")
                                    .foregroundColor(.black)
                            }
                        }
                        
                        ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarTrailing) {
                            Button {
                                withAnimation{
                                    scrollToEmptyField(scrollViewProxy: scrollViewProxy)
                                }
                            } label: {
                                Text("저장")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .alert(isPresented: $isRegisterAlertPresented,
                           alert:
                            DefaultAlertView( alertType: .custom(title: "확인", message: "저장 하시겠습니까?", image: "person.fill.checkmark")){
                        ButtonView(title: "확인") {
                            DispatchQueue.main.async {
                                focusField = nil
                                UIApplication.shared.endEditing()
                                isReadyLoadingView = true
                                isRegisterAlertPresented = false
                            }
                        }
                    } secondButton: {
                        ButtonView(title: "잘 모르겠어요", color: Color(red: 190/255, green: 190/255, blue: 190/255), role: .destructive){
                            isRegisterAlertPresented = false
                        }
                    })
                    .alert(isPresented: $viewModel.firebaseSetDataError, alert: DefaultAlertView(alertType: .error(title: "오류", message: "저장하는데 오류가 발생했습니다."), primaryButton: {
                        ButtonView(title: "확인") {
                            viewModel.firebaseSetDataError = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }))
                    .showLoadingView(isPresented: $isLoadingViewPresented,
                                     view: LoadingView(isShowing: $isLoadingViewPresented, text: "정보를 기록 하는 중 입니다."))
                    .onChange(of: isReadyLoadingView) {
                        if isReadyLoadingView {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                DispatchQueue.main.async {
                                    isLoadingViewPresented = true
                                    viewModel.registerPost{ result in
                                        if result {
                                            print("get result: registerPost")
                                            isLoadingViewPresented = false               
                                            presentationMode.wrappedValue.dismiss()
                                        } else {
                                            viewModel.firebaseSetDataError = true
                                        }
                                    }
                                }
                                isReadyLoadingView = false
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func scrollToEmptyField(scrollViewProxy: ScrollViewProxy) {
        if viewModel.times.isEmpty {
            scrollViewProxy.scrollTo(1, anchor: .center)
        } else if viewModel.mediaViewController.images.isEmpty{
            scrollViewProxy.scrollTo(2, anchor: .center)
        } else if viewModel.title.isEmpty || viewModel.title == "" {
            scrollViewProxy.scrollTo(3, anchor: .center)
        } else if viewModel.content.isEmpty {
            scrollViewProxy.scrollTo(4, anchor: .center)
        } else {
            isRegisterAlertPresented.toggle()
        }
    }
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

struct AddDailyPostView_Previews: PreviewProvider {
    static var previews: some View {
        AddDailyPostView()
            .environmentObject(AddPostViewModel())
    }
}
