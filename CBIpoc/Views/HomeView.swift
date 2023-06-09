//
//  HomeView.swift
//  CBIpoc
//
//  Created by Alberto  Guajardo on 08/06/23.
//
import SwiftUI

struct HomeView: View {
    @State private var isButtonClicked = false
    
    var body: some View {
        VStack {

            
            Image("innovationLogo")
                .padding(.top,10)
            Text("Welcome")
                .font(.largeTitle)
                .padding(.top,10)
            
            Spacer()
            
            Button(action: {
                            isButtonClicked = true
                        }) {
                            HStack {
                                Image(systemName: "plus.app")
                                    .font(.title)
                                Text("Upload")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                               
                            }
                            .foregroundColor(.white)
                            .frame(width: 300, height: 150)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]),
                                    startPoint: .topTrailing,
                                    endPoint: .bottomLeading
                                )
                            )
                            .cornerRadius(30)
                        }
            Spacer()
            Spacer()
        }
        .sheet(isPresented: $isButtonClicked) {
            ContentView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
