//
//  ProductListViewModel.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import OSLog
import SwiftUI
import XCTestDynamicOverlay

@MainActor
final class ProductListViewModel: ObservableObject {
  private let logger = Logger.make(category: "ProductListViewModel")

  private var productImageStorageRepository: any ProductImageStorageRepository {
    Dependencies.productImageStorageRepository
  }

  @Published var productImages: [Product.ID: ProductImage] = [:]
  @Published var products: [Product] = []
  @Published var isLoading = false
  @Published var error: Error?

  var onProductTapped: (Product) -> Void = unimplemented(
    "\(ProductListViewModel.self).onProductTapped")

  func loadProducts() async {
    isLoading = true
    defer { isLoading = false }

    do {
      products = try await getProducts()
      logger.info("Products loaded.")
      loadProductImages()
      error = nil
    } catch {
      logger.error("Error loading products: \(error)")
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
      logger.error("Failed to remove product: \(product.id) error: \(error)")
      self.error = error
    }

    await loadProducts()
  }

  private func loadProductImages() {
    Task {
      do {
        let productImages = try await withThrowingTaskGroup(of: (Product.ID, ProductImage)?.self) {
          group in
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
        logger.error("Error loading product images, \(error)")
      }
    }
  }

  private func getProducts() async throws -> [Product] {
    try await supabase.database
      .from("products")
      .select()
      .execute()
      .value
  }

  private func deleteProduct(id: Product.ID) async throws {
    try await supabase.database
      .from("products")
      .delete()
      .eq("id", value: id)
      .execute()
  }
}
