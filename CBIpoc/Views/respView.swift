//
//  respView.swift
//  CBIpoc
//
//  Created by Victor Ponce on 20/10/23.
//

import SwiftUI

struct respView: View {
    @State var answer:[String:String]
    @State var image:UIImage?
    @State var loading:Bool = true
    @State var showAlert:Bool = false
    
    @State var hack:Bool = false
    @State var done:Bool = false
    
    var body: some View {
        
        
        VStack{
            
            if let imageToBard = self.image {
                let width = imageToBard.size.width / 10
                let height = imageToBard.size.height / 10
                Image(uiImage:imageToBard)
                    .resizable()
                    .frame(width: width,height: height)
                    .alert(isPresented:$showAlert) {
                        Alert(
                            title: Text("Are you sure you want to use this image?"),
                            
                            primaryButton: .default(Text("Confirm")) {
                                hack = true
                            },
                            secondaryButton: .cancel(){
                                print("cancel was picked")
                            }
                        )
                    }
            }
            else{
                Text("no image was sent")
            }
            if done && hack{
                ScrollView{
                    ForEach(answer.sorted(by: <), id:\.key){resp in
                        Text("Key:\(resp.key), Value:\(resp.value)")
                    }
                }
            }
            
            
            if done && hack{
                Spacer()
                LoadingView()
                Spacer()
            }
            
            Spacer()
            
        }
        .onAppear{
            DispatchQueue.global(qos: .utility).async {
                sleep(1)
                DispatchQueue.main.async{
                    showAlert = true
                }
            }
            if let image = image{
                DispatchQueue.global(qos: .utility).async {
                    sendToBard(image:image) { success,resp  in
                        DispatchQueue.main.async{
                            if success == nil{
                                print("resp of api call: \(resp)")
                                answer = resp
                            }else{
                                answer = ["error":"an error has ocurred"]
                            }
                            done = true
                        }
                    }
                }
            }else{
                print("image is nil")
            }
        }
    }
}

