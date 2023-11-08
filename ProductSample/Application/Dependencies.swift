//
//  Dependencies.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import Foundation
import Supabase

enum Dependencies {
  static let supabase = SupabaseClient(
    supabaseURL: URL(string: Config.SUPABASE_URL)!,
    supabaseKey: Config.SUPABASE_ANON_KEY
  )

  // MARK: Repositories

  static let productImageStorageRepository: ProductImageStorageRepository =
    ProductImageStorageRepositoryImpl(storage: supabase.storage)

}
