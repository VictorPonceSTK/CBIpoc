import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var email = "victor.ponce@softtek.com"
    @State private var password = ""
    @EnvironmentObject var user: User
    var body: some View {
        if user.isLoggedIn {
            HomeView()
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
                            user.isLoggedIn = success
                            user.UID = Auth.auth().currentUser?.uid ?? ""
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
