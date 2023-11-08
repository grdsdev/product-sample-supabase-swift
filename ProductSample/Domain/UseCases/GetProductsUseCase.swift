//
//  GetProductsUseCase.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import Foundation
import PostgREST

protocol GetProductsUseCase: UseCase<Void, Task<[Product], Error>> {}

struct GetProductsUseCaseImpl: GetProductsUseCase {
  let db: PostgrestClient

  func execute(input _: ()) -> Task<[Product], Error> {
    Task {
      try await db.from("products").select().execute().value
    }
  }
}

extension Dependencies {
  static let getProductsUseCase: any GetProductsUseCase = GetProductsUseCaseImpl(
    db: supabase.database
  )
}
