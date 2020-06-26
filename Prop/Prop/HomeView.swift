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
    @State private var showingActionSheet = false
    @State private var propStatus: PropStatus = .all

    let db = Firestore.firestore()

    enum PropStatus: String {
        case accepted
        case rejected
        case pending
        case all
    }

    var body: some View {
        ZStack {
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
                        .animation(nil)
                        .sheet(isPresented: $showPropCompose) {
                            ComposeView(store: self.store)
                        }
                        .padding(8)

                        Button(action: {
                            self.showingActionSheet.toggle()
                        }) {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .renderingMode(.original)
                                .font(.system(size: 18, weight: .medium))
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                                .blur(radius: active ? 20 : 0)
                        }
                        .animation(nil)
                        .actionSheet(isPresented: $showingActionSheet) { () -> ActionSheet in
                            ActionSheet(title: Text("Filter Props By"), message: nil, buttons: [
                                .default(Text("Accepted"), action: {
                                    self.propStatus = .accepted
                                }),
                                .default(Text("Rejected"), action: {
                                    self.propStatus = .rejected
                                }),
                                .default(Text("Pending"), action: {
                                    self.propStatus = .pending
                                }),
                                .default(Text("Show All"), action: {
                                    self.propStatus = .all
                                }),
                                .cancel()
                            ])
                        }
                    }
                    .padding()

                    if !store.isLoading && store.props.isEmpty {
                        Text("No Prop Available")
                            .offset(y: screen.height/2 - 200)
                            .animation(nil)
                    } else {
                        ForEach(store.props.filter { return propStatus == .all ? true : $0.status == propStatus.rawValue }.indices, id: \.self) { index in
                            GeometryReader { geometry in
                                PropView(
                                    store: self.store,
                                    show: self.$store.props[index].show,
                                    active: self.$active,
                                    index: index, activeIndex: self.$activeIndex,
                                    prop: self.store.props.filter { return self.propStatus == .all ? true : $0.status == self.propStatus.rawValue }[index]
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
        formatter.dateStyle = .medium
        return formatter
    }

    var dateFormatter2: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                VStack(alignment: .leading, spacing: 30.0) {
                    Text("Prop Info")
                        .font(.title).bold()
                    Text(prop.proposal)
                }
                .animation(nil)
                .opacity(show ? 1 : 0)
                .offset(y: -100)
            }
            .padding(30)
            .frame(maxWidth: show ? .infinity : screen.width - 60, maxHeight: show ? .infinity : 280, alignment: .top)
            .offset(y: show ? 500 : 0)

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

                VStack(spacing: 20) {
                    Text(show ? opponentName : prop.proposal)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: screen.width - (show ? 80 : 110))
                        .offset(y: show ? 0 : -36)
                        .animation(nil)
                    Text(prop.endingAt < Date() ? "ENDED" : prop.status == "rejected" ? "REJECTED" : "Ends on " + dateFormatter.string(from: prop.endingAt) + " at " + dateFormatter2.string(from: prop.endingAt))
                        .font(.system(.subheadline))
                        .foregroundColor(.white)
                        .offset(y: show ? 0 : -36)
                }
                .offset(y: prop.bettors.last != Auth.auth().currentUser?.uid && prop.status == "pending" && prop.endingAt > Date() ? 0 : 30)

                HStack {
                    HStack {
                        Button(action: {
                            Firestore.firestore().collection("props").whereField("id", isEqualTo: self.prop.id).getDocuments { (snapshot, error) in
                                if let document = snapshot?.documents.first {
                                    document.reference.setData(["status": "accepted"], merge: true)
                                    let updatedProp = Prop(id: self.prop.id, proposal: self.prop.proposal, createdAt: self.prop.createdAt, endingAt: self.prop.endingAt, status: "accepted", show: self.prop.show, bettors: self.prop.bettors)
                                    self.store.updateProp(prop: updatedProp)
                                    DataStore.getFCMToken(uid: self.prop.bettors.last ?? "") { (fcmToken) in
                                        DataStore.sendMessageToUser(to: fcmToken, title: "Prop Accepted!", body: "Good luck! 🤘🤘🤘")
                                    }
                                }
                            }
                        }) {
                            HStack {
                                Text("ACCEPT")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                            }
                            .padding(12)
                            .padding(.horizontal, 30)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Color.green.opacity(0.3), radius: 20, x: 0, y: 20)
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
                                    DataStore.getFCMToken(uid: self.prop.bettors.last ?? "") { (fcmToken) in
                                        DataStore.sendMessageToUser(to: fcmToken, title: "Prop Rejected", body: "😞😞😞")
                                    }
                                }
                            }
                        }) {
                            HStack {
                                Text("REJECT")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                            }
                            .padding(12)
                            .padding(.horizontal, 30)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Color.red.opacity(0.3), radius: 20, x: 0, y: 20)
                        }
                    }
                }
                .padding(.top, show ? 12 : 0)
                .opacity(prop.bettors.last != Auth.auth().currentUser?.uid && prop.status == "pending" && prop.endingAt > Date() ? 1 : 0)
            }
            .padding(show ? 30 : 20)
            .padding(.top, show ? 30 : 0)
            .frame(maxWidth: show ? .infinity : screen.width - 60, maxHeight: show ? 400 : 280)
            .background(prop.endingAt < Date() || prop.status == "rejected" ? Color.red : Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: prop.endingAt < Date() ? Color.red.opacity(0.3) : Color.blue.opacity(0.3), radius: 20, x: 0, y: 20)
            .gesture(
                show ?
                    DragGesture().onChanged { value in
                        guard value.translation.height < 300 else { return }
                        guard value.translation.height > 0 else { return }
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
            if let document = snapshot?.documents.map({ $0.data() }).first, let username = document["username"] as? String {
                completion(username)
            }
        }
    }
}
