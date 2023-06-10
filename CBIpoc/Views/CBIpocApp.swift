//
//  CBIpocApp.swift
//  CBIpoc
//
//  Created by Victor Ponce on 31/05/23.
//

import SwiftUI
import FirebaseCore


@main
struct CBIpocApp: App {
    // register app delegate for Firebase setup

    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(User())
        }
    }
}

//struct ContentView_Previews: PreviewProvider{
//    static var previews: some view{
//        CBIpocApp()
//    }
//}
