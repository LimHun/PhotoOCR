//
//  CameraView.swift
//  PhotoOCR
//
//  Created by tunko on 2023/05/25.
//

import Foundation
import UIKit
import SwiftUI

struct CameraPickerView: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    
    typealias UIViewControllerType = UIImagePickerController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        
        let viewController = UIViewControllerType()
        viewController.delegate = context.coordinator
        viewController.sourceType = .camera
        viewController.cameraDevice = .rear
        viewController.cameraOverlayView = .none
        viewController.cameraFlashMode = .off
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> CameraPickerView.Coordinator {
        return Coordinator(self)
    }
}

extension CameraPickerView {
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            
        }
        
        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
            return nil
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
            }
            
            print("Image token")
            print("Width: " + image.size.width.description)
            print("Height: " + image.size.height.description)
            
            self.parent.image = image
            
//            // 랜드 스케이프로 변경함
//            if image.size.width > image.size.height {
//                self.parent.image = image.imageResized(to: CGSize(width: 3000, height: 2250))
//            } else {
//                self.parent.image = image.imageResized(to: CGSize(width: 3000, height: 2250))
//            }
        }
    }
}

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
