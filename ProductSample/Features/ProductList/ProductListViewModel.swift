//
//  ProductListViewModel.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import SwiftUI

@MainActor
final class ProductListViewModel: ObservableObject {
  private let productImageStorageRepository: any ProductImageStorageRepository

  @Published var productImages: [Product.ID: ProductImage] = [:]
  @Published var products: [Product] = []
  @Published var isLoading = false
  @Published var error: Error?

  let onProductTapped: (Product) -> Void

  init(
    productImageStorageRepository: any ProductImageStorageRepository =
      ProductImageStorageRepositoryImpl(storage: supabase.storage),
    onProductTapped: @escaping (Product) -> Void
  ) {
    self.productImageStorageRepository = productImageStorageRepository
    self.onProductTapped = onProductTapped
  }

  func loadProducts() async {
    if isLoading {
      return
    }

    isLoading = true
    defer { isLoading = false }

    do {
      products = try await getProducts()
      loadProductImages()
      error = nil
    } catch {
      self.error = error
    }
  }

  func didSwipeToDelete(_ indexes: IndexSet) async {
    for index in indexes {
      let product = products[index]
      await removeItem(product: product)
    }
  }

  func didTapProduct(_ product: Product) {
    onProductTapped(product)
  }

  private func removeItem(product: Product) async {
    products.removeAll { $0.id == product.id }

    do {
      error = nil
      try await deleteProduct(id: product.id)
    } catch {
      self.error = error
    }

    await loadProducts()
  }

  private func loadProductImages() {
    Task {
      do {
        let productImages = try await withThrowingTaskGroup(
          of: (Product.ID, ProductImage)?.self
        ) { group in
          for product in products {
            guard let imageKey = product.image else {
              continue
            }

            group.addTask {
              guard
                let data = try? await self.productImageStorageRepository.downloadImage(imageKey),
                let image = ProductImage(data: data)
              else {
                return nil
              }
              return (product.id, image)
            }
          }

          return
            try await group
            .compactMap { $0 }
            .reduce(into: [Product.ID: ProductImage]()) {
              $0[$1.0] = $1.1
            }
        }

        self.productImages = productImages
      } catch {
        debugPrint("Error loading product images, \(error)")
      }
    }
  }

  private func getProducts() async throws -> [Product] {
    // TODO: Fetch all products from Supabase.
    return []
  }

  private func deleteProduct(id: Product.ID) async throws {
    // TODO: Delete product with `id`.
  }
}
