//
//  CallView.swift
//  Matcha
//
//  Created by Chris Choi on 7/8/23.
//

//potentially just get rid of this file + toggle join button with a variable

import SwiftUI
import UserNotifications

struct AppHomeView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    var uid: String = ""
    
    var body: some View {
        VStack {
            VStack {
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .cornerRadius(20)
                    .padding()
                
                Text("CURRENT TIME: NOT MATCH O'CLOCK ☕")
            }
            .padding(.bottom, 100)
        }
    }
}
