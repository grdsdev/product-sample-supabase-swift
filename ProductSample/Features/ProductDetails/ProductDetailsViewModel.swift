//
//  ProductDetailsViewModel.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import PhotosUI
import Supabase
import SwiftUI
import XCTestDynamicOverlay

@MainActor
final class ProductDetailsViewModel: ObservableObject {
  private let productId: Product.ID?

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
    // TODO: Load the product from Supabase using provided productId.
  }

  func saveButtonTapped() async -> Bool {
    // TODO: Implement adding/updating the product in Supabase.
    return true
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
