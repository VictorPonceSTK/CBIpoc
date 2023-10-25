//
//  HomeView.swift
//  CBIpoc
//
//  Created by Alberto  Guajardo on 08/06/23.
//
import SwiftUI

struct HomeView: View {
    @State private var isButtonClicked = false
    @State var sendToBard = false
    @State var selectedImage:UIImage?
    @State var answer: [String:String] = [:]
    var body: some View {
        NavigationStack {
            VStack{
                Image("innovationLogo")
                imageSelection(isButtonClicked: $isButtonClicked,selectedImage:$selectedImage, sendToBard:$sendToBard)
            }
            .navigationDestination(isPresented: $sendToBard){
                if let image = selectedImage{
                    respView(answer: answer, image: selectedImage)
                }
                
            }
        }
    }
}

struct HomeView_preview: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

//            Image("innovationLogo")
//                .padding(.top,10)
//            Text("Welcome")
//                .font(.largeTitle)
//                .padding(.top,10)
//            Spacer()
//            Button(action: {
//                            isButtonClicked = true
//                        }) {
//                            HStack {
//                                Text("Upload")
//                                    .font(.title)
//                                    .fontWeight(.bold)
//
//
//                            }
//                            .foregroundColor(.white)
//                            .frame(width: 300, height: 150)
//                            .background(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]),
//                                    startPoint: .topTrailing,
//                                    endPoint: .bottomLeading
//                                )
//                            )
//                            .cornerRadius(30)
//                        }
//            Spacer()
//            Spacer()
//        }
//        .sheet(isPresented: $isButtonClicked) {
//            ContentView(isButtonClicked: $isButtonClicked,selectedImage:$selectedImage, sentToBard:$SentTobard   ) // Pass the binding variable
//            }
