//
//  Admin.swift
//  SmartSoln
//
//  Created by Abhishek Jadaun on 14/03/24.
//

import SwiftUI
import FirebaseDatabase

struct AllCustomerUser {
    var name: String
    var fatherName: String
    var gender: String
    var age: String
    var address: String
    var aadharNumber: String
}

class AllCustomerViewModel: ObservableObject {
    @Published var users = [AllCustomerUser]()
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        let databaseRef = Database.database().reference().child("customer/profile")
        
        databaseRef.observe(.value) { snapshot in
            var customers = [AllCustomerUser]()
            
            for case let childSnapshot as DataSnapshot in snapshot.children {
                if let userData = childSnapshot.value as? [String: Any] {
                    if let name = userData["name"] as? String,
                       let fatherName = userData["fatherName"] as? String,
                       let gender = userData["gender"] as? String,
                       let age = userData["age"] as? String,
                       let address = userData["address"] as? String,
                       let aadharNumber = userData["aadharNumber"] as? String {
                        
                        let user = AllCustomerUser(
                            name: name,
                            fatherName: fatherName,
                            gender: gender,
                            age: age,
                            address: address,
                            aadharNumber: aadharNumber
                        )
                        
                        customers.append(user)
                    }
                }
            }
            
            self.users = customers
        }
    }
}


struct AdminView: View {
    
    @ObservedObject private var viewModel = AllCustomerViewModel()
    
    var body: some View {
        ZStack {
            Color("BgColor").edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView {
                    ForEach(viewModel.users.indices, id: \.self) { i in
                        // Your Doctor UI view here
                        // Customize as needed with doctor data
                        CustomerCard(customerDetails: viewModel.users[i])
                            .padding(.top)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            Spacer()
        }
    }
}


struct CustomerCard: View {
    var customerDetails: AllCustomerUser
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
            
            VStack {
                HStack {
                    Image(systemName: "person.fill") // Replace "doctorImage" with the actual image name
                        .font(.largeTitle)
                        .cornerRadius(8)
                        .padding([.leading, .trailing])
                        .padding([.leading, .trailing])
                    
                    VStack(alignment: .leading) {
                        Text(customerDetails.name)
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(.top)
                        Text(customerDetails.fatherName)
                            .font(.callout)
                            .foregroundColor(.gray)
                        Text(customerDetails.gender)
                            .font(.callout)
                            .foregroundColor(.gray)
                        Text(customerDetails.age)
                            .font(.callout)
                            .foregroundColor(.gray)
                        Text(customerDetails.address)
                            .font(.callout)
                            .foregroundColor(.gray)
                        Text(customerDetails.aadharNumber)
                            .font(.callout)
                            .foregroundColor(.gray)
                            .padding(.bottom)
                    }
                }
                HStack {
                    Text("Approve")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(8)
                        .background(Color.green.opacity(0.4))
                        .cornerRadius(10)
                    
                    Text("Reject")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(8)
                        .background(Color.red.opacity(0.4))
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
        }
        .padding([.leading, .trailing])
    }
}

#Preview {
    AdminView()
}
