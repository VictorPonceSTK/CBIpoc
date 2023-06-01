import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

let db = Firestore.firestore()
let storage = Storage.storage()
struct ContentView: View {
    @State private var isCameraOpen = false
    @State private var isPhotoLibraryOpen = false
    @State private var selectedImage: UIImage?
    
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
                ImagePicker(sourceType: .camera) { image in
                    selectedImage = image
                    uploadImage(image)
                }
            }
            
            Button("Open Library") {
                isPhotoLibraryOpen = true
            }
            .sheet(isPresented: $isPhotoLibraryOpen) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    selectedImage = image
                    uploadImage(image)
                }
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
    var didSelectImage: (UIImage) -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didSelectImage: didSelectImage)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var didSelectImage: (UIImage) -> Void
        
        init(didSelectImage: @escaping (UIImage) -> Void) {
            self.didSelectImage = didSelectImage
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                didSelectImage(image)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

func uploadImage(_ image: UIImage) {
    // Convert the UIImage to Data
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        print("Failed to convert image to Data.")
        return
    }
    
    // Generate a unique filename for the image
    let filename = UUID().uuidString + ".jpg"
    
    // Create a reference to the Firebase Storage location where the image will be uploaded
    let storageRef = storage.reference()
    
    // Upload the image data to Firebase Storage
    print("before uploading the pictre")
//    let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
//        if let error = error {
//            print("Error uploading image: \(error.localizedDescription)")
//            return
//        }
//
//        // Metadata contains file metadata such as size, content-type.
//        let size = metadata.size
//        // You can also access to download URL after upload.
//        storageRef.downloadURL { (url, error) in
//            guard let downloadURL = url else {
//                print("Error getting download URL: \(error.localizedDescription)")
//                return
//            }
//            if let downloadURL = url {
//                // You can save the downloadURL or perform any other operations with it
//                print("Download URL: \(downloadURL)")
//            }
//        }
//    }
//
//
//    //    let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
//    //        if let error = error {
//    //            print("Error uploading image: \(error.localizedDescription)")
//    //            return
//    //        }
//    //
//    //        // Image uploaded successfully
//    //        print("Image uploaded.")
//    //
//    //        // Get the download URL of the uploaded image
//    //        storageRef.downloadURL { (url, error) in
//    //            if let error = error {
//    //                print("Error getting download URL: \(error.localizedDescription)")
//    //                return
//    //            }
//    //
//    //            if let downloadURL = url {
//    //                // You can save the downloadURL or perform any other operations with it
//    //                print("Download URL: \(downloadURL)")
//    //            }
//    //        }
//    //    }
//
//    // Observe the upload progress if needed
//    uploadTask.observe(.progress) { snapshot in
//        // Handle upload progress updates
//        guard let progress = snapshot.progress else {
//            return
//        }
//
//        let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100.0
//        print("Upload progress: \(percentComplete)%")
//    }
}
