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
    @Published var alertItem: AlertItem?
    
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
    }
    
    // method to save everything by calling a database thing
    func saveProfile(uid: String, completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.setProfile(uid: uid, firstName: self.firstName, bio: self.bio, ig: self.ig, snap: self.snap) { success in
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
}
