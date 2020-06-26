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
    @State var isFocused = false

    @EnvironmentObject var user: UserStore
    @Environment(\.presentationMode) private var presentationMode

    private func signUp() {
        self.isLoading = true
        self.isFocused = false
        hideKeyboard()
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            self.isLoading = false
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
            Color(#colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            ZStack {
                VStack {
                    Text("Create Account")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(.white)
                    Text("Sign up to get started")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.gray)

                    VStack(spacing: 18) {
                        CustomTextField(placeholder: Text("Username").foregroundColor(Color.white.opacity(0.6)), text: $username)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.gray, lineWidth: 1))
                            .onTapGesture {
                                self.isFocused = true
                        }
                        CustomTextField(placeholder: Text("Email Address").foregroundColor(Color.white.opacity(0.6)), text: $email)
                            .keyboardType(.emailAddress)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.gray, lineWidth: 1))
                            .onTapGesture {
                                self.isFocused = true
                        }
                        CustomSecureField(placeholder: Text("Password").foregroundColor(Color.white.opacity(0.6)), text: $password)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.gray, lineWidth: 1))
                            .onTapGesture {
                                self.isFocused = true
                        }
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
            .offset(y: isFocused && screen.height < 700 ? -60 : 0)
        }
        .onTapGesture {
            self.isFocused = false
            hideKeyboard()
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
