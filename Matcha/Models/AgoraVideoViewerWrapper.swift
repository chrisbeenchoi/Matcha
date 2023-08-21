//
//  AgoraViewerHelper.swift
//  Matcha
//
//  Created by Chris Choi on 6/24/23.
//

import AgoraUIKit
import SwiftUI

// needed to integrate UIKit view into SwiftUI view hierarchy
struct AgoraVideoViewerWrapper: UIViewRepresentable {
    typealias UIViewType = AgoraVideoViewer
    
    let channel: String
    let token: String
    let channelUid: UInt
    let endTime: Date
    let agView: AgoraVideoViewer
    var agSettings = AgoraSettings()
    
    init(channel: String, token: String, uid: UInt, endTime: Date) {
        self.channel = channel
        self.token = token
        self.channelUid = uid
        self.endTime = endTime
        
        // configure stuff - make everything look less boxy
        self.agSettings.enabledButtons = []
        
        self.agView = AgoraVideoViewer(
            connectionData: AgoraConnectionData(
                appId: "66e6f5baf5c445788f9d065f86b1deba"
            ),
            style: .floating, //deprecated
            agoraSettings: agSettings,
            delegate: nil //likely unnecessary
        )
    }
    
    func makeUIView(context: Context) -> AgoraVideoViewer {
        print("MAKEUIVIEW CALLED")
        agView.join(channel: self.channel, with: self.token, uid: self.channelUid)
        return agView
    }
    
    func updateUIView(_ uiView: AgoraVideoViewer, context: Context) {
        print("updateUIview called at ", Date())
        if (Date() >= self.endTime) {
            agView.exit(stopPreview: true)
            print("SHOULD BE EXITED")
        }
    }
    
    // need to be able to call this from somewhere else. if too difficult i will not have this
    func endCall() {
        print("user ended call.")
        agView.exit(stopPreview: true)
    }
}
