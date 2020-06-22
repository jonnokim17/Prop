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

    @ObservedObject var store: DataStore

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 24) {
            Text("Enter your prop bet here")
                .font(.system(size: 24, weight: .bold))
                .padding()
            TextView(text: $message, textStyle: $textStyle)
                .padding(.horizontal)
                .frame(height: 240)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 20)
            HStack {
                Spacer()
                Button(action: {
                    var acceptedAtDay = DateComponents()
                    acceptedAtDay.day = 5
                    let acceptedAtDate = Calendar.current.date(byAdding: acceptedAtDay, to: Date()) ?? Date()

                    var endingAtDay = DateComponents()
                    endingAtDay.day = 30
                    let endingAtDate = Calendar.current.date(byAdding: endingAtDay, to: Date()) ?? Date()

                    // passing dummy data
                    self.db.collection("props").addDocument(data: [
                    "createdAt": Date(),
                    "acceptedAt": acceptedAtDate,
                    "endingAt": endingAtDate,
                    "proposal": self.message,
                    "bettors": [
                        "fcl1aTMulYeAFCLDdPEgI972EZJ3", // dko's uid
                        Auth.auth().currentUser?.uid ?? ""
                        ]]) { (error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                let prop = Prop(proposal: self.message, opponent: "fcl1aTMulYeAFCLDdPEgI972EZJ3", show: false)
                                self.store.addProp(prop: prop)
                                self.presentationMode.wrappedValue.dismiss()
                            }
                    }
                }) {
                Text("Prop!")
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical)
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
