//
//  LoginView.swift
//  CBIpoc
//
//  Created by Victor Ponce on 03/06/23.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing:100) {
            VStack{
                Text("Welcome")
                    .font(.largeTitle)
                    .padding(.top,150)
                
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
                // Perform login logic here
                // You can access the entered username and password using the 'username' and 'password' variables
                
                // Example login logic:
                if email == "admin" && password == "password" {
                    // Successful login
                    print("Login successful")
                } else {
                    // Failed login
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
