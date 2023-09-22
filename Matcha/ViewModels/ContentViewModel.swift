//
//  ContentViewModel.swift
//  Matcha
//
//  Created by Chris Choi on 6/15/23.
//

import Foundation
import SwiftUI
import Firebase

class ContentViewModel: ObservableObject {
    @Published var registering: Bool = false
    @Published var profiling: Bool = false
    @Published var loggingIn: Bool = false
    @Published var loggedIn: Bool = false
    @Published var homeOverride: Bool = false
    @Published var uid: String = ""
    
    @Published var postCall: Bool = false
    @Published var adClicked: Bool = false
    @Published var rewardAd: AdCoordinator = AdCoordinator()
    
    @Published var reporting: Bool = false
    
    // default in past, to not trigger anything.
    @Published var callTime: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        addAuthStateListener()
    }

    private func addAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            self?.loggedIn = (user != nil)
            if (user != nil) {
                self?.uid = user!.uid
            }
        }
    }
    
    // call this when app opens + at needed intervals
    // needs to return a completion thing
    public func updateCallTime() {
        if (uid == "") {
            print("user logged out. not updating calltime")
            return
        }
        DatabaseManager.shared.getCallTime(uid: uid) { time in
            if let time = time {
                self.callTime = time
            } else {
                print("NO CALLTIME FOR THIS GUY!!!")
            }
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
