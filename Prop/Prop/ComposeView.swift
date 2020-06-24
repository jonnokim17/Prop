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
let ReceiverFCMToken = "c77c0YUDckB8qsuhuV6Lx8:APA91bH8x0oJc0tDEhy8u55dPiJrWRZy6j54moVehblp25Mx8Xv3XSBASGzcFSD2gQVHHwoUF6TOL52AVS062oOcXHKySfkOUjEz_GQnTRkIpEQHLK3VVZon4-ho-btf10b6lUNM_yKy"

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
                                    let prop = Prop(proposal: self.message, createdAt: Date(), endingAt: self.endDate, didAccept: false, show: false, bettors:  [self.selectedFriendUid,Auth.auth().currentUser?.uid ?? ""])
                                    self.getFCMToken(uid: self.selectedFriendUid) { (fcmToken) in
                                        self.sendMessageToUser(to: fcmToken, title: "New Prop Received!", body: self.message)
                                        self.store.addProp(prop: prop)
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
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

    func getFCMToken(uid: String, completion: @escaping(String) -> ()) {
        Firestore.firestore().collection("users").whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
            if let document = snapshot?.documents.map({ $0.data() }).first, let fcmToken = document["fcmToken"] as? String {
                completion(fcmToken)
            }
        }
    }

    func sendMessageToUser(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        guard let url = NSURL(string: urlString) else { return }
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(ServerKey)", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        print("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
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
