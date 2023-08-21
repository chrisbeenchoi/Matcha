//
//  LoginViewModel.swift
//  Matcha
//
//  Created by Chris Choi on 6/16/23.
//

import Foundation
import Firebase
import CryptoKit
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var alertItem: AlertItem?
    
    // Logs in user, returns whether it succeeded
    func loginUser(completion: @escaping (String?) -> Void) {
        // Check if email address valid
        if !isValidEmail(email: email) {
            alertItem = AlertItem(title: "Invalid email!", message: "Enter a valid email address.")
            completion(nil)
            return
        }
        
        let encrypted = encryptPassword(password)
        if let pw = encrypted {
            Auth.auth().signIn(withEmail: email, password: pw) { (authResult, error) in
                if let error = error as NSError? {
                    self.alertItem = AlertItem(title: "Login unsuccessful!", message: "Make sure your email and password are correct.")
                    print(error)
                    completion(nil)
                } else if let user = authResult?.user {
                    let uid = user.uid
                    print("SUCCESS.")
                    completion(uid)
                } else {
                    completion(nil)
                }
            }
        } else {
            print("ENCYRPTION ISSUES")
            alertItem = AlertItem(title: "Login unsuccessful!", message: "Make sure your email and password are correct.")
            completion(nil)
        }
    }
    
    // Checks whether email format valid
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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
