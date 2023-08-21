//
//  MatchaApp.swift
//  Matcha
//
//  Created by Chris Choi on 6/13/23.
//

import SwiftUI
import FirebaseCore
import Firebase

var globalDeviceToken: String = ""

@main
struct MatchaApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var configureState = ConfigureState.shared
    
    init() {
        configureFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            if (!ConfigureState.shared.configured) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                ContentView()
            }
        }
    }
    
    // some things (2) about this must be in the main thread.
    // wrap everything in dispatchqueue.main bruh idk
    func configureFirebase() {
        print("STARTING TO CONFIGURE FIREBASE...")
        
        guard let url = URL(string: "http://44.224.156.71:8080/api/firebase") else {
            print("INVALID URL")
            return
        }
        
        print("url:", url)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let config = try decoder.decode(FirebaseConfig.self, from: data)
                    print(config)
                    let options = FirebaseOptions(googleAppID: config.appID, gcmSenderID: config.senderID)
                    options.apiKey = config.apiKey
                    options.projectID = config.projectID
                    options.databaseURL = "https://matcha-5f2b0-default-rtdb.firebaseio.com"
                    FirebaseApp.configure(options: options)
                    DispatchQueue.main.async {
                        print("TURNING CONFIGURED TRUE")
                        ConfigureState.shared.configured = true
                        print("configured:", ConfigureState.shared.configured)
                    }
                    print("app configured.")
                } catch {
                    print("JSON decoding or Firebase configuration error: \(error)")
                }
            } else {
                print("CREDENTIAL FETCH FAILED")
            }
        }.resume()
    }
}

struct FirebaseConfig: Codable {
    let appID: String
    let senderID: String
    let apiKey: String
    let projectID: String
}

class ConfigureState: ObservableObject {
    static let shared = ConfigureState()
    
    @Published var configured: Bool = false
}
