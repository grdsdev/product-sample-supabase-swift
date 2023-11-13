//
//  AuthViewModel.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import Foundation
import OSLog
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
  private let logger = Logger.make(category: "AuthViewModel")

  @Published var email = ""
  @Published var password = ""

  enum Status {
    case requiresConfirmation
    case error(Error)
  }

  @Published var status: Status?

  func signInButtonTapped() async {
    do {
      try await supabase.auth.signIn(email: email, password: password)
      status = nil
    } catch {
      status = .error(error)
      logger.error("Error signing in: \(error)")
    }
  }

  func signUpButtonTapped() async {
    do {
      // This redirect to URL should match the one configured in Supabase's Dashboard.
      let redirectToURL = URL(string: "dev.grds.supabase.product-sample://")

      let response = try await supabase.auth.signUp(
        email: email,
        password: password,
        redirectTo: redirectToURL
      )

      if case .session = response {
        status = nil
      } else {
        status = .requiresConfirmation
      }
    } catch {
      status = .error(error)
      logger.error("Error signing up: \(error)")
    }
  }

  func signInWithApple(_ result: Result<SIWACredentials, Error>) async {
    do {
      let credentials = try result.get()
      try await supabase.auth.signInWithIdToken(
        credentials: OpenIDConnectCredentials(
          provider: .apple,
          idToken: credentials.identityToken,
          nonce: credentials.nonce
        )
      )
    } catch {
      logger.error("Error signing in with apple: \(error)")
    }
  }

  func onOpenURL(_ url: URL) async {
    do {
      logger.debug("Retrieve session from url: \(url)")
      try await supabase.auth.session(from: url)
      await signInButtonTapped()
      status = nil
    } catch {
      status = .error(error)
      logger.error("Error creating session from url: \(error)")
    }
  }
}
