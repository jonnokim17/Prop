//
//  ComposeView.swift
//  Prop
//
//  Created by Jonathan Kim on 6/20/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI
import Firebase

struct ComposeView: View {
    let db = Firestore.firestore()

    @State private var message = ""
    @State private var textStyle = UIFont.TextStyle.body
    @State private var showSearchView = false
    @State var selectedFriend = ""
    @State var selectedFriendUid = ""

    @ObservedObject var store: DataStore

    @Environment(\.presentationMode) private var presentationMode

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    @State private var endDate = Date()

    var body: some View {
        VStack(spacing: 24) {
            Text("Enter your prop bet here")
                .font(.system(size: 24, weight: .bold))
                .padding()
            TextView(text: $message, textStyle: $textStyle)
                .padding(.horizontal)
                .frame(height: 100)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 20)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.db.collection("props").addDocument(data: [
                        "createdAt": Date(),
                        "didAccept": false,
                        "endingAt": self.endDate,
                        "proposal": self.message,
                        "bettors": [
                            self.selectedFriendUid,
                            Auth.auth().currentUser?.uid ?? ""
                            ]]) { (error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    let prop = Prop(proposal: self.message, opponent: self.selectedFriendUid, createdAt: Date(), endingAt: self.endDate, didAccept: false, show: false, bettors:  [self.selectedFriendUid,Auth.auth().currentUser?.uid ?? ""])
                                    self.store.addProp(prop: prop)
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                        }
                    }) {
                    Text("PROP!")
                    }
                    .padding(20)
                    .background(Color.green.opacity(self.selectedFriend.isEmpty || self.message.isEmpty ? 0.3 : 1))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    .disabled(self.selectedFriend.isEmpty || self.message.isEmpty ? true : false )
                    
                }
                .padding(.horizontal, 30)
                .padding(.vertical)

                Form {
                    HStack {
                        Text("Select your friend:")
                        Spacer()
                        Button(action: {
                            self.showSearchView.toggle()
                        }) {
                            Text(selectedFriend.isEmpty ? "Search Friends" : selectedFriend)
                        }
                        .sheet(isPresented: $showSearchView) {
                            SearchView(selectedFriend: self.$selectedFriend, selectedFriendUid: self.$selectedFriendUid)
                        }
                    }
                    DatePicker("End Date:", selection: $endDate, in: Date()...)
                    .onAppear {
                        self.hideKeyboard()
                    }
                }
            }
            Spacer()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView(store: DataStore())
    }
}
