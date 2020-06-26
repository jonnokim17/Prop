//
//  TextView.swift
//  Prop
//
//  Created by Jonathan Kim on 6/20/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var textStyle: UIFont.TextStyle

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.delegate = context.coordinator

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>

        init(_ text: Binding<String>) {
            self.text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.count
            return numberOfChars < 500
        }
    }
}

public func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
