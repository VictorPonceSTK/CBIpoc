//
//  sendToBard.swift
//  CBIpoc
//
//  Created by Victor Ponce on 20/10/23.
//

import Foundation
import UIKit

func sendToBard(image: UIImage, completionHandler: @escaping (Error?,[String:String]) -> Void) {
    // Convert the UIImage to Data
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        completionHandler(NSError(domain: "ImageConversionError", code: 0, userInfo: nil), [:])
        return
    }
    
    
    let apiURL = URL(string: "http://127.0.0.1:8000/ingest/sendPictureTobard")!
    
    var request = URLRequest(url: apiURL)
    request.httpMethod = "POST"
    
    let boundary = "Boundary-\(UUID().uuidString)"

    // Set headers and content type
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    var body = Data()
    body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/jpg\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    
    // Attach image data to the request body
    request.httpBody = body
    
    print("request body: \(request.httpBody)")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("there was an error")
            completionHandler(error,[:])
            return
        }
        
        // Handle the response from the API
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                // Request was successful
                print("resp \(httpResponse)")
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                if let json = jsonData as? [String:String]{
                    print(json["filename"] ?? "error")
                    completionHandler(nil,json)
                }
            } else {
                // Handle API error (e.g., non-200 status code)
                completionHandler(NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: nil),[:])
            }
        }
    }
    
    task.resume()
}

// Usage example
//if let imageUrl = URL(string: "https://example.com/api/upload") {
//    if let image = UIImage(named: "yourImage.jpg") {
//        uploadImageToAPI(image: image, apiURL: imageUrl) { error in
//            if let error = error {
//                print("Error uploading image: \(error)")
//            } else {
//                print("Image uploaded successfully!")
//            }
//        }
//    }
//}

