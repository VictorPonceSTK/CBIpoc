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
                        uploadImage(image: image, userUID: user.UID, isDone: $loader, isCompleted: $isCompleted) { success, message in
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
                        uploadImage(image: image, userUID: user.UID, isDone: $loader, isCompleted: $isCompleted)  { success, message in
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
                //victor.ponce@softtek.com
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
                            user.isLoggedIn = false // Will send the user back to the login page
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

func uploadImage( image: UIImage, userUID: String, isDone: Binding<Bool>,isCompleted: Binding<Bool> ,completion: @escaping (Bool, String) -> Void) {
    isDone.wrappedValue = true
    
    // Convert the UIImage to Data
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        print("Failed to convert image to Data.")
        return
    }
    
    let width = image.size.width
    let height = image.size.height
    
    // Generate a unique filename for the image
    let filename = UUID().uuidString + ".jpg"
    // Create a reference to the Firebase Storage location where the image will be uploaded
    let storageRef = Storage.storage().reference().child(filename)
    // Upload the image data to Firebase Storage
    storageRef.putData(imageData, metadata: nil) { (metadata, error) in
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
            print("Image uploaded successfully with url: \(String(describing: url))").self
            //            completion(true, "Document uploaded successfully")
            uploadDoc(url: downloadURL, filename: filename, userUID: userUID,
                      downloadURL: downloadURL, height:Int(height),width: Int(width), isCompleted:isCompleted) { success, message in
                return completion(success, message)
            }
        }
    }
}

func uploadDoc(url: URL, filename: String, userUID: String, downloadURL:URL, height:Int, width:Int, isCompleted:Binding <Bool>, completion: @escaping (Bool, String) -> Void) {
    //make this array into an object to make code cleaner
    let body = [
        "added_time": FieldValue.serverTimestamp(),
        "name": filename,
        "url": "\(url)",
        "height": height,
        "width" : width,
        "open": false
    ] as [String : Any]
    
    let ref = db.collection("users").document(userUID).collection("images").document()
    db.collection("users").document(userUID).collection("images").document(ref.documentID).setData(body) {  err in
        if let err = err {
            print("Error writing document: \(err)")
            completion(false, "Failed to upload document: \(err.localizedDescription)")
        } else {
            let apiBody = [
                "url":"\(url)",
                "user_id": userUID,
                "document_id": ref.documentID
            ] as [String: Any]
            print("sending to api", apiBody)
            completion(true, "Document uploaded successfully")
            sendToAnalyse(inUrl:downloadURL, body:apiBody)
            sendToPredict(inUrl:downloadURL, body:apiBody)
            print("Document successfully written!")
            isCompleted.wrappedValue = true
            
        }
    }
}
