//
//  DeleteProductUseCase.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import Foundation
import PostgREST

protocol DeleteProductUseCase: UseCase<Product.ID, Task<Void, Error>> {}

struct DeleteProductUseCaseImpl: DeleteProductUseCase {
  let db: PostgrestClient

  func execute(input: Product.ID) -> Task<Void, Error> {
    Task {
      try await db.from("products")
        .delete()
        .eq("id", value: input)
        .execute()
        .value
    }
  }
}

extension Dependencies {
  static let deleteProductUseCase: any DeleteProductUseCase = DeleteProductUseCaseImpl(
    db: supabase.database
  )
}
