//
//  WriteView.swift
//  PhotoOCR
//
//  Created by tunko on 2023/05/25.
//

import SwiftUI
import Vision

struct WriteView: View {
     
    @State var selectUIImage: UIImage?
    
    @State var isPhotoPicker: Bool = false
    @State var isCameraPicker: Bool = false
    @State var isCropPicker: Bool = false
    
    @State var recognizedTexts: [String] = []
    
    var originalImage = UIImage(named: "movie")
    @State var croppedImage: UIImage?
    @State var cropperShown: Bool = false
    
    var body: some View {
        baseView()
            .fullScreenCover(isPresented: $isCameraPicker) {
                CameraView()
            }
            .sheet(isPresented: $isPhotoPicker) {
                TextRecognitionView(mode: .photo) 
            }
            .sheet(isPresented: $isCropPicker) {
                ImageCroppingView(shown: $cropperShown, image: originalImage!, croppedImage: $croppedImage)
            }
        
    }
    
    @ViewBuilder
    func baseView() -> some View {
        ZStack {
            buttonsView()
            cropView()
        }
    }
    
    @ViewBuilder
    func cropView() -> some View {
        VStack {
            Spacer()
            Image(uiImage: originalImage!)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Spacer()
            
            if croppedImage != nil {
                Text("Cropped")
                Image(uiImage: croppedImage!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
            }
        }
    }
    
    
    @ViewBuilder
    func buttonsView() -> some View {
        VStack {
            HStack {
                Button {
                    isCameraPicker.toggle()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.blue.opacity(0.5))
                        
                        Text("Camera Picker")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                Button {
                    isPhotoPicker.toggle()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.red.opacity(0.5))
                        
                        Text("Photo Picker")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                Button {
                    isCropPicker.toggle()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.red.opacity(0.5))
                        
                        Text("Crop Picker")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.top, 60)
            Spacer(minLength: .infinity)
            
        }
    }
    
    @ViewBuilder
    func pictureTakenView() -> some View {
        VStack {
            Image(uiImage: selectUIImage!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Button {
                selectUIImage = nil
                recognizedTexts = []
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
}

struct WriteView_Previews: PreviewProvider {
    static var previews: some View {
        WriteView()
    }
}
