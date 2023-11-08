//
//  AuthStateChangeHandler.swift
//  ProductSample
//
//  Created by Guilherme Souza on 08/11/23.
//

import Foundation
import GoTrue

protocol AuthStateChangeHandler {
  func onAuthStateChange() async -> AsyncStream<AuthenticationState>
}

extension GoTrueClient: AuthStateChangeHandler {
  func onAuthStateChange() async -> AsyncStream<AuthenticationState> {
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
