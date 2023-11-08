//
//  AuthenticationRepository.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import Foundation
import Supabase

protocol AuthenticationRepository: Sendable {
  var currentUserID: UUID { get async throws }

  func authStateListener() async -> AsyncStream<AuthenticationState>
  func signIn(email: String, password: String) async throws
  func signUp(email: String, password: String) async throws -> SignUpResult
  func signInWithApple(credentials: SIWACredentials) async throws
  func signOut() async
}

extension GoTrueClient: AuthenticationRepository {
  var currentUserID: UUID {
    get async throws {
      try await session.user.id
    }
  }

  func authStateListener() async -> AsyncStream<AuthenticationState> {
    await onAuthStateChange().compactMap { event, session in
      switch event {
      case .initialSession: session != nil ? AuthenticationState.signedIn : .signedOut
      case .signedIn: AuthenticationState.signedIn
      case .signedOut: AuthenticationState.signedOut
      case .passwordRecovery, .tokenRefreshed, .userUpdated, .userDeleted, .mfaChallengeVerified:
        nil
      }
    }
    .eraseToStream()
  }

  func signIn(email: String, password: String) async throws {
    _ = try await self.signIn(email: email, password: password) as Session
  }

  func signUp(email: String, password: String) async throws -> SignUpResult {
    // This redirect to URL should match the one configured in Supabase's Dashboard.
    let redirectToURL = URL(string: "dev.grds.supabase.product-sample://")

    let response = try await signUp(
      email: email,
      password: password,
      redirectTo: redirectToURL
    )
    if case .session = response {
      return .success
    }
    return .requiresConfirmation
  }

  func signInWithApple(credentials: SIWACredentials) async throws {
    try await signInWithIdToken(
      credentials: OpenIDConnectCredentials(
        provider: .apple,
        idToken: credentials.identityToken,
        nonce: credentials.nonce
      )
    )
  }

  @_disfavoredOverload
  func signOut() async {
    try? await self.signOut()
  }
}

extension AsyncStream {
  init<S: AsyncSequence>(_ sequence: S) where S.Element == Element {
    var iterator: S.AsyncIterator?
    self.init {
      if iterator == nil {
        iterator = sequence.makeAsyncIterator()
      }
      return try? await iterator?.next()
    }
  }
}

extension AsyncSequence {
  func eraseToStream() -> AsyncStream<Element> {
    AsyncStream(self)
  }
}
