//
//  File.swift
//  
//
//  Created by 임훈 on 2023/07/10.
//

import SwiftUI
import AVFoundation
import Combine
import Vision

class CameraViewModel: ObservableObject {
    
    let camera: Camera
    private let session: AVCaptureSession
    private var subscriptions = Set<AnyCancellable>()
    private var isCameraBusy = false
    
    let cameraPreview: AnyView
    let hapticImpact = UIImpactFeedbackGenerator()

    @Published var shutterEffect = false
    @Published var recentImage: UIImage?
    @Published var isFlashOn = false
    @Published var isSilentModeOn = false
    @Published var isSave = false
    @Published var recognizedString: String = ""
    @Published var recognizedStringList: [String] = []
    
    var callback: (String) -> Void = { _ in }
    
    init() {
        // 카메라 객체 초기화
        camera = Camera()
        
        // AVFoundation 프래임워크 AVCaptureSession 객체 초기화
        session = camera.session
        cameraPreview = AnyView(CameraPreviewView(session: session))
        
        // 카메라에 이미지가 바뀔때 처리
        camera.$recentImage.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.recentImage = pic
            self?.recognizeCardText(photo: pic)
        }
        .store(in: &self.subscriptions)
        
        camera.$isCameraBusy.sink { [weak self] (result) in
            self?.isCameraBusy = result
        }
        .store(in: &self.subscriptions)
    }
    
    func setCallback(callback: @escaping (String) -> Void) {
        self.callback = callback
    }
    
    // 초기 세팅
    func configure() {
        camera.requestAndCheckPermissions()
    }
    
    // 플래시 온오프
    func switchFlash() {
        isFlashOn.toggle()
        camera.flashMode = isFlashOn ? .on : .off
    }
    
    // 무음모드 온오프
    func switchSilent() {
        isSilentModeOn.toggle()
        print("isSilentModeOn : \(isSilentModeOn)")
        camera.isSilentModeOn = isSilentModeOn
    }
    
    // 사진 촬영
    func capturePhoto() {
        if isCameraBusy == false {
            hapticImpact.impactOccurred()
            withAnimation(.easeInOut(duration: 0.1)) {
                shutterEffect = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    self.shutterEffect = false
                }
            }
            
            camera.capturePhoto()
        } else {
            
        }
    }
    
    // 전후면 카메라 스위칭
    func changeCamera() {
        camera.switchCamera()
    }
}

extension CameraViewModel {
    
    func recognizeCardText(photo: UIImage?) {
        
        guard let photoCgImage = photo?.cgImage else {
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: photoCgImage)
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.recognitionLevel = .accurate   // 정확도 설정
        request.recognitionLanguages = ["ko"]  // 한글 인식 가능하도록 설정
        request.usesLanguageCorrection = false // 언어 수정 기능 비활성화 'a' -> 'o' 등으로 바뀔수가 있음.

        do {
            try requestHandler.perform([request])
        } catch {
            print("요청을 수행할 수 없습니다: \(error).")
        }
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        var texts: [String] = []
        let _: [()] = observations.compactMap { observation in
            let recongnizedText = observation.topCandidates(1).first!.string
            texts.append(recongnizedText)
        }
        processResults(texts)
    }
    
    func processResults(_ recognizedStrings: [String]) {
        withAnimation {
            self.recognizedStringList = recognizedStrings
        }
        
        recognizedString = ""
        recognizedStrings.forEach { string in
            recognizedString += string
        }
        print("recognizedString : \(recognizedString)")
        callback(recognizedString)
    }
}

