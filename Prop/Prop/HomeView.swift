//
//  HomeView.swift
//  Prop
//
//  Created by Jonathan Kim on 6/17/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI
import Firebase

struct HomeView: View {
    @EnvironmentObject var user: UserStore
    @State var showAlert = false
    @State var sectionData = [Section]()

    let db = Firestore.firestore()

    var body: some View {
        VStack {
            HStack {
                Text("Prop!")
                    .font(.system(size: 28, weight: .bold))
                Spacer()
                Button(action: {
//                    self.addFireStoreDB()
                }) {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .frame(width: 36, height: 36)
                }
            }
            .padding()

            ScrollView {
                VStack(spacing: 24) {
                    ForEach(sectionData) { item in
                        SectionView(section: item)
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .onAppear {
            self.getProps { (section) in
                self.sectionData = section
            }
        }
    }

    func getProps(completion: @escaping([Section]) -> ()) {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        db.collection("props").whereField("bettors", arrayContains: currentUserId).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let snapshot = snapshot {
                    let documents = snapshot.documents.map { $0.data() }
                    var sectionData = [Section]()

                    for propDocument in documents {
                        if let proposal = propDocument["proposal"] as? String, let opponent = propDocument["bettors"] as? [String], let uid = opponent.first {

                            let section = Section(proposal: proposal, opponent: uid)
                            sectionData.append(section)
                        }
                    }

                    return completion(sectionData)

                }
            }
        }
    }

    func getFriend(uid: String, completion: @escaping(String) -> ()) {
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
            if let document = snapshot?.documents.map({ $0.data() }).first, let userFirstName = document["firstName"] as? String {
                completion(userFirstName)
            }
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct SectionView: View {
    var section: Section

    var body: some View {
        VStack(spacing: 30) {
            Text(section.proposal)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 160)
            Text(section.opponent)
                .font(.system(.subheadline))
                .foregroundColor(.white)
        }
        .frame(width: 340, height: 280)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 20)
    }
}

struct Section: Identifiable {
    var id = UUID()
    var proposal: String
    var opponent: String
}

//    func addFireStoreDB() {
//        let db = Firestore.firestore()
//
//        /// Add new document
//        db.collection("airline").addDocument(data: ["year": 1990, "type": "Avianca", "origin": "Colombia"])
//
//        /// Getting document ID
//        let newDocument = db.collection("airline").document()
//        newDocument.setData(["year": 1990, "type": "LATAM", "origin": "Panama", "id": newDocument.documentID])
//
//        /// Add a document with a specific ID
//        db.collection("airline").document("asian_airlines").setData(["year": 1987, "type": "Singapore Air", "origin": "Korea", "test": "test"])
//
//        /// Using completion handler
//        db.collection("airline").addDocument(data: ["asdf": "asdf"]) { (error) in
//            if let error = error {
//                print("there was an error.")
//            } else {
//                // error is nil, operation successful
//            }
//        }
//
//        /// delete a document
//        db.collection("airline").document("IvpxFuG0F4hvmKHZREhG").delete()
//
//        /// delete a single field
//        db.collection("airline").document("asian_airlines").updateData(["test": FieldValue.delete()])
//
//        /// detect error, use completion handler
//        db.collection("airline").document("IvpxFuG0F4hvmKHZREhG").delete { (error) in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                // successful
//            }
//        }
//
//        /// read a specific document
//        db.collection("airline").document("asian_airlines").getDocument { (snapshot, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                if let snapshot = snapshot, snapshot.exists {
//                    guard let documentData = snapshot.data() else {
//                        return
//                    }
//                    print(documentData)
//                }
//            }
//        }
//
//        /// get all documents
//        db.collection("airline").getDocuments { (snapshot, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                if let snapshot = snapshot {
//                    for document in snapshot.documents {
//                        print(document.data())
//                    }
//                }
//            }
//        }
//
//        /// get subset of documents
//        db.collection("airline").whereField("year", isEqualTo: 1987).getDocuments { (snapshot, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                if let snapshot = snapshot {
//                    for document in snapshot.documents {
//                        print(document.data())
//                    }
//                }
//            }
//        }
//    }
