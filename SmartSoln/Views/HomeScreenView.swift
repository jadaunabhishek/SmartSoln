//
//  HomeScreen.swift
//  SmartSoln
//
//  Created by Abhishek Jadaun on 14/03/24.
//

import SwiftUI

struct HomeScreenView: View {
    
    // Enter your details
    @State private var yourDetails = false

    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    
    
    var body: some View {
        ZStack {
            Color("BgColor").edgesIgnoringSafeArea(.all)
            VStack {
                
                Text("Please choose the following option.")
                    .frame(maxWidth: 360, alignment: .leading)
                    .padding(.top)
                    .padding(.bottom, 5)
                
                VStack() {
                    Image("eKYC")
                        .resizable()
                        .frame(width: 330, height: 160)
                        .cornerRadius(20.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20.0)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding(.top)
                        .padding(.trailing)
                        .padding(.leading)
                    
                    Text("eKYC procedure")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: 330, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 6)
                    
                    Text("Welcome to our eKYC app! To complete the verification process smoothly, please follow these simple steps: Enter your details accurately, upload a clear photo of your Aadhar card, capture a live photo of yourself, and submit your request. Your security and convenience are our top priorities.")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .frame(maxWidth: 330, alignment: .leading)
                        .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            yourDetails = true
                        }) {
                            Text("Start")
                                .padding(.horizontal, 25)
                                .padding(.vertical, 10)
                                .background(Color("PrimaryColor"))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
                    .padding()
                    .sheet(isPresented: $yourDetails, content: {
                        KYCForm()
                    })
                }
                .navigationBarBackButtonHidden(true)
                .background(Color.white)
                .cornerRadius(20.0)
                .padding([.leading, .trailing])
                .shadow(color: Color.black.opacity(0.08), radius: 60, x: 0.0, y: 16)
                Spacer()
            }
        }
    }
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}

