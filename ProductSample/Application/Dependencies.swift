//
//  Dependencies.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: Config.SUPABASE_URL)!,
  supabaseKey: Config.SUPABASE_ANON_KEY
)

enum Dependencies {
  static let productImageLocalCache: any ProductImageLocalCache = ProductImageLocalCacheImpl()

  static let productImageStorageRepository: any ProductImageStorageRepository =
    ProductImageStorageRepositoryImpl(storage: supabase.storage)
}
