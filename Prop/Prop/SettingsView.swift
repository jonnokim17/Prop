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

            Spacer()
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
