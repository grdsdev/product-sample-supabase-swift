//
//  ProductImageStorageRepository.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import Foundation
import Storage

protocol ProductImageStorageRepository: Sendable {
  func uploadImage(_ params: ImageUploadParams) async throws -> String
  func downloadImage(_ key: ImageKey) async throws -> Data
}

struct ProductImageStorageRepositoryImpl: ProductImageStorageRepository {
  let storage: SupabaseStorageClient
  let localCache: any ProductImageLocalCache

  init(
    storage: SupabaseStorageClient,
    localCache: any ProductImageLocalCache = ProductImageLocalCacheImpl()
  ) {
    self.storage = storage
    self.localCache = localCache
  }

  func uploadImage(_ params: ImageUploadParams) async throws -> String {
    // TODO: Upload image to Supabase using params.
    return ""
  }

  func downloadImage(_ key: ImageKey) async throws -> Data {
    if let data = try? localCache.load(at: key) {
      return data
    }

    // TODO: Download image from Supabase and cache it locally.
    return Data()
  }
}

extension ImageKey {
  // we save product images in the format "bucket-id/image.png", but SupabaseStorage prefixes
  // the path with the bucket-id already so we must provide only the file name to the download
  // call, this is what lastPathComponent is doing below.
  var fileName: String {
    (rawValue as NSString).lastPathComponent
  }
}
