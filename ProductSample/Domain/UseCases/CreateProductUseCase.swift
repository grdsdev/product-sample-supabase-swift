//
//  CreateProductUseCase.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import Foundation
import Supabase

protocol CreateProductUseCase: UseCase<CreateProductParams, Task<Void, Error>> {}

struct CreateProductUseCaseImpl: CreateProductUseCase {
  let db: PostgrestClient
  let auth: GoTrueClient
  let productImageStorageRepository: ProductImageStorageRepository

  func execute(input: CreateProductParams) -> Task<Void, Error> {
    Task {
      let ownerId = try await auth.session.user.id

      var imageFilePath: String?

      if let image = input.image {
        imageFilePath = try await productImageStorageRepository.uploadImage(image)
      }

      let product = InsertProductDto(
        name: input.name, price: input.price, image: imageFilePath, ownerId: ownerId
      )

      try await db.from("products").insert(product).execute()
    }
  }

  private struct InsertProductDto: Encodable {
    let name: String
    let price: Double
    let image: String?
    let ownerId: UserID
  }
}

extension Dependencies {
  static let createProductUseCase: any CreateProductUseCase = CreateProductUseCaseImpl(
    db: supabase.database,
    auth: supabase.auth,
    productImageStorageRepository: productImageStorageRepository
  )
}
