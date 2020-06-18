//
//  UserStore.swift
//  Prop
//
//  Created by Jonathan Kim on 6/17/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI
import Combine

class UserStore: ObservableObject {
    @Published var isLogged: Bool = UserDefaults.standard.bool(forKey: "isLogged") {
        didSet {
            UserDefaults.standard.set(self.isLogged, forKey: "isLogged")
        }
    }
}
