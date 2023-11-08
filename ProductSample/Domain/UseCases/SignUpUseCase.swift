//
//  SignUpUseCase.swift
//  ProductSample
//
//  Created by Guilherme Souza on 21/10/23.
//

import Foundation
import GoTrue

enum SignUpResult {
  case success
  case requiresConfirmation
}

protocol SignUpUseCase: UseCase<Credentials, Task<SignUpResult, Error>> {}

struct SignUpUseCaseImpl: SignUpUseCase {
  let auth: GoTrueClient

  func execute(input: Credentials) -> Task<SignUpResult, Error> {
    Task {
      // This redirect to URL should match the one configured in Supabase's Dashboard.
      let redirectToURL = URL(string: "dev.grds.supabase.product-sample://")

      let response = try await auth.signUp(
        email: input.email,
        password: input.password,
        redirectTo: redirectToURL
      )
      if case .session = response {
        return .success
      }
      return .requiresConfirmation
    }
  }
}

extension Dependencies {
  static let signUpUseCase: any SignUpUseCase = SignUpUseCaseImpl(
    auth: supabase.auth
  )
}
