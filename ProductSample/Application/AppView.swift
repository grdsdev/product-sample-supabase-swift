//
//  AppView.swift
//  ProductSample
//
//  Created by Guilherme Souza on 18/10/23.
//

import OSLog
import SwiftUI
import SwiftUINavigation

@MainActor
final class AppViewModel: ObservableObject {
  private let logger = Logger.make(category: "AppViewModel")

  enum AuthState {
    case main(MainViewModel)
    case auth(AuthViewModel)
  }

  @Published var authState: AuthState?
  private var authStateListenerTask: Task<Void, Never>?

  init(authenticationRepository: AuthenticationRepository = Dependencies.authenticationRepository) {
    authStateListenerTask = Task {
      for await state in await authenticationRepository.authStateListener() {
        logger.debug("auth state changed: \(String(describing: state))")

        if Task.isCancelled {
          logger.debug("auth state task cancelled, returning.")
          return
        }

        switch state {
        case .signedIn: self.authState = .main(.init())
        case .signedOut: self.authState = .auth(.init())
        }
      }
    }
  }

  deinit {
    authStateListenerTask?.cancel()
  }
}

struct AppView: View {
  @StateObject var model = AppViewModel()

  var body: some View {
    NavigationStack {
      switch model.authState {
      case let .main(model):
        MainView(model: model)
      case let .auth(model):
        AuthView(model: model)
      case .none:
        ProgressView()
      }
    }
  }
}
