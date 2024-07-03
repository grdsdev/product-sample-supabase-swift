//
//  ProductDetailsViewModel.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import OSLog
import PhotosUI
import Supabase
import SwiftUI
import XCTestDynamicOverlay

@MainActor
final class ProductDetailsViewModel: ObservableObject {
  private let logger = Logger.make(category: "ProductDetailsViewModel")

  private let productId: Product.ID?

  private var productImageStorage: any ProductImageStorageRepository {
    Dependencies.productImageStorageRepository
  }

  @Published var name: String = ""
  @Published var price: Double = 0

  enum ImageSource {
    case remote(ProductImage)
    case local(ProductImage)

    var productImage: ProductImage {
      switch self {
      case let .remote(image), let .local(image): image
      }
    }
  }

  @Published var imageSelection: PhotosPickerItem? {
    didSet {
      if let imageSelection {
        Task {
          await loadTransferable(from: imageSelection)
        }
      }
    }
  }

  @Published var imageSource: ImageSource?
  @Published var isSavingProduct = false
  @Published var isDownloadingImage = false

  let onCompletion: (Bool) -> Void

  init(productId: Product.ID?, onCompletion: @escaping (Bool) -> Void) {
    self.productId = productId
    self.onCompletion = onCompletion
  }

  func loadProductIfNeeded() async {
    guard let productId else { return }

    do {
      let product: Product = try await supabase.database
        .from("products")
        .select()
        .eq("id", value: productId)
        .single()
        .execute()
        .value

      name = product.name
      price = product.price

      if let image = product.image {
        isDownloadingImage = true
        defer { isDownloadingImage = false }
        let data = try await productImageStorage.downloadImage(image)
        imageSource = ProductImage(data: data).map(ImageSource.remote)
      }
    } catch {
      logger.error("Error loading product: \(error)")
    }
  }

  func saveButtonTapped() async -> Bool {
    isSavingProduct = true
    defer { isSavingProduct = false }

    do {
      var imageFilePath: String?

      if case let .local(image) = imageSource {
        let image = ImageUploadParams(
          fileName: UUID().uuidString,
          fileExtension: imageSelection?.supportedContentTypes.first?.preferredFilenameExtension,
          mimeType: imageSelection?.supportedContentTypes.first?.preferredMIMEType,
          data: image.data
        )

        imageFilePath = try await productImageStorage.uploadImage(image)
      }

      if let productId {
        logger.info("Will update product: \(productId)")

        var params: [String: AnyJSON] = [
          "name": .string(name),
          "price": .double(price),
        ]

        if let imageFilePath {
          params["image"] = .string(imageFilePath)
        }

        try await supabase.database.from("products")
          .update(params)
          .eq("id", value: productId)
          .execute()
      } else {
        logger.info("Will add product")

        let currentUserId = try await supabase.auth.session.user.id

        let product = InsertProduct(
          name: name, price: price, image: imageFilePath, ownerId: currentUserId
        )

        try await supabase.database.from("products").insert(product).execute()
      }

      logger.error("Save succeeded")
      onCompletion(true)
      return true
    } catch {
      logger.error("Save failed: \(error)")
      onCompletion(false)
      return false
    }
  }

  private func loadTransferable(from imageSelection: PhotosPickerItem) async {
    if let image = try? await imageSelection.loadTransferable(type: ProductImage.self) {
      imageSource = .local(image)
    }
  }
}

struct ProductImage: Transferable, Equatable {
  let image: Image
  let data: Data

  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(importedContentType: .image) { data in
      guard let image = ProductImage(data: data) else {
        throw TransferError.importFailed
      }

      return image
    }
  }
}

extension ProductImage {
  init?(data: Data) {
    guard let uiImage = UIImage(data: data) else {
      return nil
    }

    let image = Image(uiImage: uiImage)
    self.init(image: image, data: data)
  }
}

enum TransferError: Error {
  case importFailed
}
