//
//  ProductImageLocalCache.swift
//  ProductSample
//
//  Created by Guilherme Souza on 09/11/23.
//

import Foundation

protocol ProductImageLocalCache: Sendable {
  func load(at key: ImageKey) throws -> Data?
  func store(_ data: Data, at key: ImageKey) throws
}

struct ProductImageLocalCacheImpl: ProductImageLocalCache {
  func load(at key: ImageKey) throws -> Data? {
    let fileManager = FileManager.default
    let localImageURL = try cacheURL().appending(path: key.fileName)

    if fileManager.fileExists(atPath: localImageURL.path()) {
      return try Data(contentsOf: localImageURL)
    }

    return nil
  }

  func store(_ data: Data, at key: ImageKey) throws {
    let localImageURL = try cacheURL().appending(path: key.fileName)
    try data.write(to: localImageURL)
  }

  private func cacheURL() throws -> URL {
    let fileManager = FileManager.default

    let url = try fileManager.url(
      for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true
    )
    .appending(path: "dev.grds.supabase.product-sample")
    .appending(path: "product-images")

    if !fileManager.fileExists(atPath: url.path()) {
      try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }

    return url
  }
}
