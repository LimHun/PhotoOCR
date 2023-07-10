//
//  PhotoPickerView.swift
//  PhotoOCR
//
//  Created by tunko on 2023/05/24.
//

import SwiftUI
import PhotosUI
import UIKit
  
struct PhotoPickerView: UIViewControllerRepresentable {
     
    @Binding var image: UIImage?
    @Binding var isLoading: Bool
    
    func makeUIViewController(context: Context) -> some PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        picker.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "버튼", style: .done, target: self, action: nil)
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
                    
            let itemProvider = results.first?.itemProvider
            
            if let itemProvider = itemProvider,
               itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage 
                        //self.parent.isLoading = false
                    } 
                }
                
                
            } else {  
                // TODO: Handle empty results or item provider not being able load UIImage
            }
        }
    }
}
