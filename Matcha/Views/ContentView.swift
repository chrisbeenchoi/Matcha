//
//  ContentView.swift
//  Matcha
//
//  Created by Chris Choi on 6/13/23.
//

import SwiftUI

// Top level view for app
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var contentViewModel: ContentViewModel = ContentViewModel() //top level instance. need to pass this in other into everywhere that affects app directory
    @State var currTime: Date = Date() //move into contentviewmodel?
    @State var home: Bool = true
    @State var profile: Bool = false
    @State var tokenSet: Bool = false
    
    @State var postCallTriggered: Bool = false
    
    var body: some View {
        if contentViewModel.loggedIn {
            ZStack {
                // content: home or profile
                if contentViewModel.profiling {
                    ProfileCreationView()
                        .environmentObject(contentViewModel)
                } else if (home && !profile) {
                    if (contentViewModel.homeOverride) {
                        AppHomeView().environmentObject(contentViewModel)
                            .onAppear {
                                startTimer()
                                contentViewModel.updateCallTime()
                                DatabaseManager.shared.getProfileStatus(uid: contentViewModel.uid) { done in
                                    if !done {
                                        contentViewModel.profiling = true
                                    } else {
                                        contentViewModel.profiling = false
                                    }
                                }
                            }
                    } else if (contentViewModel.reporting) {
                        ReportView().environmentObject(contentViewModel)
                    } else if (currTime >= contentViewModel.callTime &&
                        currTime <= contentViewModel.callTime.addingTimeInterval(2 * 60)) {
                        CallView().environmentObject(contentViewModel)
                            .onAppear {
                                startTimer()
                                contentViewModel.updateCallTime()
                            }
                    } // this is not quite working correctly. i believe there is a variable that needs to be tracked to reload this little window  - currently not 
                    else if (contentViewModel.postCall && (contentViewModel.adClicked ||
                               (currTime >= contentViewModel.callTime.addingTimeInterval(2 * 60) &&
                                currTime <= contentViewModel.callTime.addingTimeInterval(2 * 60 + 15)))) {
                        PostCallView().environmentObject(contentViewModel)
                            .onAppear {
                                contentViewModel.rewardAd.loadAd()
                                startTimer()
                                contentViewModel.updateCallTime()
                            }
                    } else {
                        AppHomeView().environmentObject(contentViewModel)
                            .onAppear {
                                startTimer()
                                contentViewModel.updateCallTime()
                                DatabaseManager.shared.getProfileStatus(uid: contentViewModel.uid) { done in
                                    if !done {
                                        contentViewModel.profiling = true
                                    }
                                }
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
            .onChange(of: scenePhase) { newScenePhase in
                if newScenePhase == .active {
                    contentViewModel.updateCallTime()
                    print("App entered the foreground")
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
            } else if contentViewModel.profiling {
                ProfileCreationView()
                    .environmentObject(contentViewModel)
            } else {
                StartView().environmentObject(contentViewModel)
                    .onAppear() {
                        home = true
                        profile = false
                    }
            }
        }
    }
    
    //could definitely fetch calltime less frequently.
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            currTime = Date()
            
            if (contentViewModel.homeOverride && currTime >= contentViewModel.callTime.addingTimeInterval(135)) {
                contentViewModel.homeOverride = false
            }
            
            if (currTime >= contentViewModel.callTime.addingTimeInterval(2 * 60) &&
                currTime <= contentViewModel.callTime.addingTimeInterval(2 * 60 + 10) &&
                !postCallTriggered && !contentViewModel.postCall) {
                contentViewModel.postCall = true
                postCallTriggered = true
            }
            
            // restore this with any issues
            contentViewModel.updateCallTime()
            
            if (!tokenSet) {
                if (globalDeviceToken != "") {
                    DatabaseManager.shared.setDeviceToken(uid: contentViewModel.uid) { success in
                        if success {
                            print("THE DEVICE TOKEN HAS BEEN SET")
                            tokenSet = true
                        } else {
                            print("THE DEVICE TOKEN HAS NOT BEEN SET UH OH!")
                            tokenSet = false
                        }
                    }
                }
            }
        }
    }
}
