//
//  File.swift
//  
//
//  Created by 임훈 on 2023/07/10.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    class VideoPreviewView: UIView {
        
        // layerClass 재정의 AVCaptureVideoPreviewLayer로 지정
        // UIView 인스턴스 생성시 UIView의 레이어로 AVCaptureVideoPreviewLayer를 사용함.
        override class var layerClass: AnyClass {
             AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as? AVCaptureVideoPreviewLayer ?? AVCaptureVideoPreviewLayer()
        }
    }
    
    // AVCaptureSession은. AVFoundation 프래임워킂의 중심 클래스로, 미디어 캡쳐, 녹음, 입력, 출력, 데이터 흐름 컨트롤을 담당합니다.
    // 캡쳐 세션을 하나 이상의 입력소스 (예: 카메라, 마이크)로 부터 데이터를 받아들이고, 이 데이터를 하나 이상의 출력으로 제동합니다.
    
    // 미디어 캡처 장치의 선택: AVCaptureDevice를 사용하여 특정 미디어 타입(예: 비디오, 오디오)에 대한 입력 장치를 선택할 수 있습니다. 예를 들어, 프론트 카메라, 후면 카메라, 외장 마이크 등을 선택할 수 있습니다.
    // 입력 및 출력의 설정: AVCaptureInput과 AVCaptureOutput을 세션에 추가하여 미디어 데이터의 소스와 목적지를 정의합니다. 각 입력과 출력은 여러 개의 포트를 가질 수 있으며, 이러한 포트 간에 연결이 설정됩니다.
    // 세션 구성의 조정: 세션은 beginConfiguration과 commitConfiguration 메소드를 사용하여 복수의 입력과 출력의 추가 또는 제거를 원자적인 연산으로 처리합니다.
    // 미디어 데이터의 캡처 시작 및 중지: startRunning과 stopRunning 메소드를 사용하여 세션의 실행을 시작하거나 중지합니다.
    // 미디어 데이터의 미리보기: AVCaptureVideoPreviewLayer를 사용하여 카메라의 라이브 미디어 데이터를 화면에 미리 표시할 수 있습니다.
    let session: AVCaptureSession
   
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        
        view.videoPreviewLayer.session = session
        view.backgroundColor = .black
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.videoPreviewLayer.cornerRadius = 0
        view.videoPreviewLayer.connection?.videoOrientation = .portrait

        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        
    }
}

