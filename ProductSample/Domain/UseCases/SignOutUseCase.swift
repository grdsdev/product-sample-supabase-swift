//
//  SignOutUseCase.swift
//  ProductSample
//
//  Created by Guilherme Souza on 08/11/23.
//

import Foundation

protocol SignOutUseCase: UseCase<Void, Task<Void, Never>> {}

struct SignOutUseCaseImpl: SignOutUseCase {
  let authenticationRepository: AuthenticationRepository

  func execute(input: ()) -> Task<(), Never> {
    Task {
      await authenticationRepository.signOut()
    }
  }
}

extension Dependencies {
  static let signOutUseCase: any SignOutUseCase = SignOutUseCaseImpl(
    authenticationRepository: supabase.auth
  )
}
