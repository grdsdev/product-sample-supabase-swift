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

  private let signInUseCase: any SignInUseCase
  private let signInWithAppleUseCase: any SignInWithAppleUseCase
  private let signUpUseCase: any SignUpUseCase

  @Published var email = ""
  @Published var password = ""

  enum Status {
    case requiresConfirmation
    case error(Error)
  }

  @Published var status: Status?

  init(
    signInUseCase: any SignInUseCase = Dependencies.signInUseCase,
    signInWithAppleUseCase: any SignInWithAppleUseCase = Dependencies.signInWithAppleUseCase,
    signUpUseCase: any SignUpUseCase = Dependencies.signUpUseCase
  ) {
    self.signInUseCase = signInUseCase
    self.signInWithAppleUseCase = signInWithAppleUseCase
    self.signUpUseCase = signUpUseCase
  }

  func signInButtonTapped() async {
    do {
      try await signInUseCase.execute(input: .init(email: email, password: password)).value
      status = nil
    } catch {
      status = .error(error)
      logger.error("Error signing in: \(error)")
    }
  }

  func signUpButtonTapped() async {
    do {
      let result = try await signUpUseCase.execute(input: .init(email: email, password: password))
        .value
      if result == .requiresConfirmation {
        status = .requiresConfirmation
      } else {
        status = nil
      }
    } catch {
      status = .error(error)
      logger.error("Error signing up: \(error)")
    }
  }

  func signInWithApple(_ result: Result<SIWACredentials, Error>) async {
    do {
      let credentials = try result.get()
      try await signInWithAppleUseCase.execute(input: credentials).value
    } catch {
      logger.error("Error signing in with apple: \(error)")
    }
  }

  func onOpenURL(_ url: URL) async {
    do {
      logger.debug("Retrieve session from url: \(url)")
      try await Dependencies.supabase.auth.session(from: url)
      await signInButtonTapped()
      status = nil
    } catch {
      status = .error(error)
      logger.error("Error creating session from url: \(error)")
    }
  }
}
