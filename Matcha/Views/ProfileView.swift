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
    
    var body: some View {
        VStack {
            // profile picture <-- add later if need be
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
                
                //HStack {
                //    Text("Bio:")
                //    TextField("Enter a lil bio...", text: $profileViewModel.bio)
                //        .textFieldStyle(RoundedBorderTextFieldStyle())
                //        .autocapitalization(.none)
                //        .disableAutocorrection(true)
                //        .onChange(of: profileViewModel.bio) { _ in
                //            saved = false
                //        }
                //}
                //.padding()
                //
                //HStack {
                //    Text("Instagram:")
                //    TextField("Enter Instagram handle...", text: $profileViewModel.ig)
                //        .textFieldStyle(RoundedBorderTextFieldStyle())
                //        .autocapitalization(.none)
                //        .disableAutocorrection(true)
                //        .onChange(of: profileViewModel.ig) { _ in
                //            saved = false
                //        }
                //}
                //.padding()
                //
                //HStack {
                //    Text("Snapchat:")
                //    TextField("Enter Snapchat username...", text: $profileViewModel.snap)
                //        .textFieldStyle(RoundedBorderTextFieldStyle())
                //        .autocapitalization(.none)
                //        .disableAutocorrection(true)
                //        .onChange(of: profileViewModel.snap) { _ in
                //            saved = false
                //        }
                //}
                //.padding()
                
                if (!saved) {
                    Button("Save Changes") {
                        profileViewModel.saveProfile(uid: contentViewModel.uid) { success in
                            if success {
                                print("changes saved")
                                saved = true
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
        .onAppear() {
            profileViewModel.fetchProfile(uid: contentViewModel.uid)
        }
        .alert(item: $profileViewModel.alertItem) { alertItem in
            Alert(title: Text(alertItem.title),
                  message: Text(alertItem.message),
                  primaryButton: .cancel(Text("NO")),
                  secondaryButton: .destructive(Text("Delete..."), action: deleteProfile)
            )
        }
    }
    
    func deleteProfile() {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    print("Error deleting user account: \(error.localizedDescription)")
                } else {
                    print("User account deleted successfully.")
                }
            }
        }
        DatabaseManager.shared.deleteUser(uid: contentViewModel.uid) { success in
            if success {
                print("USER DATA DELETED")
            } else {
                print("USER DATA NOT DELETED UH OH!")
            }
        }
        contentViewModel.signOut()
        contentViewModel.loggedIn = false
        contentViewModel.loggingIn = false
        contentViewModel.registering = false
        contentViewModel.uid = ""
    }
}

