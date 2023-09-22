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
                
                if (contentViewModel.uid == "isM1hfTO2ggkbkDa3gUEiCUNnnD2") {
                    Button("MAKE IT MATCH O'CLOCK 🍵") {
                        print("BUTTON PRESSED")
                        
                        guard let url = URL(string: "http://44.224.156.71:8080/match/now") else {
                            print("INVALID URL")
                            return
                        }
                        
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type") //needed?
                        // maybe pass in UID and check on server side.
                        
                        URLSession.shared.dataTask(with: request) { _, response, _ in
                            if let response = response {
                                print("CALL TIME SET TO NOW SUCCESSFULLY IF 200: ", response)
                            }
                        }.resume()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color("matcha"))
                    .cornerRadius(10)
                }
            }
            .padding(.bottom, 100)
        }
    }
}
