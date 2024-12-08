import SwiftUI

struct LoginView: View {
    @State private var identifier: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var loginSuccess: Bool = false
    @State private var loginFailed: Bool = false
    @State private var isLoggedIn: Bool = false
    @AppStorage("userNickname") var savedNickname: String = ""

    @ObservedObject private var keyboardResponder = KeyboardResponder()

    // 最大偏移量
    private let maxOffset: CGFloat = 150  // 根据需要调整

    var body: some View {
        NavigationView {
            VStack {
                Text("READWORLD")
                    .font(.system(size: 36, weight: .bold))
                    .padding(.top, 60)

                Spacer()

                TextField("Nickname or Phone Number", text: $identifier)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)

                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }

                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: self.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 40)
                .padding(.top, 10)

                NavigationLink(destination: HomeViewWithTabBar()
                    .navigationBarBackButtonHidden(true), isActive: $isLoggedIn) {
                    EmptyView()
                }

                Button(action: {
                    if verifyUserData(identifier: identifier, password: password) {
                        loginSuccess = true
                        loginFailed = false

                        if let nickname = getNickname(for: identifier) {
                            savedNickname = nickname
                        }

                        isLoggedIn = true
                    } else {
                        loginFailed = true
                        loginSuccess = false
                    }
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width - 80, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 30)
                }

                if loginSuccess {
                    Text("Login Successful")
                        .foregroundColor(.green)
                        .padding(.top, 20)
                }

                if loginFailed {
                    Text("Login Failed: Incorrect Nickname, Phone Number or Password")
                        .foregroundColor(.red)
                        .padding(.top, 20)
                }

                Spacer()

                HStack {
                    Text("Don’t have an account?")
                        .foregroundColor(.gray)
                    NavigationLink(destination: RegisterView()) {
                        Text("Register")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.bottom, min(keyboardResponder.currentHeight, maxOffset))  // 限制最大偏移量
            .animation(.easeOut(duration: 0.3), value: keyboardResponder.currentHeight)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }

    func getNickname(for identifier: String) -> String? {
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.hasSuffix("_nickname"), let nickname = value as? String,
               let phoneNumber = UserDefaults.standard.string(forKey: key.replacingOccurrences(of: "_nickname", with: "_phoneNumber")) {
                if identifier == nickname || identifier == phoneNumber {
                    return nickname
                }
            }
        }
        return nil
    }

    func verifyUserData(identifier: String, password: String) -> Bool {
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.hasSuffix("_nickname"), let nickname = value as? String,
               let phoneNumber = UserDefaults.standard.string(forKey: key.replacingOccurrences(of: "_nickname", with: "_phoneNumber")),
               let storedPassword = UserDefaults.standard.string(forKey: key.replacingOccurrences(of: "_nickname", with: "_password")) {
                
                if (identifier == nickname || identifier == phoneNumber), password == storedPassword {
                    return true
                }
            }
        }
        return false
    }
}
