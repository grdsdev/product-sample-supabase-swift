//
//  UpdateProductUseCase.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import Foundation
import Supabase

protocol UpdateProductUseCase: UseCase<UpdateProductParams, Task<Void, Error>> {}

struct UpdateProductUseCaseImpl: UpdateProductUseCase {
  let db: PostgrestClient
  let productImageStorageRepository: any ProductImageStorageRepository

  func execute(input: UpdateProductParams) -> Task<Void, Error> {
    Task {
      var imageFilePath: String?

      if let image = input.image {
        imageFilePath = try await productImageStorageRepository.uploadImage(image)
      }

      var params: [String: AnyJSON] = [:]

      if let name = input.name {
        params["name"] = .string(name)
      }

      if let price = input.price {
        params["price"] = .number(price)
      }

      if let imageFilePath {
        params["image"] = .string(imageFilePath)
      }

      if params.isEmpty {
        // nothing to update, just return.
        return
      }

      try await db.from("products")
        .update(params)
        .eq("id", value: input.id)
        .execute()
    }
  }
}

extension Dependencies {
  static let updateProductUseCase: any UpdateProductUseCase = UpdateProductUseCaseImpl(
    db: supabase.database,
    productImageStorageRepository: productImageStorageRepository
  )
}
