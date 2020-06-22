//
//  SearchView.swift
//  Prop
//
//  Created by Jonathan Kim on 6/21/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI
import Firebase

struct SearchView: View {
    @State private var searchData = ""
    @State private var showAction = false
    @State private var friendsArray = [String]()

    @Binding var selectedFriend: String

    @EnvironmentObject var user: UserStore
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            SearchBar(text: $searchData)
                .padding()
            List {
                ForEach(self.friendsArray, id: \.self) { data in
                    HStack {
                        Button(action: {
                            self.selectedFriend = data
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                        Text(data)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            self.getAllFriends()
        }
    }

    func getAllFriends() {
        Firestore.firestore().collection("users").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid ?? "").getDocuments { (snapshot, error) in
            if let document = snapshot?.documents.map({ $0.data() }).first {
                if let friendsUidArray = document["friends"] as? [String] {
                    self.getFriends(uids: friendsUidArray)
                }
            }
        }
    }

    func getFriends(uids: [String]) {
        for uid in uids {
            Firestore.firestore().collection("users").whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
                if let document = snapshot?.documents.map({ $0.data() }).first, let userFirstName = document["firstName"] as? String {
                    self.friendsArray.append(userFirstName)
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(selectedFriend: .constant(""))
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.black)
            TextField("Search", text: $text)
            Spacer(minLength: 0)

            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .foregroundColor(Color(UIColor.systemGray6))
                        .frame(width: 8, height: 8)
                        .background(Circle().foregroundColor(Color(UIColor.systemGray2)).frame(width: 16, height: 16))

                }
            }
        }
        .padding(5)
        .padding([.leading, .trailing], 6)
        .background(RoundedRectangle(cornerRadius: 30).foregroundColor(Color(UIColor.systemGray6)))
        .frame(maxWidth: .infinity)
    }
}
