//
//  SupabaseSignInWithAppleButton.swift
//  ProductSample
//
//  Created by Guilherme Souza on 31/10/23.
//

import AuthenticationServices
import CryptoKit
import Supabase
import SwiftUI

struct SupabaseSignInWithAppleButton: View {
  let onCompletion: (Result<SIWACredentials, Error>) -> Void
  @State private var nonce: String?

  var body: some View {
    SignInWithAppleButton { request in
      let nonce = randomString()
      self.nonce = nonce
      request.nonce = sha256(nonce)
      request.requestedScopes = [.email, .fullName]
    } onCompletion: { result in
      switch result {
      case .success(let authorization):
        guard
          let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
          let idToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) })
        else {
          return
        }

        let credentials = SIWACredentials(
          identityToken: idToken,
          nonce: nonce!
        )

        onCompletion(.success(credentials))

      case .failure(let error):
        onCompletion(.failure(error))

      }
    }
    .fixedSize()
  }
}

private func randomString(length: Int = 32) -> String {
  precondition(length > 0)
  var randomBytes = [UInt8](repeating: 0, count: length)
  let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
  if errorCode != errSecSuccess {
    fatalError(
      "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
    )
  }

  let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

  let nonce = randomBytes.map { byte in
    // Pick a random character from the set, wrapping around if needed.
    charset[Int(byte) % charset.count]
  }

  return String(nonce)
}

private func sha256(_ input: String) -> String {
  let inputData = Data(input.utf8)
  let hashedData = SHA256.hash(data: inputData)
  let hashString = hashedData.compactMap {
    String(format: "%02x", $0)
  }.joined()

  return hashString
}
