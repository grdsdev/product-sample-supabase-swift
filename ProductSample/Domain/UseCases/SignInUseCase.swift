//
//  SignInUseCase.swift
//  ProductSample
//
//  Created by Guilherme Souza on 20/10/23.
//

import Foundation
import GoTrue

protocol SignInUseCase: UseCase<Credentials, Task<Void, Error>> {}

struct SignInUseCaseImpl: SignInUseCase {
  let auth: GoTrueClient

  func execute(input: Credentials) -> Task<Void, Error> {
    Task {
      try await auth.signIn(email: input.email, password: input.password)
    }
  }
}

extension Dependencies {
  static let signInUseCase: any SignInUseCase = SignInUseCaseImpl(auth: supabase.auth)
}

protocol SignInWithAppleUseCase: UseCase<SIWACredentials, Task<Void, Error>> {}

struct SignInWithAppleUseCaseImpl: SignInWithAppleUseCase {
  let auth: GoTrueClient

  func execute(input: SIWACredentials) -> Task<Void, Error> {
    Task {
      try await auth.signInWithIdToken(
        credentials: OpenIDConnectCredentials(
          provider: .apple,
          idToken: input.identityToken,
          nonce: input.nonce
        )
      )
    }
  }
}

extension Dependencies {
  static let signInWithAppleUseCase: any SignInWithAppleUseCase = SignInWithAppleUseCaseImpl(
    auth: supabase.auth)
}
