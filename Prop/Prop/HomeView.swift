//
//  HomeView.swift
//  Prop
//
//  Created by Jonathan Kim on 6/17/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI
import Firebase

let screen = UIScreen.main.bounds

struct HomeView: View {
    @State var showAlert = false
    @ObservedObject var store = DataStore()
    @State var showPropCompose = false
    @State var show = false
    @State var active = false
    @State var activeIndex = -1

    let db = Firestore.firestore()

    var body: some View {
        ZStack {
            Color.black.opacity(active ? 0.5 : 0)
                .animation(.linear)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Text("Props")
                            .font(.largeTitle).bold()
                            .frame(width: 100)
                            .padding(.leading, 24)
                            .blur(radius: active ? 20 : 0)
                            Spacer()
                        Button(action: {
                            self.showPropCompose.toggle()
                        }) {
                            Image(systemName: "square.and.pencil")
                                .renderingMode(.original)
                                .font(.system(size: 18, weight: .medium))
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                .blur(radius: active ? 20 : 0)
                        }
                        .sheet(isPresented: $showPropCompose) {
                            ComposeView(store: self.store)
                        }
                    }
                    .padding()

                    ForEach(store.props.indices, id: \.self) { index in
                        GeometryReader { geometry in
                            PropView(
                                store: self.store,
                                show: self.$store.props[index].show,
                                active: self.$active,
                                index: index, activeIndex: self.$activeIndex,
                                prop: self.store.props[index]
                            )
                                .offset(y: self.store.props[index].show ? -geometry.frame(in: .global).minY : 0)
                                .opacity(self.activeIndex != index && self.active ? 0 : 1)
                                .scaleEffect(self.activeIndex != index && self.active ? 0.5 : 1)
                                .offset(x: self.activeIndex != index && self.active ? screen.width : 0)
                        }
                        .frame(height: 280)
                        .frame(maxWidth: self.store.props[index].show ? .infinity : screen.width - 60)
                        .zIndex(self.store.props[index].show ? 1 : 0)
                    }
                }
                .frame(maxWidth: screen.width)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
            }
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct PropView: View {
    @ObservedObject var store: DataStore
    @Binding var show: Bool
    @Binding var active: Bool
    var index: Int
    @Binding var activeIndex: Int
    @State var activeView = CGSize.zero

    var prop: Prop
    @State var opponentName = ""

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                HStack {
                    HStack {
                        Button(action: {
                            Firestore.firestore().collection("props").whereField("id", isEqualTo: self.prop.id).getDocuments { (snapshot, error) in
                                if let document = snapshot?.documents.first {
                                    document.reference.setData(["status": "accepted"], merge: true)
                                    let updatedProp = Prop(id: self.prop.id, proposal: self.prop.proposal, createdAt: self.prop.createdAt, endingAt: self.prop.endingAt, status: "accepted", show: self.prop.show, bettors: self.prop.bettors)
                                    self.store.updateProp(prop: updatedProp)
                                    self.show = false
                                    self.active = false
                                    self.activeIndex = -1
                                }
                            }
                        }) {
                            HStack {
                                Text("ACCEPT")
                                    .font(.system(size: 18))
                            }
                            .frame(minWidth: 0, maxWidth: 120)
                            .padding()
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color.white, lineWidth: 2))
                                .background(Color.green.cornerRadius(40))

                        }
                    }

                    Spacer()

                    HStack {
                        Button(action: {
                            Firestore.firestore().collection("props").whereField("id", isEqualTo: self.prop.id).getDocuments { (snapshot, error) in
                                if let document = snapshot?.documents.first {
                                    document.reference.setData(["status": "rejected"], merge: true)
                                    let updatedProp = Prop(id: self.prop.id, proposal: self.prop.proposal, createdAt: self.prop.createdAt, endingAt: self.prop.endingAt, status: "rejected", show: self.prop.show, bettors: self.prop.bettors)
                                    self.store.updateProp(prop: updatedProp)
                                    self.show = false
                                    self.active = false
                                    self.activeIndex = -1
                                }
                            }
                        }) {
                            HStack {
                                Text("REJECT")
                                    .font(.system(size: 18))
                            }
                            .frame(minWidth: 0, maxWidth: 120)
                            .padding()
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color.white, lineWidth: 2))
                                .background(Color.red.cornerRadius(40))
                        }
                    }
                }
                .padding(.bottom, 30)
                .opacity(prop.bettors.last != Auth.auth().currentUser?.uid && prop.status == "pending" ? 1 : 0)

                VStack(alignment: .leading, spacing: 30.0) {
                    Text("Prop Info")
                        .font(.title).bold()
                    Text("Proposal: \(prop.proposal)")
                    Text("Opponent: \(opponentName)")
                }
            }
            .padding(30)
            .frame(maxWidth: show ? .infinity : screen.width - 60, maxHeight: show ? .infinity : 280, alignment: .top)
            .offset(y: show ? 460 : 0)

            VStack(spacing: 30) {
                HStack {
                    HStack {
                        Text(prop.status.uppercased())
                            .font(.system(size: 16, weight: .medium))
                        Image(prop.status)
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                    Spacer()
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black)
                        .clipShape(Circle())
                }
                .opacity(show ? 1 : 0)
                .offset(y: -60)
                Text(prop.proposal)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 160)
                    .offset(y: show ? 0 : -36)
                Text(dateFormatter.string(from: prop.createdAt))
                    .font(.system(.subheadline))
                    .foregroundColor(.white)
                    .offset(y: show ? 0 : -36)
            }
            .padding(show ? 30 : 20)
            .padding(.top, show ? 30 : 0)
            .frame(maxWidth: show ? .infinity : screen.width - 60, maxHeight: show ? 460 : 280)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 20)
            .gesture(
                show ?
                    DragGesture().onChanged { value in
                        guard value.translation.height < 300  else { return }
                        guard value.translation.height > 0  else { return }
                        self.activeView = value.translation
                    }
                    .onEnded { _ in
                        if self.activeView.height > 50  {
                            self.show = false
                            self.active = false
                            self.activeIndex = -1
                        }
                        self.activeView = .zero
                    }
                    : nil
            )
            .onTapGesture {
                self.show.toggle()
                self.active.toggle()
                if self.show {
                    self.activeIndex = self.index
                } else {
                    self.activeIndex = -1
                }
            }
        }
        .frame(height: show ? screen.height : 280)
        .scaleEffect(1 - self.activeView.height/1000)
        .rotation3DEffect(Angle(degrees: Double(self.activeView.height/10)), axis: (x: 0, y: 10, z: 0))
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
        .gesture(
            show ?
                DragGesture().onChanged { value in
                    guard value.translation.height < 300  else { return }
                    guard value.translation.height > 0  else { return }
                    self.activeView = value.translation
                }
                .onEnded { _ in
                    if self.activeView.height > 50  {
                        self.show = false
                        self.active = false
                        self.activeIndex = -1
                    }
                    self.activeView = .zero
                }
                : nil
        )
            .onAppear {
                self.getFriend(uid: self.prop.bettors.filter { $0 != Auth.auth().currentUser?.uid }.first) { (name) in
                self.opponentName = name
            }
        }
    }

    func getFriend(uid: String?, completion: @escaping(String) -> ()) {
        Firestore.firestore().collection("users").whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
            if let document = snapshot?.documents.map({ $0.data() }).first, let userFirstName = document["firstName"] as? String {
                completion(userFirstName)
            }
        }
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
