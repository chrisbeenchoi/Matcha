//
//  LoginView.swift
//  Matcha
//
//  Created by Chris Choi on 6/19/23.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var loginViewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .cornerRadius(20)
            
            VStack(spacing: 15) {
                TextField("Email", text: $loginViewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("Password", text: $loginViewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            // login processing is a little slow. add wheel
            Button("Login") {
                loginViewModel.loginUser { uid in
                    if let uid = uid {
                        contentViewModel.loggedIn = true
                        contentViewModel.uid = uid
                        DatabaseManager.shared.setDeviceToken(uid: uid) { success in
                            if success {
                                print("THE DEVICE TOKEN HAS BEEN SET")
                            } else {
                                print("THE DEVICE TOKEN HAS NOT BEEN SET UH OH!")
                            }
                        }
                    }
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color("matcha"))
            .cornerRadius(10)
        }
        .padding(.bottom, 75)
        .alert(item: $loginViewModel.alertItem) { alertItem in
            Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .default(Text("Yes")))
        }
    }
}
