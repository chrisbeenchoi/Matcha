//
//  StartView.swift
//  Matcha
//
//  Created by Chris Choi on 6/19/23.
//

import Foundation
import SwiftUI

struct StartView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    // improve this soon.
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .cornerRadius(20)
                .padding()
            
            Button("Login") {
                contentViewModel.loggingIn = true
            }
            .padding()
            .foregroundColor(.white)
            .background(Color("matcha"))
            .cornerRadius(10)
            
            Button("Register") {
                contentViewModel.registering = true
            }
            .padding()
            .foregroundColor(.white)
            .background(Color("matcha"))
            .cornerRadius(10)
        }
        .padding(.bottom, 75)
    }
}
