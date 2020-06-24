//
//  SettingsView.swift
//  Prop
//
//  Created by Jonathan Kim on 6/19/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI
import Firebase

struct SettingsView: View {
    @EnvironmentObject var user: UserStore
    @State var showAlert = false

    @State private var fcmTokenMessage = "fcmTokenMessage"
    @State private var instanceIDTokenMessage = "instanceIDTokenMessage"
    @State private var notificationTitle: String = ""
    @State private var notificationContent: String = ""

    var body: some View {
        VStack {
            HStack {
                Text("User Settings")
                Spacer()
                Button(action: {
                    self.showAlert = true
                }) {
                Text("Logout")
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Logging out..."), message: Text("Are you sure you want to logout?"), primaryButton: .default(Text("Yes"), action: {

                        // logout of Firebase
                        do {
                            try Auth.auth().signOut()
                            UserDefaults.standard.set(false, forKey: "isLogged")
                            self.user.isLogged = false
                            } catch let err {
                                print(err)
                        }

                    }), secondaryButton: .default(Text("Cancel")))
                }
            }
            .padding()

            TextField("Add Notification Title", text: $notificationTitle).textFieldStyle(RoundedBorderTextFieldStyle()).padding(8)
            TextField("Add Notification Content", text: $notificationContent).textFieldStyle(RoundedBorderTextFieldStyle()).padding(8)
            Button(action: {self.sendMessageToUser(to: ReceiverFCMToken, title: self.notificationTitle, body: self.notificationContent)
                self.notificationTitle = ""
                self.notificationContent = ""
            }) {
                Text("Send message to User").font(.title)
            }.padding(8)

            Spacer()
        }
    }

    func sendMessageToUser(to token: String, title: String, body: String) {
        print("sendMessageTouser()")
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
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
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
