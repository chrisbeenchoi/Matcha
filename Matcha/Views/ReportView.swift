//
//  ReportView.swift
//  Matcha
//
//  Created by Chris Choi on 9/20/23.
//

import Foundation
import SwiftUI

struct Violation: Identifiable {
    let id = UUID()
    let name: String
    var isSelected = false
}

class ItemListViewModel: ObservableObject {
    @Published var items: [Violation] = [
        Violation(name: "Inappropriate profile content"),
        Violation(name: "Bullying or harassment"),
        Violation(name: "Impersonation"),
        Violation(name: "Nudity or sexual activity"),
        Violation(name: "Hate speech or symbols"),
        Violation(name: "Other")
    ]
    @Published var selectedItem: Violation? = nil
}

struct ReportView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var itemListViewModel = ItemListViewModel()
    
    @State var reporting = false
    
    @State var matchUid: String = "" //fetch this
    @State var firstName: String = ""
    @State var description: String = ""
    
    @State var alertItem: AlertItem?
    
    var body: some View {
        if !reporting {
            VStack {
                Text("\(firstName) has been blocked.")
                    .padding()
                
                Button("Cancel block", action: {
                    if matchUid != "" {
                        DatabaseManager.shared.unblockUser(blocker: contentViewModel.uid, blocked: matchUid) { success in
                            if success {
                                contentViewModel.reporting = false
                                contentViewModel.homeOverride = true
                            }
                        }
                    }
                })
                .padding()
                
                Button("Close", action: {
                    contentViewModel.homeOverride = true
                })
                .padding()
                
                Button("Report", action: {
                    reporting = true
                })
                .padding()
            }
            .onAppear() {
                DatabaseManager.shared.getMatchUid(uid: contentViewModel.uid) { match in
                    if let match = match {
                        self.matchUid = match
                        DatabaseManager.shared.getFirstName(uid: match) { name in
                            if let name = name {
                                self.firstName = name
                            }
                        }
                    }
                }
            }
        } else {
            
            VStack {
                List {
                    ForEach(itemListViewModel.items.indices, id: \.self) { index in
                        let itemBinding = $itemListViewModel.items[index]
                        HStack {
                            Text(itemBinding.wrappedValue.name)
                            Spacer()
                            Image(systemName: itemBinding.wrappedValue.isSelected ? "checkmark" : "square")
                                .onTapGesture {
                                    itemBinding.wrappedValue.isSelected.toggle()
                                }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            itemBinding.wrappedValue.isSelected.toggle()
                        }
                    }
                }
                // if Other selected you must write something
                TextField("Describe violation", text: self.$description, axis: .vertical)
                    .lineLimit(4)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button("Report \(firstName)", action: {
                    print("blocked..rported..the whole package")
                    
                    let selected = itemListViewModel.items.filter { $0.isSelected }
                    var valid = true
                    if selected.count == 0 {
                        print("HELL NAW!!")
                        alertItem = AlertItem(title: "Invalid reason!", message: "Select a reason for reporting.")
                        valid = false
                    }
                    
                    selected.forEach { item in
                        if item.name == "Other" && description == "" {
                            print("HELL NAW")
                            alertItem = AlertItem(title: "Invalid reason!", message: "Specify a reason for selecting Other.")
                            valid = false
                        }
                    }
                    
                    if valid {
                        DatabaseManager.shared.reportUser(reporter: contentViewModel.uid, reported: matchUid, violations: selected, description: description) { success in
                            if success {
                                alertItem = AlertItem(title: "Reported \(firstName)", message: "We will review \(firstName)'s activity and take action as necessary.")
                            } else {
                                alertItem = AlertItem(title: "Failed to report!", message: "Try again.")
                            }
                        }
                    }
                })
            }
            .alert(item: $alertItem) { alertItem in
                Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .default(Text("OK")) {
                    if (alertItem.title == "Reported \(firstName)") {
                        contentViewModel.reporting = false
                        contentViewModel.homeOverride = true
                    }
                })
            }
        }
    }
}
