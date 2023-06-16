//
//  uploadToFirebase.swift
//  CBIpoc
//
//  Created by Victor Ponce on 10/06/23.
//

import Foundation
import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseFirestore

func uploadToFirebase( image: UIImage, userUID: String, isDone: Binding<Bool>,isCompleted: Binding<Bool> ,completion: @escaping (Bool, String) -> Void) {
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
            uploadDoc(url: downloadURL, filename: filename, userUID: userUID,
                      downloadURL: downloadURL, height:Int(height),width: Int(width), isCompleted:isCompleted) { success, message in
                return completion(success, message)
            }
        }
    }
}

func uploadDoc(url: URL, filename: String, userUID: String, downloadURL:URL, height:Int, width:Int, isCompleted:Binding <Bool>, completion: @escaping (Bool, String) -> Void) {
    //make this array into an object to make code cleaner
    let userImageSize: [String: Any] = [
        "width": width,
        "height": height
        
    ]
    let body = [
        "added_time": FieldValue.serverTimestamp(),
        "name": filename,
        "url": "\(url)",
        "size": userImageSize,
        "seen": false
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
