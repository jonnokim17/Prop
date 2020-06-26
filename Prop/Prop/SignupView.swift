//
//  SignupView.swift
//  Prop
//
//  Created by Jonathan Kim on 6/24/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI
import Firebase

struct SignupView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var error = ""
    @State private var isLoading = false

    @EnvironmentObject var user: UserStore

    @Environment(\.presentationMode) private var presentationMode

    private func signUp() {
        self.isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.error = error.localizedDescription
            } else {
                self.user.isLogged = true
                let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") as? String ?? ""
                let uid = Auth.auth().currentUser?.uid ?? ""
                Firestore.firestore().collection("users").document(uid).setData([
                    "fcmToken": fcmToken,
                    "username": self.username,
                    "uid": uid
                ]) { (error) in
                    if let error = error {
                        self.error = error.localizedDescription
                    } else {
                        UserDefaults.standard.set(true, forKey: "isLogged")
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.presentationMode.wrappedValue.dismiss()
                            self.username = ""
                            self.email = ""
                            self.password = ""
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        ZStack {
            VStack {
                Text("Create Account")
                    .font(.system(size: 32, weight: .heavy))
                Text("Sign up to get started")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.gray)

                VStack(spacing: 18) {
                    TextField("Username", text: $username)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.gray, lineWidth: 1))

                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.gray, lineWidth: 1))

                    SecureField("Password", text: $password)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.gray, lineWidth: 1))
                }
                .padding(.vertical, 24)

                Button(action: signUp) {
                    Text("Create Account")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                        .background(Color.blue)
                        .cornerRadius(5)
                }

                if !error.isEmpty {
                    Text(error)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.red)
                        .padding()
                }

                Spacer()
                    .padding(.horizontal, 32)
            }
            .offset(y: -40)

            if isLoading {
                LoadingView()
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
