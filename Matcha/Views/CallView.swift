//
//  CallView.swift
//  Matcha
//
//  Created by Chris Choi on 6/15/23.
//

import SwiftUI
import AgoraUIKit

// separate functions out into callviewmodel?
struct CallView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @State var joined: Bool = false
    @State var loading: Bool = false
    
    @State var channel: String = ""
    @State var token: String = ""
    @State var channelUid: UInt = 0
    
    @State var callScreen: AgoraVideoViewerWrapper? = nil
    
    //turn time left into a state variable to make ui update reactively?
    private let countdown = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func joinChannel() {
        // refetch by default?
        var channelFetched = false //(channel == "")
        var tokenFetched = false //(token == "")
        var channelUidFetched = false //(channelUid == 0)
        
        func checkCompletion() {
            if channelFetched && tokenFetched && channelUidFetched {
                print(self.channel)
                print(self.token)
                print(self.channelUid)
                loading = false
                self.joined = true
                self.callScreen = AgoraVideoViewerWrapper(channel: self.channel, token: self.token, uid: self.channelUid, endTime: contentViewModel.callTime.addingTimeInterval(119))
            }
        }
        
        func fetchChannel() {
            DatabaseManager.shared.getChannel(uid: contentViewModel.uid) { channel in
                if let channel = channel {
                    self.channel = channel
                    channelFetched = true
                    checkCompletion()
                } else {
                    // Channel not found, wait and retry
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        fetchChannel()
                    }
                }
            }
        }
        
        func fetchToken() {
            DatabaseManager.shared.getToken(uid: contentViewModel.uid) { token in
                if let token = token {
                    self.token = token
                    tokenFetched = true
                    checkCompletion()
                } else {
                    // Token not found, wait and retry
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        fetchToken()
                    }
                }
            }
        }
        
        func fetchChannelUid() {
            DatabaseManager.shared.getChannelUid(uid: contentViewModel.uid) { channelUid in
                if let channelUid = channelUid {
                    self.channelUid = UInt(channelUid)
                    channelUidFetched = true
                    checkCompletion()
                } else {
                    // Channel UID not found, wait and retry
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        fetchChannelUid()
                    }
                }
            }
        }
        
        fetchChannel()
        fetchToken()
        fetchChannelUid()
    }
    
    private func timeString(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        if (minutes <= 0 && seconds <= 0) {
            return String("00:00")
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            if (loading) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            VStack {
                Text(timeString(120 - Int(Date().timeIntervalSince(contentViewModel.callTime).rounded())))
                    .onReceive(countdown) { _ in
                        if 120 - Int(Date().timeIntervalSince(contentViewModel.callTime).rounded()) <= 0 {
                            self.joined = false
                            self.channel = ""
                            self.token = ""
                            self.channelUid = 0
                        }
                    }
                    .font(.system(size: 80, weight: .bold))
                    .padding(.top, 50)
                
                Spacer()
            }
            
            if joined {
                ZStack {
                    
                    VStack {
                        Spacer()
                        Button("Leave") {
                            // you can rejoin the same call but not a new one
                            joined = false
                            callScreen?.endCall()
                            
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.bottom, 45)
                    }
                    
                    callScreen
                        .frame(width: 300, height: 500)
                        .cornerRadius(30)
                        .padding(.top, 15)
                }
            }
            if !joined {
                VStack {
                    Text("CURRENT TIME: MATCH O'CLOCK 🍵")
                    
                    Button("Join") {
                        if (!loading) {
                            loading = true
                            if (self.channel != "" && self.token != "" && self.channelUid != 0) {
                                self.joinChannel()
                            } else {
                                DatabaseManager.shared.matchPrep(uid: contentViewModel.uid) { success in
                                    if success {
                                        print("SUCCESS.")
                                        self.joinChannel()
                                    } else {
                                        print("FAILED TO JOIN MATCH POOL") ///alert user to try again? probably should
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color("matcha"))
                    .cornerRadius(10)
                }
                .padding(.bottom, 120)
            }
        }
    }
}
