//
//  ProfileCreationViewModel.swift
//  Matcha
//
//  Created by Chris Choi on 8/31/23.
//

import Foundation
import SwiftUI

class ProfileCreationViewModel: ObservableObject {
    @Published var profileImage: UIImage? = nil
    @Published var firstName: String = ""
    @Published var bio: String = ""
    @Published var ig: String = ""
    @Published var snap: String = ""
    @Published var phoneNumber: String = ""
    @Published var alertItem: AlertItem?
    
    func createProfile(uid: String, completion: @escaping (Bool) -> Void) {
        
        // check first name (required)
        if firstName == "" {
            alertItem = AlertItem(title: "First name required!", message: "Please enter a first name.")
            completion(false)
            return
        }
        
        // check ig: letters, periods, numbers, or underscores. less than 30 characters
        
        // check snap: letters, numbers, one of these: ._- and 3-15 characters
        
        // phone number check: ignore separators oh wait no you can only put numbers in there lol.
        // ig leave some room for the
        
        // check if at least one contact method selected, and if phone number valid
        if ig == "" && snap == "" && !isValidPhoneNumber(phoneNumber) {
            alertItem = AlertItem(title: "At least one contact method required!", message: "Please enter at least one valid contact method.")
            completion(false)
            return
        }
        
        DatabaseManager.shared.setProfile(uid: uid, firstName: firstName, bio: bio, ig: ig, snap: snap, phoneNumber: phoneNumber) { success in
            if success {
                // set pfp here or out there idfk
                print("PROFILE CREATED")
                completion(true)
            } else {
                print("PROFILE DIDNT CREATE..!")
                completion(false)
            }
        }
        
        // set profile + pfp using database methods.
        // adjust database set + fetch funcs to include phone number
        
        // return completion 
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // dashes?
        let phoneNumberRegex = #"^\d{10}$"#
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
}
