//
//  GetProfileUseCase.swift
//  ProductSample
//
//  Created by Guilherme Souza on 08/11/23.
//

import Foundation
import GoTrue

protocol GetProfileUseCase: UseCase<Void, Task<User, Error>> {}

struct GetProfileUseCaseImpl: GetProfileUseCase {
  let auth: GoTrueClient

  func execute(input: ()) -> Task<User, Error> {
    Task {
      try await auth.user()
    }
  }
}

extension Dependencies {
  static let getProfileUseCase: any GetProfileUseCase = GetProfileUseCaseImpl(auth: supabase.auth)
}
