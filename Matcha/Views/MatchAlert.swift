//
//  MatchAlert.swift
//  Matcha
//
//  Created by Chris Choi on 9/2/23.
//

import Foundation
import SwiftUI

//TODO: make sheet undismissable EXCEPT for with buttons. is this possible???

struct MatchAlert: View {
    @Binding var isPresented: Bool
    @Binding var accepted: Bool
    @Binding var blocked: Bool
    @State var matchUid: String //need to pass in from higher level
    @State var pfp: UIImage?
    @State var firstName: String?
    @State var bio: String?
    
    // init calls over and over. minimize?
    init(matchUid: String, isPresented: Binding<Bool>, accepted: Binding<Bool>, blocked: Binding<Bool>) {
        self.matchUid = matchUid
        _isPresented = isPresented
        _accepted = accepted
        _blocked = blocked
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            
            // Block / Report
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        print("user block / report selected")
                        blocked = true
                        isPresented = false
                    }) {
                        Image(systemName: "person.crop.circle.badge.xmark.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.gray)
                            .padding()
                    }
                }
                Spacer()
            }
            
            VStack {
                if let pfp = self.pfp {
                    Image(uiImage: pfp)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .foregroundColor(.gray)
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                }
                
                // first
                Text(firstName ?? "User")
                    .font(.title)
                    .bold()
                
                Text(bio ?? "I'm a user lol")
                
                // less space here
                
                HStack {
                    // spacers, padding with good insets to push to appropriate locations
                    
                    // buttons: accept / decline call, need to communicate decision with callview
                    
                    Button(action: {
                        print("call accept selected")
                        isPresented = false
                        accepted = true
                    }) {
                        Image(systemName: "phone.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("matcha"))
                            .padding()
                    }
                    
                    Button(action: {
                        print("call decline selected")
                        isPresented = false
                        accepted = false
                    }) {
                        Image(systemName: "phone.down.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color.gray)
                            .padding()
                    }
                }
                
            }
            .onAppear() {
                fetchMatch(uid: matchUid)
            }
        }
    }
    
    func fetchMatch(uid: String) {
        DatabaseManager.shared.fetchPfp(uid: uid) { url in
            if let url = url {
                URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.pfp = image
                            }
                        }
                }.resume()
            } else {
                self.pfp = nil
            }
        }
        DatabaseManager.shared.getFirstName(uid: uid) { name in
            if let name = name {
                self.firstName = name
            }
        }
        DatabaseManager.shared.getBio(uid: uid) { bio in
            if let bio = bio {
                self.bio = bio
            }
        }
    }
}
