//
//  Auth.swift
//  ProductSample
//
//  Created by Guilherme Souza on 21/10/23.
//

import Foundation
import Supabase

struct SIWACredentials {
  let identityToken: String
  let nonce: String
}

struct Product: Identifiable, Decodable, Hashable {
  let id: String
  let name: String
  let price: Double
  let image: ImageKey?
}

struct ImageKey: RawRepresentable, Decodable, Hashable {
  var rawValue: String
}

struct ImageUploadParams {
  let fileName: String
  let fileExtension: String?
  let mimeType: String?
  let data: Data
}

struct InsertProduct: Encodable {
  let name: String
  let price: Double
  let image: String?
  let ownerId: User.ID

  enum CodingKeys: String, CodingKey {
    case name
    case price
    case image
    case ownerId = "owner_id"
  }
}
