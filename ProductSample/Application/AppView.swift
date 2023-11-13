//
//  AppView.swift
//  ProductSample
//
//  Created by Guilherme Souza on 18/10/23.
//

import OSLog
import Supabase
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

  init() {
    authStateListenerTask = Task {
      for await state in await supabase.auth.onAuthStateChange() {
        logger.debug("auth state changed: \(String(describing: state))")

        if Task.isCancelled {
          logger.debug("auth state task cancelled, returning.")
          return
        }

        guard Set([.initialSession, .signedIn, .signedOut]).contains(state.event) else {
          continue
        }

        self.authState = state.session == nil ? .auth(.init()) : .main(.init())
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
