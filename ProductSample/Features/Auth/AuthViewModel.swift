//
//  AuthViewModel.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
  @Published var email = ""
  @Published var password = ""

  enum Status {
    case requiresConfirmation
    case error(Error)
  }

  @Published var status: Status?

  func signInButtonTapped() async {
    // TODO: Implement sign in using email and password.
  }

  func signUpButtonTapped() async {
    // TODO: Implement sign up using email and password.
  }

  func signInWithApple(_ result: Result<SIWACredentials, Error>) async {
    // TODO: Implement Sign in with Apple using signInWithIdToken method.
  }

  func onOpenURL(_ url: URL) async {
    // TODO: Try to initialize a session from the URL.
  }
}
