//
//  ContentView.swift
//  Prop
//
//  Created by Jonathan Kim on 6/17/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var user: UserStore

    var body: some View {
        ZStack {
            LoginView()
                .opacity(user.isLogged ? 0 : 1)
            TabView {
                HomeView().tabItem({
                    Image(systemName: "person.fill")
                    Text("Home")
                }).tag(0)
                SettingsView().tabItem({
                    Image(systemName: "gear")
                    Text("Settings")
                }).tag(1)
            }.opacity(user.isLogged ? 1 : 0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
