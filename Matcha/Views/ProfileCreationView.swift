//
//  ProfileCreationView.swift
//  Matcha
//
//  Created by Chris Choi on 8/31/23.
//

import Foundation
import SwiftUI

struct ProfileCreationView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var profileCreationViewModel = ProfileCreationViewModel()
    @State private var isImagePickerPresented = false
    
    var body: some View {
        VStack {
            // pfp selection
            if let profileImage = profileCreationViewModel.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .foregroundColor(.gray)
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
            }
            
            Button("Select Profile Picture") {
                isImagePickerPresented = true
            }
            
            VStack(spacing: 15) {
                TextField("First name", text: $profileCreationViewModel.firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Bio", text: $profileCreationViewModel.bio)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Instagram", text: $profileCreationViewModel.ig)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                TextField("Snapchat", text: $profileCreationViewModel.snap)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                // make this a number keypad type operation
                TextField("Phone number", text: $profileCreationViewModel.phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: profileCreationViewModel.phoneNumber) { newValue in
                        profileCreationViewModel.phoneNumber = newValue.filter { "0123456789".contains($0) }
                                }
            }
            .padding()
            
            Button("Save Profile") {
                // iff successful, edit top level navigation to home screen
                profileCreationViewModel.createProfile(uid: contentViewModel.uid) { success in
                    if success {
                        print("profile created")
                        DatabaseManager.shared.setProfileStatus(uid: contentViewModel.uid) { success in
                            if success {
                                contentViewModel.profiling = false
                                contentViewModel.loggedIn = true
                            }
                        }
                        if let pfp = profileCreationViewModel.profileImage {
                            DatabaseManager.shared.uploadPfp(uid: contentViewModel.uid, pfp: pfp) { success in 
                                if success {
                                    print("pfp initialized")
                                } else {
                                    print("pfp NOT initialized")
                                }
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
        .padding()
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $profileCreationViewModel.profileImage)
        }
        .alert(item: $profileCreationViewModel.alertItem) { alertItem in
            Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
        }
    }
}
