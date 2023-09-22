//
//  PostCallView.swift
//  Matcha
//
//  Created by Chris Choi on 9/13/23.
//

import Foundation
import SwiftUI

struct PostCallView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @State var matchUid: String = "" //fetch this asap...!!!
    
    // do this like match alert
    @State var firstName: String = ""
    @State var pfp: UIImage? = nil
    
    @State var rewarded: Bool = false
    
    @State var ig: String = ""
    @State var snap: String = ""
    @State var phoneNumber: String = ""
    
    // make a timer
    // this will be very similar to callview.
    //   - need to be able to report from here too. add that sheet which should be done exactly the same way but with more options (add a boolean into the reportalert thing)
    //   - the way you are doing this unfortunately makes the ad load more slowly (tkaes a until you figure out how to do it at initialization and keep it before it reforms.. add a wheel or figure out how to run it earlier.

    private func timeString(_ seconds: Int) -> String {
        if (seconds <= 0) {
            return String("00:00")
        }
        return String(format: "00:%02d", seconds)
    }
    
    var body: some View {
        ZStack {
            
            VStack {
                HStack {
                    Button(action: {
                        print("user block / report selected")
                        DatabaseManager.shared.blockUser(blocker: contentViewModel.uid, blocked: matchUid) { blocked in
                            if blocked {
                                contentViewModel.reporting = true
                            }
                        }
                    }) {
                        Image(systemName: "person.crop.circle.badge.xmark.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.gray)
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
            }
            
            VStack {
                Text(timeString(135 - Int(Date().timeIntervalSince(contentViewModel.callTime).rounded())))
                    .font(.system(size: 80, weight: .bold))
                    .padding(.top, 50)
                
                Spacer()
            }
            
            if !rewarded {
                VStack {
                    
                    // buttons - iconize, layout later
                    Button("🎥 Keep in touch with \(firstName)") {
                        contentViewModel.adClicked = true
                        
                        contentViewModel.rewardAd.presentAd(rewardFunction: {
                            print("Ad done and shyt")
                            rewarded = true
                            // should have fetched profile ... find out how to do this while ad playing?
                        })
                        
                        // does the reward only happen if you FINISH the ad?
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color("matcha"))
                    .cornerRadius(10)
                    
                    Button("Nah") {
                        contentViewModel.postCall = false
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
                    
                }
            } else {
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
                    
                    //need small padding between these, if any.
                    if (ig != "") {
                        Text("IG: @\(ig)")
                    }
                    
                    if (snap != "") {
                        Text("SNAP: @\(snap)")
                    }
                        
                    if (phoneNumber != "") {
                        Text("DIGITS: \(phoneNumber)")
                    }
                    
                    Button("Got it.") {
                        contentViewModel.postCall = false
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color("matcha"))
                    .cornerRadius(10)
                    
                }
                
            }
            
        
            // display pfp + first name just for kicks n gigles. will need to fetch all that
            // need to fetch ig, snap, phone number and display non-nil values. this is easy to do.
            
            // if ad watched + completed write approval to database
            
            // be constantly checking both uids for approval / rejection
            // other user rejects --> display sad face and close
        }
        .onAppear() {
            print("this should only call once")
            DatabaseManager.shared.getMatchUid(uid: contentViewModel.uid) { match in
                if let match = match {
                    matchUid = match
                    DatabaseManager.shared.fetchPfp(uid: matchUid) { url in
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
                    DatabaseManager.shared.getFirstName(uid: matchUid) { name in
                        if let name = name {
                            self.firstName = name
                        }
                    }
                    DatabaseManager.shared.getIg(uid: matchUid) { ig in
                        if let ig = ig {
                            self.ig = ig
                        }
                    }
                    DatabaseManager.shared.getSnap(uid: matchUid) { snap in
                        if let snap = snap {
                            self.snap = snap
                        }
                    }
                    DatabaseManager.shared.getDigits(uid: matchUid) { digits in
                        if let digits = digits {
                            self.phoneNumber = digits
                        }
                    }
                } else {
                    print("Fetch fuckin failed")
                }
            }
        }
    }
}
