//
//  ImagePicker.swift
//  Matcha
//
//  Created by Chris Choi on 8/30/23.
//

import Foundation
import SwiftUI

// TODO: OFFER SQUARE CROP + RESIZE THE IMAGE
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // No need for updates in this example
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                // Get the center square portion of the image
                let imageSize = min(uiImage.size.width, uiImage.size.height)
                let croppedRect = CGRect(x: (uiImage.size.width - imageSize) / 2, y: (uiImage.size.height - imageSize) / 2, width: imageSize, height: imageSize)
                
                if let croppedCGImage = uiImage.cgImage?.cropping(to: croppedRect) {
                    let croppedImage = UIImage(cgImage: croppedCGImage)
                    
                    // Resize the cropped image to desired pixel dimensions
                    let newSize = CGSize(width: 150, height: 150)
                    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                    croppedImage.draw(in: CGRect(origin: .zero, size: newSize))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    parent.image = resizedImage
                }
                
                picker.dismiss(animated: true)
            }
        }
    }
}
