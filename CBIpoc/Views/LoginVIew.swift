import SwiftUI
//import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn = false
    @State private var user = ""
    
    var body: some View {
        if userIsLoggedIn {
            ContentView(userUID: user)
        } else {
            VStack(spacing:100) {
                VStack {
                    Image("innovationLogo")
                        .padding(.top,10)
                    Text("Welcome")
                        .font(.largeTitle)
                        .padding(.top,10)
                    
                    TextField("Email",text: $email)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .textFieldStyle(.plain)
                        .padding([.top,.bottom],20)
                        .padding(.leading,40)
                    Rectangle()
                        .frame(width:350,height:1)
                        .foregroundColor(.blue)
                    
                    SecureField("Password",text: $password)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .textFieldStyle(.plain)
                        .padding([.top,.bottom],20)
                        .padding(.leading,40)
                    Rectangle()
                        .frame(width:350,height:1)
                        .foregroundColor(.blue)
                    
                }
                
                Button(action: {
                    if !email.isEmpty && !password.isEmpty {
                        login(){ success in
                            userIsLoggedIn = success
                            user = Auth.auth().currentUser?.uid ?? ""
                        }
                        print("Login successful")
                    } else {
                        print("Login failed")
                    }
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 50)
                
                Spacer()
                
            }
        }
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                print("There was an error!!")
                print(error!.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
