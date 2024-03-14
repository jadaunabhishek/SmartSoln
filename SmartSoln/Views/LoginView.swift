//
//  LoginView.swift
//  SmartSoln
//
//  Created by Abhishek Jadaun on 14/03/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var shouldNavigate: Bool = false
    @State private var shouldNavigateAdmin: Bool = false
    
    var body: some View {
        ZStack {
            Color("BgColor").edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                VStack {
                    
                    Image("AppLogo")
                        .resizable()
                        .frame(width: 60, height: 80, alignment: .center)
                    
                    Text("Log In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 30)
                    
                    TextField("Email Id", text: $email)
                        .font(.title3)
                        .padding(12)
                        .autocapitalization(.none)
                        .foregroundColor(Color("TextColor"))
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 5)
                        .padding(.bottom, 5)
                        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    SecureField("Password", text: $password)
                        .font(.title3)
                        .padding(12)
                        .autocapitalization(.none)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 5)
                        .padding(.bottom, 5)
                        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Text("Forgot your password?")
                        .font(.caption)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                        .padding()
                    
                    Button(action: {
                        if email == "abhishek@gmail.com", password == "abhishekjadaun" {
                            shouldNavigateAdmin = true
                        }
                        else {
                            if !email.isEmpty, !password.isEmpty {
                                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                                    if let error = error {
                                        // Handle the login error
                                        print("Error loggin in: \(error.localizedDescription)")
                                    } else {
                                        // If login is successful, navigate to UserFirstView
                                        print("Login successful!")
                                        UserDefaults.standard.set(true, forKey: "emailLoggedIn")
                                        shouldNavigate = true
                                    }
                                }
                            }
                        }
                    }) {
                        Text("Log In")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("PrimaryColor"))
                            .cornerRadius(50)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                    .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    NavigationLink("", destination: HomeScreenView(), isActive: $shouldNavigate)
                        .hidden() // Hide the navigation link
                    
                    NavigationLink("", destination: AdminView(), isActive: $shouldNavigateAdmin)
                        .hidden() // Hide the navigation link
                    
                    
                }.padding()
                
                Spacer()
                
                HStack{
                    Text("Already have an account?")
                    NavigationLink(destination: SignUpView()){
                        Text("SIGN UP")
                            .foregroundColor(Color("PrimaryColor"))
                    }
                }
                .padding([.leading, .trailing, .top])
                .navigationBarHidden(true)
                
            }
        }
    }
}

#Preview {
    LoginView()
}
