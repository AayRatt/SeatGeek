import SwiftUI

struct LoginView: View {
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var remember: Bool = false
  @State private var signUpView: Bool = false
  @FocusState private var isFocused: Bool
  @State private var showAlert: Bool = false
  @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
  @AppStorage("loggedUser") var loggedUser: String = ""
  @EnvironmentObject var authHelper: FirebaseAuthController

  var body: some View {
    NavigationStack {
      ZStack {
        Image("background")
          .ignoresSafeArea()

        VStack {
          Spacer()
          Group {
            Image("logo")
              .resizable()
              .frame(height: 220)
          }
          .font(.largeTitle)
          .foregroundColor(.white)
          .bold()
          .frame(width: 300)
          Group {
            CustomTextField(text: $email, placeholder: "Enter Email")
              .focused($isFocused)
              .textInputAutocapitalization(.none)

            CustomTextField(text: $password, placeholder: "Enter Password", isSecure: true)
              .focused($isFocused)
          }.textInputAutocapitalization(.never)

          //                    Toggle(isOn: $remember) {
          //                        Text("Remember Me")
          //                            .foregroundColor(.white)
          //                            .font(.title3)
          //                    }
          //                    .padding(.horizontal, 30)
          //                    .padding(.top, 15)

          Group {
            Spacer()
            Button("Login") {
              authHelper.signIn(email: email, password: password) { success, userEmail in
                if success {
                  print("User authenticated successfully.")
                  isLoggedIn = true
                  loggedUser = userEmail ?? ""

                } else {
                  print("Authentication failed.")
                  showAlert = true
                }
              }
            }
            .padding(.bottom, 25)
            .buttonStyle(GrowingButton(width: 320))
            .alert("Wrong Credentials", isPresented: $showAlert) {
              Button("Retry", role: .cancel) {}
            }
            Button("Sign Up") {
              signUpView = true
            }
            .buttonStyle(GrowingButton(width: 320))

            Spacer()
          }
        }
      }
      //            .toolbar {
      //                ToolbarItemGroup(placement: .keyboard) {
      //                    Spacer()
      //                    Button("Done") {
      //                        isFocused = false
      //                    }
      //                }
      //            }
      .navigationDestination(isPresented: $signUpView) {
        SignUpView()
      }
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}

extension View {
  func placeholder<Content: View>(
    when shouldShow: Bool,
    alignment: Alignment = .leading,
    @ViewBuilder placeholder: () -> Content
  ) -> some View {

    ZStack(alignment: alignment) {
      placeholder().opacity(shouldShow ? 1 : 0)
      self
    }
  }
}
