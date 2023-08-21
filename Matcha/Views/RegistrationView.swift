//
//  RegistrationView.swift
//  Matcha
//
//  Created by Chris Choi on 6/14/23.
//

import Foundation
import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var registrationViewModel = RegistrationViewModel()
    
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .cornerRadius(20)
            
            TextField("First Name", text: $registrationViewModel.firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
            
            TextField("Email", text: $registrationViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
            
            SecureField("Password", text: $registrationViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // registration processing is a little slow. add a wheel later?
            Button("Register") {
                registrationViewModel.registerUser { uid in
                    if let uid = uid {
                        contentViewModel.loggedIn = true
                        contentViewModel.uid = uid
                    }
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color("matcha"))
            .cornerRadius(10)
        }
        .padding()
        .alert(item: $registrationViewModel.alertItem) { alertItem in
            Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
        }
    }
}
