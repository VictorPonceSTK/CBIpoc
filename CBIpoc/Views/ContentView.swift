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
    @State private var loader = false // brings bottom slider up
    @State private var messageStatus = ""
    @EnvironmentObject var user: User
    @Binding var isButtonClicked:Bool
    var body: some View{
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
                        uploadToFirebase(image: image, userUID: user.UID, isDone: $loader, isCompleted: $isCompleted) { success, message in
                            messageStatus = message
                        }
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
                        uploadToFirebase(image: image, userUID: user.UID, isDone: $loader, isCompleted: $isCompleted)  { success, message in
                            isCompleted = success
                            messageStatus = message
                        }
                    }
                }
                
                Text("From Library")
                    .font(.headline)
            }
            Spacer()
        }.sheet(isPresented: $loader){
            if !isCompleted {
                NewGaleryOptionView() // Loading animation
            }
            else{
                VStack(spacing: 30){
                    HStack{
                        Text("Upload another picture?")
                    }
                    HStack(spacing: 20){
                        Button(action: { // This button will reset the view and will let the user pick to use the camera or gallery
                            isCompleted = false
                            loader = false
                        }){
                            Text("Yes")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 150)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            isButtonClicked = false // Will send the user back to the login page
                        }) {
                            Text("No")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 150)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                }
            }
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
