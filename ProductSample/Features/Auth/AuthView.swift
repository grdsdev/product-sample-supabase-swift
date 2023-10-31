//
//  AuthView.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import SwiftUI

struct AuthView: View {
  @ObservedObject var model: AuthViewModel

  var body: some View {
    Form {
      Section {
        TextField("Email", text: $model.email)
          .keyboardType(.emailAddress)
          .textContentType(.emailAddress)
          .autocorrectionDisabled()
          .textInputAutocapitalization(.never)
        SecureField("Password", text: $model.password)
          .textContentType(.password)
          .autocorrectionDisabled()
          .textInputAutocapitalization(.never)
      }

      Section {
        AsyncButton("Sign in") {
          await model.signInButtonTapped()
        }
        AsyncButton("Sign up") {
          await model.signUpButtonTapped()
        }
        SupabaseSignInWithAppleButton { result in
          Task {
            await model.signInWithApple(result)
          }
        }
      }

      if let status = model.status {
        switch status {
        case let .error(error):
          Text(error.localizedDescription).font(.callout).foregroundStyle(.red)
        case .requiresConfirmation:
          Text(
            "Account created, but it requires confirmation, click the verification link sent to the registered email."
          )
          .font(.callout)
        }
      }
    }
    .navigationTitle("Authenticate")
    .onOpenURL { url in
      Task { await model.onOpenURL(url) }
    }
  }
}
