//
//  ContentView.swift
//  Matcha
//
//  Created by Chris Choi on 6/13/23.
//

import SwiftUI

// Top level view for app
struct ContentView: View {
    @StateObject var contentViewModel: ContentViewModel = ContentViewModel() //top level instance. need to pass this in other into everywhere that affects app directory
    @State var currTime: Date = Date() //move into contentviewmodel?
    @State var home: Bool = true
    @State var profile: Bool = false
    @State var tokenSet: Bool = false
    
    var body: some View {
        // all false: view with login / register options
        // login true, rest false: login view
        // register true, rest false: register view:
        // loggedin true: the regular app and whatnot
        if contentViewModel.loggedIn {
            ZStack {
                // content: home or profile
                if (home && !profile) {
                    // CALL TIME...!!!
                    if (currTime >= contentViewModel.callTime &&
                        currTime <= contentViewModel.callTime.addingTimeInterval(2 * 60)) {
                        CallView().environmentObject(contentViewModel)
                            .onAppear {
                                startTimer()
                                contentViewModel.updateCallTime()
                                
                            }
                    } else {
                        AppHomeView().environmentObject(contentViewModel)
                            .onAppear {
                                startTimer()
                                contentViewModel.updateCallTime()
                            }
                    }
                } else {
                    ProfileView().environmentObject(contentViewModel)
                }
                
                // position + scale these buttons better..!
                if (home && !profile) {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                profile = !profile
                                home = !home
                            }) {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 25))
                                    .padding(.trailing, 10)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                    }
                } else {
                    VStack {
                        HStack {
                            Button(action: {
                                profile = !profile
                                home = !home
                            }) {
                                Image(systemName: "arrowshape.turn.up.left.fill")
                                    .font(.system(size: 25))
                                    .padding(.leading, 10)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        } else {
            // not logged in.
            if contentViewModel.loggingIn {
                ZStack {
                    VStack {
                        HStack {
                            Button(action: {
                                contentViewModel.loggingIn = false
                            }) {
                                Image(systemName: "arrowshape.turn.up.left.fill")
                                    .font(.system(size: 25))
                                    .padding(.leading, 10)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    LoginView().environmentObject(contentViewModel)
                }
            } else if contentViewModel.registering {
                ZStack {
                    VStack {
                        HStack {
                            Button(action: {
                                contentViewModel.registering = false
                            }) {
                                Image(systemName: "arrowshape.turn.up.left.fill")
                                    .font(.system(size: 25))
                                    .padding(.leading, 10)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    RegistrationView().environmentObject(contentViewModel)
                }
            } else {
                StartView().environmentObject(contentViewModel)
                    .onAppear() {
                        home = true
                        profile = false
                    }
            }
        }
    }
    
    
    // need to pause this too, when you log out or something. .invalidate
    // anyway this constantly listens for changes in calltime because it's a very important feature of the app
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            currTime = Date()
            contentViewModel.updateCallTime()
            if (!tokenSet) {
                if (globalDeviceToken != "") {
                    DatabaseManager.shared.setDeviceToken(uid: contentViewModel.uid) { success in
                        if success {
                            print("THE DEVICE TOKEN HAS BEEN SET")
                            tokenSet = true
                        } else {
                            print("THE DEVICE TOKEN HAS NOT BEEN SET UH OH!")
                        }
                    }
                }
            }
        }
    }
}
