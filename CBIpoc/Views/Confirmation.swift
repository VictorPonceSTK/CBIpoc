//
//  Confirmation.swift
//  CBIpoc
//
//  Created by Victor Ponce on 23/10/23.
//

import SwiftUI


struct Confirmation: View {
    @State var selectedImage:UIImage?
    @Binding var userConfirmation:Bool
    @State var fakeConfirm = true
    //    @Binding var sendToBard:Bool
    @State private var isShowingAlert = false

    var body: some View {

//            Color.black.opacity(0.4)
//                .edgesIgnoringSafeArea(.all)
//                .opacity(isShowingAlert ? 1 : 0)
//                .animation(.easeInOut(duration: 0.3))
            
            VStack {
                Text("Custom Alert")
                    .font(.title)
                    .padding()
                
                Text("This is a custom SwiftUI alert.")
                    .padding()
                
                Button("Confirm") {
                    isShowingAlert.toggle()
                    // Handle OK action here
                }
                .buttonStyle(AlertButtonStyle(isCancel: false))
                
                Button("Cancel") {
                    isShowingAlert.toggle()
                    // Handle Cancel action here
                }
                .buttonStyle(AlertButtonStyle(isCancel: true))
            }
//            .frame(width: 300, height: 200)
//            .background(Color.white)
//            .cornerRadius(10)
//            .opacity(isShowingAlert ? 1 : 0)
//            .animation(.easeInOut(duration: 0.3))
  
 
    }
}

struct AlertButtonStyle: ButtonStyle {
    let isCancel: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(isCancel ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}


struct Confirmation_Preview: PreviewProvider {
    static var previews: some View {
        @State var userConfirmation = false
        Confirmation(userConfirmation: $userConfirmation)
    }
}
