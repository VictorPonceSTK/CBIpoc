//
//  ContentView.swift
//  CBIpoc
//
//  Created by Victor Ponce on 31/05/23.
//
import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var isCameraOpen = false
    @State private var isPhotoLibraryOpen = false

    var body: some View {
        VStack(spacing: 50) {
            Button("Open Camera") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            isCameraOpen = true
                        }
                    }
                }
            }
            .sheet(isPresented: $isCameraOpen) {
                ImagePicker(sourceType: .camera)
            }
            
            Button("Open Library") {
                isPhotoLibraryOpen = true
            }
            .sheet(isPresented: $isPhotoLibraryOpen) {
                ImagePicker(sourceType: .photoLibrary)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
}
