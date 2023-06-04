import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseCore
let db = Firestore.firestore()

struct ContentView: View {
    @State private var isCameraOpen = false
    @State private var isPhotoLibraryOpen = false
    @State private var selectedImage: UIImage?
    @State private var isCompleted = false
    @State private var messageStatus = ""
    var userUID = ""
//    @EnvironmentObject private var completionStatus: UploadStatus = UploadStatus()

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
                    uploadImage(image,userUID){ success, message in
                        isCompleted = success
                        messageStatus = message
                    }
                }
            }
            
            Button("Open Library") {
                isPhotoLibraryOpen = true
            }
            .sheet(isPresented: $isPhotoLibraryOpen) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    selectedImage = image
                    uploadImage(image, userUID){ success, message in
                        isCompleted = success
                        messageStatus = message
                    }
                }
            }
        }
        .padding()
        .alert(isPresented: $isCompleted) {
            Alert(
                title: Text("Status message"),
                message: Text("Image has been uploaded sucessfully"),
                dismissButton: .default(Text("Close"))
            )
        }
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

func uploadImage(_ image: UIImage, _ userUID: String, completion: @escaping (Bool, String) -> Void) {
    // Convert the UIImage to Data
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        print("Failed to convert image to Data.")
        return
    }
    
    // Generate a unique filename for the image
    let filename = UUID().uuidString + ".jpg"
    // Create a reference to the Firebase Storage location where the image will be uploaded
    let storageRef = Storage.storage().reference().child(filename)
    // Upload the image data to Firebase Storage
    let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
        if let error = error {
            print("Error uploading image: \(error.localizedDescription)")
            
            return completion(false, "Error uploading image: \(error.localizedDescription)")
        }
        
        // Image uploaded successfully
        storageRef.downloadURL { (url, error) in
            if let error = error {
                print("Error retrieving download URL: \(error.localizedDescription)")
                return completion(true, "Error retrieving download URL: \(error.localizedDescription)")
            }
            
            guard let downloadURL = url else {
                print("Download URL is nil.")
                return completion(true,"Download URL is nil!")
            }
            print("Image uploaded sucessfully with url: \(url)")
//            return completion(true,"Image uploaded successfully!")
            uploadDoc(url: downloadURL, filename: filename, userUID: userUID) { success, message in
                return completion(success, message)
            }
        }
    }
}

func uploadDoc(url: URL, filename: String,userUID: String,completion: @escaping (Bool, String) -> Void) {
    db.collection("users").document(userUID).collection("images").document().setData([
        "added_time": Int(NSDate().timeIntervalSince1970),
        "name": filename,
        "url": "\(url)"
    ]) { err in
        if let err = err {
            print("Error writing document: \(err)")
            completion(false, "Failed to upload document: \(err.localizedDescription)")
        } else {
            print("Document successfully written!")
            completion(true, "Document uploaded successfully")
        }
    }
}
