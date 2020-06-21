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
                    var sectionData = [Prop]()

                    for propDocument in documents {
                        if let proposal = propDocument["proposal"] as? String, let opponent = propDocument["bettors"] as? [String], let uid = opponent.first {

                            let section = Prop(proposal: proposal, opponent: uid)
                            sectionData.append(section)
                        }
                    }

                    self.props = sectionData

                }
            }
        }
    }

    func addProp(prop: Prop) {
        props.append(prop)
    }
}
