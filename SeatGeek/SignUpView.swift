import SwiftUI

struct SignUpView: View {
    @State private var email:String = ""
    @State private var password:String = ""
    @State private var signUpView:Bool = false
    @State private var name:String = ""
    @FocusState private var isFocused:Bool
    @AppStorage("isLoggedIn") var isLoggedIn:Bool = false
    @EnvironmentObject var authHelper:FirebaseAuthController

    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Text("Sign Up to SeatGeek")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.bottom, 50)
                    Group {
                        CustomTextField(text: $name, placeholder: "Enter Name")
                            .focused($isFocused)

                        CustomTextField(text: $email, placeholder: "Enter Email")
                            .focused($isFocused)
                            .textInputAutocapitalization(.none)

                        CustomTextField(text: $password, placeholder: "Enter Password", isSecure: true)
                            .focused($isFocused)
                    }.textInputAutocapitalization(.never)
                    Group {
                        Spacer()
                            .frame(height: 60)
                        Button("Sign Up") {
                            authHelper.signUp(name: name, email: email, password: password)
                            isLoggedIn = true
                        }
                        .buttonStyle(GrowingButton(width: 320))

                        Spacer()
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
