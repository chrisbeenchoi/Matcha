//
//  ProfileViewModel.swift
//  Matcha
//
//  Created by Chris Choi on 7/29/23.
//

import Foundation
import Firebase
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var bio: String = ""
    @Published var ig: String = ""
    @Published var snap: String = ""
    @Published var phoneNumber: String = ""
    @Published var alertItem: AlertItem?
    @Published var profileImage: UIImage?
    
    func fetchProfile(uid: String) {
        DatabaseManager.shared.getFirstName(uid: uid) { name in
            if let name = name {
                self.firstName = name
            } else {
                self.firstName = ""
            }
        }
        DatabaseManager.shared.getBio(uid: uid) { bio in
            if let bio = bio {
                self.bio = bio
            } else {
                self.bio = ""
            }
        }
        DatabaseManager.shared.getIg(uid: uid) { ig in
            if let ig = ig {
                self.ig = ig
            } else {
                self.ig = ""
            }
        }
        DatabaseManager.shared.getSnap(uid: uid) { snap in
            if let snap = snap {
                self.snap = snap
            } else {
                self.snap = ""
            }
        }
        DatabaseManager.shared.fetchPfp(uid: uid) { url in
            if let url = url {
                URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.profileImage = image
                            }
                        }
                }.resume()
            } else {
                self.profileImage = nil
            }
        }
    }
    
    // method to save everything by calling a database thing
    func saveProfile(uid: String, completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.setProfile(uid: uid, firstName: self.firstName, bio: self.bio, ig: self.ig, snap: self.snap, phoneNumber: self.phoneNumber) { success in
            if success {
                print("PROFILE SAVE SUCCESS.")
                completion(true)
            } else {
                print("PROFILE DIDNT SAVE..!")
                completion(false)
            }
        }
    }
    
    func deleteAlert() {
        alertItem = AlertItem(
            title: "REALLY⁉️",
            message: "Account deletion is permanent."
        )
    }
    
    func failedDelete() {
        alertItem = AlertItem(
            title: "Failed to delete account - expired login",
            message: "Log out and log in again to try again"
        )
    }
}
