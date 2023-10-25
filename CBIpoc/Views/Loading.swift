//
//  NewGaleryOptionView.swift
//  CBIpoc
//
//  Created by Victor Ponce on 09/06/23.
//
//  This view geneartes the loading animation that you see
//  after uploading a picture to the backend


import SwiftUI

struct LoadingView: View {
    @State private var isLoading = false;
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 14)
                .frame(width: 100, height: 100)
            
            Circle()
                .trim(from: 0, to: 0.2)
                .stroke(Color.blue, lineWidth: 7)
                .frame(width: 100, height: 100)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .onAppear() {
                    withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                        self.isLoading = true
                    }
                }
        }
    }
}

struct NewGaleryOptionView_Preview:PreviewProvider{
    static var previews: some View {
        LoadingView()
    }
}
