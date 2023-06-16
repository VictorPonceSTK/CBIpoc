//
//  sendToAnalyse.swift
//  CBIpoc
//
//  Created by Victor Ponce on 06/06/23.
//

import Foundation

func sendToAnalyse(inUrl:URL, body: [String: Any]){
    guard let url = URL(string: "https://shelfdetector.azurewebsites.net/api/analyse-image/from_url") else{
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
    } catch {
        print("Error serializing JSON: \(error)")
        return
    }
    
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        // Handle the response data
        if let data = data {
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: upload was successful")
            }
        }
    }
    
    task.resume()
}
