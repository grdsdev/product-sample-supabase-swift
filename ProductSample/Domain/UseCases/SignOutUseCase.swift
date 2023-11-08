//
//  SignOutUseCase.swift
//  ProductSample
//
//  Created by Guilherme Souza on 08/11/23.
//

import Foundation
import GoTrue

protocol SignOutUseCase: UseCase<Void, Task<Void, Never>> {}

struct SignOutUseCaseImpl: SignOutUseCase {
  let auth: GoTrueClient

  func execute(input: ()) -> Task<(), Never> {
    Task {
      try? await auth.signOut()
    }
  }
}

extension Dependencies {
  static let signOutUseCase: any SignOutUseCase = SignOutUseCaseImpl(
    auth: supabase.auth
  )
}
