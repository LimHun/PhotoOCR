//
//  CameraTextRecognitionView.swift
//  PhotoOCR
//
//  Created by tunko on 2023/05/25.
//

import SwiftUI
import Vision

enum RecognitionViewMode {
    case camera
    case photo
}

struct TextRecognitionView: View {
    
    @State var mode: RecognitionViewMode
    @State private var imageTaken: UIImage?
    @State private var recognizedTexts: [String] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if self.imageTaken == nil {
                if mode == .camera {
                    CameraPickerView(image: $imageTaken)
                } else if mode == .photo {
                    PhotoPickerView(image: $imageTaken, isLoading: $isLoading)
                }
            } else {
                if !self.isLoading {
                    pictureTakenView()
                        .onAppear {
                            self.recognizeCardText()
                        }
                } else {
                    ProgressView()
                }
            }
        }
    }
    
    @ViewBuilder
    func pictureTakenView() -> some View {
        VStack {
            Image(uiImage: self.imageTaken!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Button {
                self.imageTaken = nil
                self.recognizedTexts = []
            } label: {
                HStack {
                    Image(systemName: "camera")
                    Text("Re-take picture")
                }
            }

            List {
                ForEach(self.recognizedTexts, id: \.self) {
                    Text("\($0)")
                }
            }
        }
    }
    
    func recognizeCardText() {
        let requestHandler = VNImageRequestHandler(cgImage: self.imageTaken!.cgImage!)
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.recognitionLevel = .accurate   // 정확도 설정
        request.recognitionLanguages = ["ko"]  // 한글 인식 가능하도록 설정
        request.usesLanguageCorrection = false // 언어 수정 기능 비활성화 'a' -> 'o' 등으로 바뀔수가 있음.

        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        var texts: [String] = []
        let recognizedStrings: [()] = observations.compactMap { observation in
            let recongnizedText = observation.topCandidates(1).first!.string
            texts.append(recongnizedText)
        }
        print("recognizedStrings.count : \(recognizedStrings.count)")
        processResults(texts)
    }
    
    func processResults(_ recognizedStrings: [String]) {
        print("processResults recognizedStrings : \(recognizedStrings)")
        self.recognizedTexts = recognizedStrings
    }
}
