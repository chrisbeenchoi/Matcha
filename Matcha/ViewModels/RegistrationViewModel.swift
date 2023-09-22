//
//  RegistrationViewModel.swift
//  Matcha
//
//  Created by Chris Choi on 6/14/23.
//

import Foundation
import Firebase
import CryptoKit
import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

class RegistrationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var alertItem: AlertItem?
    @Published var eulaChecked: Bool = false
    
    // Registers user to database, returns whether it succeeded
    func registerUser(completion: @escaping (String?) -> Void) {
        
        // Check if email address valid
        if !isValidEmail(email: email) {
            alertItem = AlertItem(title: "Invalid email!", message: "Enter a valid email address.")
            completion(nil)
            return
        }
        
        // Checks if password format valid (8-50 chars with a number & symbol)
        if !isValidPassword(password: password) {
            alertItem = AlertItem(title: "Invalid password!", message: "Passwords must be 8-50 characters and include a number and symbol.")
            completion(nil)
            return
        }
        
        if !eulaChecked {
            alertItem = AlertItem(title: "EULA unchecked!", message: "To register, please agree to the end-user license agreement!")
            completion(nil)
            return
        }
        
        let encrypted = encryptPassword(password)
        if let pw = encrypted {
            Auth.auth().createUser(withEmail: email, password: pw) { (authResult, error) in
                if let error = error as NSError? {
                    if error.code == 17007 {
                        self.alertItem = AlertItem(title: "Invalid email!", message: "This email address is already in use.")
                    }
                    print(error)
                    completion(nil)
                } else if let user = authResult?.user {
                    let uid = user.uid
                    DatabaseManager.shared.addUser(uid: uid) { success in
                        if success {
                            print("SUCCESS.")
                            completion(uid)
                        } else {
                            completion(uid)
                        }
                    }
                } else {
                    completion(nil)
                }
            }
        } else {
            alertItem = AlertItem(title: "Registration unsuccessful!", message: "Try a different password.")
            completion(nil)
        }
    }
    
    // Checks whether email format valid
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Checks whether password format valid (8-50 chars with a number & symbol)
    func isValidPassword(password: String) -> Bool {
        if password.count < 8 || password.count > 50 {
            return false
        }
        let numberRegex = ".*\\d.*"
        let symbolRegex = ".*[!@#\\$%^&*\\(\\)\\-=_+\\[\\]{};:'\"\\\\\\|,\\.<>/?`~].*"
        // !@#$%^&*()-=_+[]{};:'"\|,,<>/?`~  --> add a few more accessible on apple keyboard?
        let hasNumber = NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: password)
        let hasSymbol = NSPredicate(format: "SELF MATCHES %@", symbolRegex).evaluate(with: password)
        return hasNumber && hasSymbol
    }
    
    // Encrypts password using CryptoKit, returns nil value if unsuccessful
    func encryptPassword(_ password: String) -> String? {
        guard let passwordData = password.data(using: .utf8) else {
            return nil
        }
        
        let hashed = SHA256.hash(data: passwordData)
        let hashedString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        
        return hashedString
    }
}
