//
//  LoginVIew.swift
//  CBIpoc
//
//  Created by Alberto  Guajardo on 03/06/23.
//
import SwiftUI
import GoogleSignIn
import Firebase

struct LoginView: View {
    @State private var isSignedIn = false

    var body: some View {
        VStack {
            Text("Welcome")
                .font(.largeTitle)
                .padding()

            if isSignedIn {
                Text("You are signed in!")
            } else {
                GoogleSignInButton()
                    .frame(width: 200, height: 50)
                    .padding()
            }
        }
        .onAppear {
            GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.first?.rootViewController
            GIDSignIn.sharedInstance()?.delegate = AppDelegate.shared
        }
    }
}

struct GoogleSignInButton: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<GoogleSignInButton>) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.style = .wide
        return button
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: UIViewRepresentableContext<GoogleSignInButton>) {
        // No need to update anything
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, GIDSignInDelegate {
    static let shared = AppDelegate()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Google Sign-In Error: \(error.localizedDescription)")
        } else {
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { (_, error) in
                if let error = error {
                    print("Firebase Authentication Error: \(error.localizedDescription)")
                } else {
                    // User successfully signed in
                    print("User signed in with Google")
                    // Perform any additional operations, such as navigating to the next screen, etc.
                }
            }
        }
    }
}
