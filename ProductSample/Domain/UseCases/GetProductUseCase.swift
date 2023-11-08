//
//  GetProductUseCase.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import Foundation
import PostgREST

protocol GetProductUseCase: UseCase<Product.ID, Task<Product, Error>> {}

struct GetProductUseCaseImpl: GetProductUseCase {
  let db: PostgrestClient

  func execute(input: Product.ID) -> Task<Product, Error> {
    Task {
      try await db.from("products")
        .select()
        .eq("id", value: input)
        .single()
        .execute()
        .value
    }
  }
}

extension Dependencies {
  static let getProductUseCase: any GetProductUseCase = GetProductUseCaseImpl(db: supabase.database)
}
