import SwiftUI

struct RegisterView: View {
    @State private var nickname: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var registrationSuccess: Bool = false
    @State private var emailError: String? = nil  // 用于显示邮箱格式错误信息
    @State private var nicknameExists: Bool = false  // 昵称是否已存在
    @State private var phoneNumberExists: Bool = false  // 手机号码是否已存在
    @State private var emailExists: Bool = false  // 邮箱是否已存在
    @State private var missingFieldsError: String? = nil  // 用于显示缺少字段的错误信息
    @Environment(\.presentationMode) var presentationMode // 用于控制视图返回
    @ObservedObject private var keyboardResponder = KeyboardResponder() // 监听键盘

    var body: some View {
        VStack {
            Text("Create Account")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 60)
            
            // 昵称输入框
            TextField("Nickname", text: $nickname)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .onChange(of: nickname) { newNickname in
                    // 检查昵称是否已存在
                    nicknameExists = isNicknameExists(newNickname)
                }
            
            // 昵称已存在的提示
            if nicknameExists {
                Text("Nickname already exists")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
                    .padding(.horizontal, 40)
            }
            
            // 手机号码输入框
            TextField("Phone Number", text: $phoneNumber)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .keyboardType(.phonePad)
                .padding(.horizontal, 40)
                .padding(.top, 10)
                .onChange(of: phoneNumber) { newPhoneNumber in
                    // 检查手机号码是否已存在
                    phoneNumberExists = isPhoneNumberExists(newPhoneNumber)
                }
            
            // 手机号码已存在的提示
            if phoneNumberExists {
                Text("Phone number already exists")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
                    .padding(.horizontal, 40)
            }
            
            // 邮箱输入框
            TextField("Email", text: $email)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .keyboardType(.emailAddress)
                .padding(.horizontal, 40)
                .padding(.top, 10)
                .onChange(of: email) { newEmail in
                    // 检查邮箱是否已存在
                    emailExists = isEmailExists(newEmail)
                }
            
            // 邮箱已存在的提示
            if emailExists {
                Text("Email already exists")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
                    .padding(.horizontal, 40)
            }
            
            // 邮箱格式错误提示
            if let error = emailError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
                    .padding(.horizontal, 40)
            }
            
            // 密码输入框
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
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            .padding(.horizontal, 40)
            .padding(.top, 10)
            
            // 必填项提示
            if let missingFieldsError = missingFieldsError {
                Text(missingFieldsError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
                    .padding(.horizontal, 40)
            }
            
            // 注册按钮
            Button(action: {
                // 检查所有字段是否已填
                if nickname.isEmpty || phoneNumber.isEmpty || email.isEmpty || password.isEmpty {
                    missingFieldsError = "All fields are required"
                    return
                }
                
                // 检查邮箱格式和昵称、手机号码、邮箱唯一性
                if !nicknameExists && !phoneNumberExists && !emailExists && isValidEmail(email) {
                    emailError = nil
                    missingFieldsError = nil  // 清除错误消息
                    saveUserData(nickname: nickname, phoneNumber: phoneNumber, email: email, password: password)
                    registrationSuccess = true
                    
                    // 模拟延迟1秒后返回上一个页面
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        presentationMode.wrappedValue.dismiss() // 返回到之前的页面
                    }
                } else {
                    if !isValidEmail(email) {
                        emailError = "Invalid email format"
                    }
                }
                
            }) {
                Text("Register")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 80, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.top, 30)
            }
            
            // 注册成功提示
            if registrationSuccess {
                Text("Registration Successful")
                    .foregroundColor(.green)
                    .padding(.top, 20)
            }
            
            Spacer()
        }
        .padding(.bottom, keyboardResponder.currentHeight) // 动态调整底部填充
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.easeOut(duration: 0.3), value: keyboardResponder.currentHeight) // 平滑动画
    }
    
    // 保存用户数据
    func saveUserData(nickname: String, phoneNumber: String, email: String, password: String) {
        let uniqueKey = "user_\(email)"  // 以邮箱为唯一标识符
        UserDefaults.standard.set(nickname, forKey: "\(uniqueKey)_nickname")
        UserDefaults.standard.set(phoneNumber, forKey: "\(uniqueKey)_phoneNumber")
        UserDefaults.standard.set(email, forKey: "\(uniqueKey)_email")
        UserDefaults.standard.set(password, forKey: "\(uniqueKey)_password")
        print("User data saved: \(nickname), \(phoneNumber), \(email), \(password)")
    }
    
    // 验证邮箱格式
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // 检查昵称是否已存在
    func isNicknameExists(_ nickname: String) -> Bool {
        return UserDefaults.standard.dictionaryRepresentation().contains { key, value in
            key.hasSuffix("_nickname") && (value as? String == nickname)
        }
    }
    
    // 检查手机号码是否已存在
    func isPhoneNumberExists(_ phoneNumber: String) -> Bool {
        return UserDefaults.standard.dictionaryRepresentation().contains { key, value in
            key.hasSuffix("_phoneNumber") && (value as? String == phoneNumber)
        }
    }
    
    // 检查邮箱是否已存在
    func isEmailExists(_ email: String) -> Bool {
        return UserDefaults.standard.dictionaryRepresentation().contains { key, value in
            key.hasSuffix("_email") && (value as? String == email)
        }
    }
}
