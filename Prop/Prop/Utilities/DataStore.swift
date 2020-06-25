//
//  DataStore.swift
//  Prop
//
//  Created by Jonathan Kim on 6/20/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI
import Combine
import Firebase

class DataStore: ObservableObject {
    @Published var props: [Prop] = []

    init() {
        getProps()
    }

    func getProps() {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        Firestore.firestore().collection("props").whereField("bettors", arrayContains: currentUserId).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let snapshot = snapshot {
                    let documents = snapshot.documents.map { $0.data() }
                    var propData = [Prop]()

                    for propDocument in documents {
                        if let proposal = propDocument["proposal"] as? String,
                            let bettors = propDocument["bettors"] as? [String],
                            let createdAt = propDocument["createdAt"] as? Timestamp,
                            let endingAt = propDocument["endingAt"] as? Timestamp,
                            let status = propDocument["status"] as? String,
                            let id = propDocument["id"] as? String
                        {
                            let prop = Prop(id: id, proposal: proposal, createdAt: createdAt.dateValue(), endingAt: endingAt.dateValue(), status: status, show: false, bettors: bettors)
                            propData.append(prop)
                        }
                    }

                    propData.sort { $0.createdAt > $1.createdAt }
                    self.props = propData
                }
            }
        }
    }

    func addProp(prop: Prop) {
        props.append(prop)
    }

    func updateProp(prop: Prop) {
        if let row = props.firstIndex(where: {$0.id == prop.id}) {
            props[row] = prop
        }
    }

    static func getFCMToken(uid: String, completion: @escaping(String) -> ()) {
        Firestore.firestore().collection("users").whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
            if let document = snapshot?.documents.map({ $0.data() }).first, let fcmToken = document["fcmToken"] as? String {
                completion(fcmToken)
            }
        }
    }

    static func sendMessageToUser(to token: String, title: String, body: String) {
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
        let task = URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
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

struct Prop: Identifiable {
    var id: String
    var proposal: String
    var createdAt: Date
    var endingAt: Date
    var status: String
    var show: Bool
    var bettors: [String]
}
