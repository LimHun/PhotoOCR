//
//  SwiftUIView.swift
//  
//
//  Created by 임훈 on 2023/07/10.
//

import SwiftUI
import AVFoundation

public struct CameraView: View {
    
    @ObservedObject var viewModel = CameraViewModel() // 카메라 뷰 모델
    @Environment(\.dismiss) var dismiss
    
    
    public init(callback: @escaping (String) -> Void) {
        self.viewModel.setCallback(callback: callback)
    }
    
    public var body: some View {
        ZStack {
            // 뷰모델에 있는 프리뷰
            // AnyView 형태로 어떤 뷰든지 들어갈 수있도록 함.
            // CameraPreviewView: UIViewRepresentable 형태로 프리뷰를 넣어줌.
            viewModel.cameraPreview
                .ignoresSafeArea()
                .onAppear {
                    viewModel.configure()   // 뷰 모델에 있는 초기 설정 함수 호출 (권한 설정 같음)
                }
            
            VStack(spacing: 0) {
                topButtonView()
                Spacer()
                
                bottomButtonView()
                    .padding(.horizontal, 16)
            }
            .foregroundColor(.white)
            
            VStack(spacing: 0) {
                Spacer()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 4) {
                        ForEach(viewModel.recognizedStringList, id: \.self) { text in
                            Text(text)
                                .foregroundColor(.white)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.black.opacity(0.25))
                                        .padding(-8)
                                }
                                .padding(8)
                        }
                    }
                }
                .frame(height: 200)
                .padding(.bottom, 85)
            }
        }
        .opacity(viewModel.shutterEffect ? 0 : 1)
    }
    
    @ViewBuilder
    func topButtonView() -> some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Text("닫기")
                    .font(.system(size: 14))
                    .fontWeight(.light)
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray.opacity(0.3))
                    }
            }
            .padding(.leading, 16)

            Spacer()
            speakerButtonView()
            flashOnOffButtonView()
            changeCameraButtonView()
        }
    }
    
    @ViewBuilder
    func changeCameraButtonView() -> some View {
        Button {
            viewModel.changeCamera()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .font(.system(size: 16))
                .frame(width: 44, height: 44)
        }
    }
    
    // 셔터사운드 온오프
    @ViewBuilder
    func speakerButtonView() -> some View {
        Button {
            viewModel.switchSilent()
        } label: {
            Image(systemName: viewModel.isSilentModeOn ? "speaker" : "speaker.fill")
                .font(.system(size: 16))
                .foregroundColor(viewModel.isSilentModeOn ? .white : .white)
                .frame(width: 44, height: 44)
        }
    }
    
    // 플래시 온오프
    @ViewBuilder
    func flashOnOffButtonView() -> some View {
        Button {
            viewModel.switchFlash()
        } label: {
            Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt")
                .font(.system(size: 16))
                .foregroundColor(viewModel.isFlashOn ? .white : .white)
                .frame(width: 44, height: 44)
        }
    }
    
    @ViewBuilder
    func bottomButtonView() -> some View {
        HStack(spacing: 0) {
            // 찍은 사진 미리보기
            Button(action: {}) {
                if let previewImage = viewModel.recentImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 75, height: 75)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .aspectRatio(1, contentMode: .fit)
                } else {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 1)
                        .foregroundColor(.white)
                        .frame(width: 75, height: 75)
                }
            }
            .frame(width: 75, height: 75)
            
            Spacer()
            
            // 사진찍기 버튼
            Button {
                viewModel.capturePhoto()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 65, height: 65)
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 75, height: 75)
                }
            }
            .frame(width: 75, height: 75)
            
            Spacer()
            
            // 전후면 카메라 교체
            Button {
                print("Text 사용하기")
            } label: {
                Text("사용")
                    .font(.system(size: 14))
                    .fontWeight(viewModel.recognizedStringList.count == 0 ? .light : .bold)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewModel.recognizedStringList.count == 0 ? .gray.opacity(0.3) : .green.opacity(0.5))
                    }
            }
            .frame(width: 75)
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView() { ocrText in
            
        }
    }
}
