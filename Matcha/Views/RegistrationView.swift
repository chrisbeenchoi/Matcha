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
            
            VStack(spacing: 15) {
                TextField("Email", text: $registrationViewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("Password", text: $registrationViewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            // make this look a lot better
            Toggle("I have read and agreed to the Matcha EULA.", isOn: $registrationViewModel.eulaChecked)
                .padding()
            
            Text("End-User License Agreement")
                .foregroundColor(.blue)
                .underline()
                .onTapGesture {
                    if let url = URL(string: "https://docs.google.com/document/d/1w6SFxb2DQ4eVapiQ_Ys0ZRglvMz3EGUw2B43Zf7YVGE/edit?usp=sharing") {
                        UIApplication.shared.open(url)
                    }
                }
                .padding()
            
            // registration processing is a little slow. add a wheel later?
            Button("Register") {
                registrationViewModel.registerUser { uid in
                    if let uid = uid {
                        contentViewModel.registering = false
                        contentViewModel.profiling = true
                        contentViewModel.loggedIn = false
                        contentViewModel.uid = uid
                    }
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color("matcha"))
            .cornerRadius(10)
        }
        .padding(.bottom, 75)
        .alert(item: $registrationViewModel.alertItem) { alertItem in
            Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
        }
    }
}
