//
//  CustomTextField.swift
//  Prop
//
//  Created by Jonathan Kim on 6/26/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}

struct CustomSecureField: View {
    var placeholder: Text
    @Binding var text: String
    var commit: ()->() = { }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            SecureField("", text: $text, onCommit: commit)
        }
    }
}
