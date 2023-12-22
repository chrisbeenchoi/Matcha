//
//  DatabaseManager.swift
//  Matcha
//
//  Created by Chris Choi on 6/14/23.
//

import Foundation
import Firebase
import FirebaseStorage
import SwiftUI

class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    let storage = Storage.storage().reference()
    let serverTimeZone = TimeZone(identifier: "America/Los_Angeles")
    let deviceTimeZone = TimeZone.current
    
    // need to convert from pacific time --> device time to correctly trigger UI changes
    func getCallTime(uid: String, completion: @escaping (Date?) -> Void) {
        let time = database.child("users").child(uid).child("callTime")
        time.observeSingleEvent(of: .value) { snapshot in
            if let timeString = snapshot.value as? String {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                if let serverTime = dateFormatter.date(from: timeString) {
                    //converts time from pacific time to device time
                    let currentDate = Date()
                    let offset1 = self.serverTimeZone!.secondsFromGMT(for: currentDate)
                    let offset2 = self.deviceTimeZone.secondsFromGMT(for: currentDate)
                    completion(serverTime.addingTimeInterval(TimeInterval(offset2-offset1)))
                } else {
                    print("Invalid date format")
                    completion(nil)
                }
            } else {
                print("Couldn't get calltime for user: ", uid)
                completion(nil)
            }
        }
    }
    
    func addUser(uid: String, completion: @escaping (Bool) -> Void) {
        let userRef = database.child("users").child(uid)
        let userData = [
            "firstName": "",
            "callTime": nil,
            "profileStatus": "0"
        ]
        
        userRef.setValue(userData) { (error, databaseRef) in
            if let error = error {
                print("Error writing to database: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User added successfully")
                completion(true)
            }
        }
    }
    
    // Add user to current matching pool
    func matchPrep(uid: String, completion: @escaping (Bool) -> Void) {
        let matchRef = database.child("matchPool").child(uid)
        
        matchRef.setValue(["uid": uid]) { (error, databaseRef) in
            if let error = error {
                print("Error writing to database: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User added successfully to match pool")
                completion(true)
            }
        }
    }
    
    // get channel
    func getChannel(uid: String, completion: @escaping (String?) -> Void) {
        let channel = database.child("users").child(uid).child("matchInfo").child("channel")
        channel.observeSingleEvent(of: .value) { snapshot in
            if let channel = snapshot.value as? String {
                print("channel: \(channel)")
                completion(channel)
            } else {
                print("NO CHANNEL YET...!")
                completion(nil) //will trigger the method to be called again
            }
        }
    }
    
    // get token
    func getToken(uid: String, completion: @escaping (String?) -> Void) {
        let token = database.child("users").child(uid).child("matchInfo").child("token")
        token.observeSingleEvent(of: .value) { snapshot in
            if let token = snapshot.value as? String {
                print("token: \(token)")
                completion(token)
            } else {
                print("NO TOKEN YET...!")
                completion(nil) //will trigger the method to be called again
            }
        }
    }
    
    // get channel uid
    func getChannelUid(uid: String, completion: @escaping (Int?) -> Void) {
        let channelUid = database.child("users").child(uid).child("matchInfo").child("channelUid")
        channelUid.observeSingleEvent(of: .value) { snapshot in
            if let channelUid = snapshot.value as? Int {
                print("channel uid: \(channelUid)")
                completion(channelUid)
            } else {
                print("NO CHANNEL UID YET...!")
                completion(nil) //will trigger the method to be called again
            }
        }
    }
    
    // PROFILE METHODS:
    func setProfile(uid: String, firstName: String, bio: String?, ig: String?, snap: String?, phoneNumber: String?, completion: @escaping (Bool) -> Void) {
        let userRef = database.child("users").child(uid)
        let profileRef = userRef.child("profile")
        
        let profileData = [
            "firstName": firstName,
            "bio": bio,
            "ig": ig,
            "snap": snap,
            "phoneNumber": phoneNumber
        ]
        
        profileRef.setValue(profileData) { (error, databaseRef) in
            if let error = error {
                print("Error writing to database: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Profile set successfully")
                completion(true)
            }
        }
    }
    
    
    // get first name
    func getFirstName(uid: String, completion: @escaping (String?) -> Void) {
        let firstName = database.child("users").child(uid).child("profile").child("firstName")
        firstName.observeSingleEvent(of: .value) { snapshot in
            if let firstName = snapshot.value as? String {
                print("firstName: \(firstName)")
                completion(firstName)
            } else {
                print("NO FIRSTNAME YET...!")
                completion(nil)
            }
        }
    }
    
    // get bio
    func getBio(uid: String, completion: @escaping (String?) -> Void) {
        let bio = database.child("users").child(uid).child("profile").child("bio")
        bio.observeSingleEvent(of: .value) { snapshot in
            if let bio = snapshot.value as? String {
                print("bio: \(bio)")
                completion(bio)
            } else {
                print("NO BIO YET...!")
                completion(nil)
            }
        }
    }

    // get ig
    func getIg(uid: String, completion: @escaping (String?) -> Void) {
        let ig = database.child("users").child(uid).child("profile").child("ig")
        ig.observeSingleEvent(of: .value) { snapshot in
            if let ig = snapshot.value as? String {
                print("ig: \(ig)")
                completion(ig)
            } else {
                print("NO IG YET...!")
                completion(nil)
            }
        }
    }
    
    // get snap
    func getSnap(uid: String, completion: @escaping (String?) -> Void) {
        let snap = database.child("users").child(uid).child("profile").child("snap")
        snap.observeSingleEvent(of: .value) { snapshot in
            if let snap = snapshot.value as? String {
                print("snap: \(snap)")
                completion(snap)
            } else {
                print("NO SNAP YET...!")
                completion(nil)
            }
        }
    }
    
    // get phone number
    func getDigits(uid: String, completion: @escaping (String?) -> Void) {
        let digits = database.child("users").child(uid).child("profile").child("phoneNumber")
        digits.observeSingleEvent(of: .value) { snapshot in
            if let digits = snapshot.value as? String {
                print("digits: \(digits)")
                completion(digits)
            } else {
                print("NO SNAP YET...!")
                completion(nil)
            }
        }
    }
    
    func uploadPfp(uid: String, pfp: UIImage, completion: @escaping (Bool) -> Void) {
        let pfpRef = storage.child("pfps").child("\(uid).jpg")
        if let imageData = pfp.jpegData(compressionQuality: 0.8) {
            pfpRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading profile image: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func fetchPfp(uid: String, completion: @escaping (URL?) -> Void) {
        let pfpRef = storage.child("pfps").child("\(uid).jpg")
        pfpRef.downloadURL { url, error in
            if let url = url {
                print(url)
                completion(url)
            } else if let error = error {
                print(error)
                completion(nil)
            }
        }
    }
    
    func getMatchUid(uid: String, completion: @escaping (String?) -> Void) {
        let matchRef = database.child("users").child(uid).child("matchInfo").child("match")
        matchRef.observeSingleEvent(of: .value) { snapshot in
            if let match = snapshot.value as? String {
                print("match uid: \(match)")
                completion(match)
            } else {
                print("NO MATCH YET...!")
                completion(nil)
            }
        }
    }
    
    func blockUser(blocker: String, blocked: String, completion: @escaping (Bool) -> Void) {
        let blockListRef = database.child("users").child(blocker).child("blocked").child(blocked)
        blockListRef.setValue(blocked) { (error, databaseRef) in
            if let error = error {
                print("Error writing to database: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User successfully written to block list", blocked)
                completion(true)
            }
        }
    }
    
    func unblockUser(blocker: String, blocked: String, completion: @escaping (Bool) -> Void) {
        let blockListRef = database.child("users").child(blocker).child("blocked").child(blocked)
        blockListRef.removeValue() { (error, _) in
            if let error = error {
                print("Error writing to database: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User successfully unblocked", blocked)
                completion(true)
            }
        }
    }
    
    func reportUser(reporter: String, reported: String, violations: [Violation], description: String, completion: @escaping (Bool) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: Date())
        
        var reasons: String = ""
        violations.forEach { violation in
            reasons = reasons + violation.name + " "
        }
        
        let reportData = [
            "timeStamp": formattedDate,
            "reported": reported,
            "violations": reasons,
            "description": description
        ]
        
        let reportRef = database.child("reports").child(formattedDate + ": " + reported)
        reportRef.setValue(reportData) { (error, databaseRef) in
            if let error = error {
                print("Error writing to database: \(error.localizedDescription)")
                completion(false)
            } else {
                print("REPORTED TO DATABASE")
                completion(true)
            }
        }
        
    }
    
    func setDeviceToken(uid: String, completion: @escaping (Bool) -> Void) {
        let dtRef = database.child("users").child(uid).child("deviceToken")
        
        dtRef.setValue(globalDeviceToken) { (error, databaseRef) in
            if let error = error {
                print("Error writing to database: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Device token successfully written to ", uid)
                completion(true)
            }
        }
    }
    
    func removeDeviceToken(uid: String, completion: @escaping (Bool) -> Void) {
        let dtRef = database.child("users").child(uid).child("deviceToken")
        
        dtRef.removeValue() { (error, _) in
            if let error = error {
                print("Error writing to database: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Device token successfully removed for ", uid)
                completion(true)
            }
        }
    }
    
    func getProfileStatus(uid: String, completion: @escaping (Bool) -> Void) {
        let profileStatus = database.child("users").child(uid).child("profileStatus")
        profileStatus.observeSingleEvent(of: .value) { snapshot in
            if let status = snapshot.value as? String {
                print("done? (0 for false, 1 for true): \(status)")
                completion(status == "1")
            } else {
                completion(true)
            }
        }
    }
    
    func setProfileStatus(uid: String, completion: @escaping (Bool) -> Void) {
        let profileStatus = database.child("users").child(uid)
        profileStatus.updateChildValues(["profileStatus": "1"]) { (error, databaseRef) in
            if let error = error {
                print("Error writing to database: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User profile status set successfully")
                completion(true)
            }
        }
        
    }
    
    func deleteUser(uid: String, completion: @escaping (Bool) -> Void) {
        let userRef = database.child("users").child(uid)
        userRef.removeValue() { (error, _) in
            if let error = error {
                print("Error deleting user data: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Data successfully removed for user", uid)
                completion(true)
            }
        }
    }
}
