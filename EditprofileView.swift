import SwiftUI

struct EditProfileView: View {
    @State private var nickname: String = ""
    @State private var phoneNumber: String = ""
    @State private var storedEmail: String = ""
    var identifier: String // 可用昵称或手机号作为唯一标识

    var body: some View {
        Form {
            // 个人信息部分
            Section(header: Text("Personal Information")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .textCase(nil)
                        .padding(.bottom, 40)
            ) {
                // 昵称（不可修改）
                HStack {
                    Text("Nickname")
                        .font(.headline)
                    Spacer()
                    Text(nickname)
                        .foregroundColor(.gray)
                }
                
                // 邮箱（不可修改）
                HStack {
                    Text("Email")
                        .font(.headline)
                    Spacer()
                    Text(storedEmail)
                        .foregroundColor(.gray)
                }
                
                // 手机号码（不可修改）
                HStack {
                    Text("Phone Number")
                        .font(.headline)
                    Spacer()
                    Text(phoneNumber)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .onAppear {
            loadUserData(for: identifier)
        }
    }

    // 根据 identifier 加载用户数据
    private func loadUserData(for identifier: String) {
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.hasSuffix("_nickname"), let savedNickname = value as? String {
                let baseKey = key.replacingOccurrences(of: "_nickname", with: "")
                let savedPhoneNumber = UserDefaults.standard.string(forKey: "\(baseKey)_phoneNumber") ?? ""
                let savedEmail = UserDefaults.standard.string(forKey: "\(baseKey)_email") ?? ""

                if identifier == savedNickname || identifier == savedPhoneNumber {
                    // 找到匹配的数据
                    self.nickname = savedNickname
                    self.phoneNumber = savedPhoneNumber
                    self.storedEmail = savedEmail
                    break
                }
            }
        }
    }
}
