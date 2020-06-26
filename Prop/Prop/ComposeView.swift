//
//  ComposeView.swift
//  Prop
//
//  Created by Jonathan Kim on 6/20/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI
import Firebase

let ServerKey = "AAAASRQEUjg:APA91bHu8frbx_UlKFLZCwtfWBwFPA1fNkyC0oZQRoVKSai_75fc_bkDFqh4d25hHomyE6bAPlb5WaO06QiOqLCFsCJ10C9aQHXfkJ2MNpc7krBQA6LsF0bUjnadr7LiUN_gdApPnKu_"

struct ComposeView: View {
    let db = Firestore.firestore()

    @State private var message = ""
    @State private var textStyle = UIFont.TextStyle.body
    @State private var showSearchView = false
    @State var selectedFriend = ""
    @State var selectedFriendUid = ""
    @State private var isFocused = false
    @State private var isDatePickerOpen = false
    @State private var viewDidLoad = false

    @ObservedObject var store: DataStore

    @Environment(\.presentationMode) private var presentationMode

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    @State private var endDate = Date()

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Text("Enter your prop bet here")
                    .font(.system(size: 24, weight: .bold))
                    .padding()
                TextView(text: $message, textStyle: $textStyle)
                    .padding(.horizontal)
                    .frame(height: 100)
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 20)
                    .onTapGesture {
                        self.isFocused = true
                    }
                VStack {
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
                            if self.viewDidLoad {
                                self.isDatePickerOpen = true
                            }
                            self.viewDidLoad = true
                            self.isFocused = false
                            hideKeyboard()
                        }
                        .onDisappear {
                            self.isDatePickerOpen = false
                        }
                    }
                    .frame(height: isDatePickerOpen ? 500 : 150)

                    VStack {
                        Button(action: {
                            let id = UUID().uuidString
                            self.db.collection("props").addDocument(data: [
                                "id": id,
                                "createdAt": Date(),
                                "status": "pending",
                                "endingAt": self.endDate,
                                "proposal": self.message,
                                "bettors": [
                                    self.selectedFriendUid,
                                    Auth.auth().currentUser?.uid ?? ""
                                ]]) { (error) in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else {
                                        let prop = Prop(id: id, proposal: self.message, createdAt: Date(), endingAt: self.endDate, status: "pending", show: false, bettors:  [self.selectedFriendUid,Auth.auth().currentUser?.uid ?? ""])
                                        DataStore.getFCMToken(uid: self.selectedFriendUid) { (fcmToken) in
                                            DataStore.sendMessageToUser(to: fcmToken, title: "New Prop Received! 🚀🚀🚀", body: self.message)
                                            self.store.addProp(prop: prop)
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                            }
                        }) {
                        Text("PROP")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.white.opacity(self.selectedFriend.isEmpty || self.message.isEmpty ? 0.3 : 1))
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 60)
                        .background(Color.green.opacity(self.selectedFriend.isEmpty || self.message.isEmpty ? 0.3 : 1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                        .disabled(self.selectedFriend.isEmpty || self.message.isEmpty ? true : false )
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.00001))
                    .onTapGesture {
                        self.isFocused = false
                        hideKeyboard()
                    }
                }
                Spacer()
            }
            .offset(y: isFocused && screen.height < 700 ? -80 : 0)
        }
    }
}

struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView(store: DataStore())
    }
}
