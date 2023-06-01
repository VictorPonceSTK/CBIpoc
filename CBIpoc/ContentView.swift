import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore
import Foundation

let db = Firestore.firestore()

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
    let storageRef = Storage.storage().reference().child("\(filename)")
    
    // Upload the image data to Firebase Storage
    let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
        if let error = error {
            print("Error uploading image: \(error.localizedDescription)")
            return
        }
        
        // Image uploaded successfully
        print("Image uploaded.")
        storageRef.downloadURL { (url, error) in
            if let error = error {
                print("Error retrieving download URL: \(error.localizedDescription)")
                return
            }
            
            guard let downloadURL = url else {
                print("Download URL is nil.")
                return
            }
            
            // Use the downloadURL for further processing
            print("Download URL: \(downloadURL)")
            let currentDate = Date()
            
            // Create a DateFormatter instance
            let dateFormatter = DateFormatter()
            
            // Set the date format
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss"
            
            // Format the current date using the date formatter
            let formattedDateTime = dateFormatter.string(from: currentDate)
            
            db.collection("images").addDocument(data: [
                "added_time": formattedDateTime,
                "name": filename,
                "url": "\(downloadURL)"
            ]){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            
        }
        // Get the download URL of the uploaded image
        
    }
}
