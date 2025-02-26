//
//  LoginView.swift
//  Prop
//
//  Created by Jonathan Kim on 6/17/20.
//  Copyright © 2020 nomadjonno. All rights reserved.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @State var isFocused = false
    @State var showAlert = false
    @State var alertMessage = "Something went wrong."
    @State var isLoading = false
    @State var isSuccessful = false

    @EnvironmentObject var user: UserStore

    private func login() {
        hideKeyboard()
        self.isFocused = false
        self.isLoading = true

        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            self.isLoading = false
            if error != nil {
                self.alertMessage = error?.localizedDescription ?? ""
                self.showAlert = true
            } else {
                self.isSuccessful = true
                self.user.isLogged = true
                let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") as? String ?? ""
                Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").setData(["fcmToken": fcmToken], merge: true)
                UserDefaults.standard.set(true, forKey: "isLogged")

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isSuccessful = false
                    self.email = ""
                    self.password = ""
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                ZStack(alignment: .top) {
                    Color("background2")
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .edgesIgnoringSafeArea(.bottom)
                    CoverView()

                    VStack {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)))
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                                .padding(.leading)
                            TextField("Your Email".uppercased(), text: $email)
                                .keyboardType(.emailAddress)
                                .font(.subheadline)
                                .padding(.leading)
                                .frame(height: 44)
                                .onTapGesture {
                                    self.isFocused = true
                            }
                        }

                        Divider()
                            .padding(.leading, 80)

                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)))
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                                .padding(.leading)
                            SecureField("Password".uppercased(), text: $password)
                                .keyboardType(.default)
                                .font(.subheadline)
                                .padding(.leading)
                                .frame(height: 44)
                                .onTapGesture {
                                    self.isFocused = true
                            }
                        }
                    }
                    .frame(height: 136)
                    .frame(maxWidth: .infinity)
                    .background(BlurView(style: .systemMaterial))
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 20)
                    .padding(.horizontal)
                    .offset(y: 440)

                    VStack {
                        HStack {
                            Text("Forgot password?")
                                .font(.subheadline)
                            Spacer()
                            Button(action: {
                                self.login()
                            }) {
                            Text("Log in")
                                .foregroundColor(.white)

                            }
                            .padding(12)
                            .padding(.horizontal, 30)
                            .background(Color(#colorLiteral(red: 0, green: 0.6192483948, blue: 1, alpha: 1)))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Color(#colorLiteral(red: 0, green: 0.6192483948, blue: 1, alpha: 1)).opacity(0.3), radius: 20, x: 0, y: 20)
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Error"), message: Text(self.alertMessage), dismissButton: .default(Text("OK")))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding()
                        .offset(y: isFocused && screen.height > 700 ? -140 : 0)

                        Spacer()

                        NavigationLink(destination: SignupView()) {
                            HStack {
                                Text("I'm a new user.")
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundColor(.primary)
                                Text("Create an account")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.blue)
                            }
                        }
                        .offset(y: isFocused && screen.height > 700 ? -140 : 0)
                    }
                }
                .offset(y: isFocused ? screen.height < 700 ? -240 : -200 : 0)
                .animation(.easeInOut)
                .onTapGesture {
                    self.isFocused = false
                    hideKeyboard()
                }

                if isLoading {
                    LoadingView()
                }

                if isSuccessful {
                    SuccessView()
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct CoverView: View {
    @State var show = false
    @State var viewState = CGSize.zero
    @State var isDragging = false

    var body: some View {
        VStack(spacing: -20) {
            GeometryReader { geometry in
                Text("Welcome to Prop!")
                    .font(.system(size: geometry.size.width/10, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 375, maxHeight: 100)
            .padding(.horizontal, 16)
            .offset(x: viewState.width/15, y: viewState.height/15)

            Text("Have fun prop betting with your friends!")
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(width: 200)
                .offset(x: viewState.width/20, y: viewState.height/20)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.top, 80)
        .frame(height: 477)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                Image(uiImage: #imageLiteral(resourceName: "Blob"))
                    .offset(x: -150, y: -200)
                    .rotationEffect(Angle(degrees: show ? 360+90 : 90))
                    .blendMode(.plusDarker)
                    .animation(Animation.linear(duration: 120).repeatForever(autoreverses: false))
                    .onAppear {
                        self.show = true
                }
                Image(uiImage: #imageLiteral(resourceName: "Blob"))
                    .offset(x: -200, y: -250)
                    .rotationEffect(Angle(degrees: show ? 360 : 0), anchor: .leading)
                    .blendMode(.overlay)
                    .animation(Animation.linear(duration: 100).repeatForever(autoreverses: false))
            }
        )
            .background(
                Image(uiImage: #imageLiteral(resourceName: "LoginBackground"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: viewState.width/25, y: viewState.height/25), alignment: .bottom
        )
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .scaleEffect(isDragging ? 0.9 : 1)
            .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
            .rotation3DEffect(Angle(degrees: 5), axis: (x: viewState.width, y: viewState.height, z: 0))
            .gesture(
                DragGesture().onChanged { value in
                    self.viewState = value.translation
                    self.isDragging = true
                }
                .onEnded { _ in
                    self.viewState = .zero
                    self.isDragging = false
                }
        )
    }
}
