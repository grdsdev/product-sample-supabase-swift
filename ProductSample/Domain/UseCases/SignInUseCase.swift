//
//  SignInUseCase.swift
//  ProductSample
//
//  Created by Guilherme Souza on 20/10/23.
//

import Foundation

protocol SignInUseCase: UseCase<Credentials, Task<Void, Error>> {}

struct SignInUseCaseImpl: SignInUseCase {
  let repository: AuthenticationRepository

  func execute(input: Credentials) -> Task<Void, Error> {
    Task {
      try await repository.signIn(email: input.email, password: input.password)
    }
  }
}

protocol SignInWithAppleUseCase: UseCase<SIWACredentials, Task<Void, Error>> {}

struct SignInWithAppleUseCaseImpl: SignInWithAppleUseCase {
  let repository: AuthenticationRepository

  func execute(input: SIWACredentials) -> Task<Void, Error> {
    Task {
      try await repository.signInWithApple(credentials: input)
    }
  }
}
