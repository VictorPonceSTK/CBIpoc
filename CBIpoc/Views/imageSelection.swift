import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseCore
let db = Firestore.firestore()

struct imageSelection: View {
    @State private var isCameraOpen = false
    @State private var isPhotoLibraryOpen = false
    @State private var isCompleted = false
    @State private var loader = false // brings the bottom slider up
    @State private var messageStatus = ""
    @State private var isImagePickedAlertPresented = false // Alert state
    @EnvironmentObject var user: User
    
    @Binding var isButtonClicked: Bool
    @Binding var selectedImage: UIImage?
    @Binding var sendToBard: Bool
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            VStack {
                Button(action: {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        AVCaptureDevice.requestAccess(for: .video) { granted in
                            if granted {
                                isCameraOpen = true
                            }
                        }
                    }
                }) {
                    Image(systemName: "camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 25)
                        .padding(.bottom, 25)
                }
                .sheet(isPresented: $isCameraOpen) {
                    ImagePicker(sourceType: .camera) { image in
                        selectedImage = image
                        print("Image was picked")
                        sendToBard = true
                    }
                }
                
                Text("From Camera")
                    .font(.headline)
            }
            
            VStack {
                Button(action: {
                    isPhotoLibraryOpen = true
                }) {
                    Image(systemName: "photo.stack")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 25)
                        .padding(.bottom, 25)
                }
                .sheet(isPresented: $isPhotoLibraryOpen) {
                    ImagePicker(sourceType: .photoLibrary) { image in
                        selectedImage = image
                        print("Image was picked")
                        print("Image \(image.size)")
                        sendToBard = true
                        isImagePickedAlertPresented = true // Show the alert
                    }
                }
                
                Text("From Library")
                    .font(.headline)
            }
            Spacer()
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
