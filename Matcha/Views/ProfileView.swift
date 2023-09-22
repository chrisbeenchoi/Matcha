//
//  ProfileView.swift
//  Matcha
//
//  Created by Chris Choi on 7/28/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var profileViewModel = ProfileViewModel()
    @State var saved = false
    @State private var isImagePickerPresented = false
    
    var body: some View {
        VStack {
            if let profileImage = profileViewModel.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .onChange(of: profileViewModel.profileImage) { _ in
                        saved = false
                    }
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .foregroundColor(.gray)
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .onChange(of: profileViewModel.profileImage) { _ in
                        saved = false
                    }
            }
            
            //adjust size?
            Button("Select Profile Picture") {
                isImagePickerPresented = true
            }
            
            // adjust spacing. look at login controller and take what it's doing
            VStack(spacing: 15) {
                HStack {
                    Text("First name:")
                    TextField("Enter first name (required)", text: $profileViewModel.firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: profileViewModel.firstName) { _ in
                            saved = false
                        }
                }
                .padding()
                
                HStack {
                    Text("Bio:")
                    TextField("Enter a lil bio...", text: $profileViewModel.bio)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: profileViewModel.bio) { _ in
                            saved = false
                        }
                }
                .padding()
                
                HStack {
                    Text("Instagram:")
                    TextField("Enter Instagram handle...", text: $profileViewModel.ig)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: profileViewModel.ig) { _ in
                            saved = false
                        }
                }
                .padding()
                
                HStack {
                    Text("Snapchat:")
                    TextField("Enter Snapchat username...", text: $profileViewModel.snap)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: profileViewModel.snap) { _ in
                            saved = false
                        }
                }
                .padding()
                
                if (!saved) {
                    Button("Save Changes") {
                        profileViewModel.saveProfile(uid: contentViewModel.uid) { success in
                            if success {
                                print("changes saved")
                                // save image
                                if let pfp = profileViewModel.profileImage {
                                    DatabaseManager.shared.uploadPfp(uid: contentViewModel.uid, pfp: pfp) { success in
                                        if success {
                                            print("pfp saved")
                                            saved = true
                                        } else {
                                            print("pfp NOT saved...!")
                                        }
                                    }
                                } else {
                                    saved = true
                                }
                            } else {
                                print("changes NOT saved...!")
                            }
                        }
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color("matcha"))
                    .cornerRadius(10)
                } else {
                    Button("Changes Saved") {
                        print("nothing to save..!")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .cornerRadius(10)
                }
                
                Button("Logout") {
                    contentViewModel.signOut()
                    contentViewModel.loggedIn = false
                    contentViewModel.loggingIn = false
                    contentViewModel.registering = false
                    DatabaseManager.shared.removeDeviceToken(uid: contentViewModel.uid) { success in
                        if success {
                            print("THE DEVICE TOKEN HAS BEEN REMOVED")
                        } else {
                            print("THE DEVICE TOKEN HAS NOT BEEN REMOVED UH OH!")
                        }
                    }
                    contentViewModel.uid = ""
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10)
                
                Button("Delete Account") {
                    profileViewModel.deleteAlert()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $profileViewModel.profileImage)
        }
        .onAppear() {
            profileViewModel.fetchProfile(uid: contentViewModel.uid)
        }
        .alert(item: $profileViewModel.alertItem) { alertItem in
            if (alertItem.title == "REALLY⁉️") {
                return Alert(title: Text(alertItem.title),
                      message: Text(alertItem.message),
                      primaryButton: .cancel(Text("NO")),
                      secondaryButton: .destructive(Text("Delete..."), action: deleteProfile)
                )
            } else {
                return Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .cancel(Text("Ok")))
            }
        }
    }
    
    func deleteProfile() {
        if let user = Auth.auth().currentUser {
            DatabaseManager.shared.deleteUser(uid: contentViewModel.uid) { success in
                if success {
                    print("USER DATA DELETED")
                    user.delete { error in
                        if let error = error {
                            print("Error deleting user account: \(error.localizedDescription)")
                            profileViewModel.failedDelete()
                        } else {
                            print("User account deleted successfully.")
                            contentViewModel.signOut()
                            contentViewModel.loggedIn = false
                            contentViewModel.loggingIn = false
                            contentViewModel.registering = false
                            contentViewModel.uid = ""
                        }
                    }
                } else {
                    print("USER DATA NOT DELETED UH OH!")
                }
            }
        }
    }
}

