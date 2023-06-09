//
//  File.swift
//  
//
//  Created by 임훈 on 2023/07/10.
//

import SwiftUI
import AVFoundation

class Camera: NSObject, ObservableObject {
    
    // AVCaptureSession은 AVFoundation 프레임워크 중심 클래스로, 미디어 캡처, 녹음, 입력, 출력, 데이터 흐름 컨트롤을 담당합니다.
    var session = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    let output: AVCapturePhotoOutput = AVCapturePhotoOutput()
    var photoData: Data = Data(count: 0)
    var isSilentModeOn: Bool = true
    var flashMode: AVCaptureDevice.FlashMode = .off
    
    @Published var recentImage: UIImage?
    @Published var isCameraBusy: Bool = false
    @Published var isSave: Bool = false
 
    // 카메라 셋업 과정을 담당하는 함수,
    func setUpCamera() {
        // 디바이스 카메라 장치 조회
        // .builtInWideAngleCamera: 모바일 기본 카메라 모드
        // .video 비디오 타입
        // .back 후면 카메라
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            do { // 카메라가 사용 가능하면 세션에 input과 output을 연결
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
                
                if let videoDeviceInput = videoDeviceInput {
                    if session.canAddInput(videoDeviceInput) {
                        session.addInput(videoDeviceInput)
                    }
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                    output.isHighResolutionCaptureEnabled = true    // 고해상도 사진 캡쳐 가능 옵션
                    output.maxPhotoQualityPrioritization = .quality // 사진 품질을 최우선시
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    self.session.startRunning() // 세션 시작
                }
            } catch {
                print(error) // 에러 프린트
            }
        }
    }
    
    // 카메라 권한 상태 확인
    func requestAndCheckPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus {
                    DispatchQueue.main.async {
                        self?.setUpCamera()
                    }
                }
            }
        case .restricted:
            break
        case .authorized:
            setUpCamera()
        default:
            print("Permession declined")
        }
    }
    
    func capturePhoto() {
        // 사진 옵션 세팅
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = self.flashMode
        
        self.output.capturePhoto(with: photoSettings, delegate: self)
        print("[Camera]: Photo's taken")
    }
    
    func savePhoto(_ imageData: Data) {
        guard let image = UIImage(data: imageData) else {
            return
        }
        
        if !isSave {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // 사진 저장하기
        print("[Camera]: Photo's saved")
    }
    
    func switchCamera() {
        
        guard let videoDeviceInput = videoDeviceInput else {
            return
        }
        
        // 현재 카메라 포지션 (전면, 후면)
        let currentPosition = videoDeviceInput.device.position
        let newPosition: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: newPosition).devices

        guard let newDevice = devices.first else {
            print("Device not found")
            return
        }

        let newVideoInput: AVCaptureDeviceInput!
        do {
            newVideoInput = try AVCaptureDeviceInput(device: newDevice)
        } catch let error {
            print(error)
            return
        }

        // 기존 입력을 제거하고 새 입력을 추가
        session.beginConfiguration()
        session.removeInput(videoDeviceInput)

        if session.canAddInput(newVideoInput) {
            session.addInput(newVideoInput)
            self.videoDeviceInput = newVideoInput
        } else {
            session.addInput(videoDeviceInput)
        }

        session.commitConfiguration()
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        self.isCameraBusy = true
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        if isSilentModeOn {
            print("[Camera]: Silent sound activated")
            AudioServicesDisposeSystemSoundID(1108)
        }
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        if isSilentModeOn {
            AudioServicesDisposeSystemSoundID(1108)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        print("[CameraModel]: Capture routine's done")
        
        self.photoData = imageData
        self.recentImage = UIImage(data: imageData)
        self.savePhoto(imageData)
        self.isCameraBusy = false
    }
}
