//
//  AppView.swift
//  ProductSample
//
//  Created by Guilherme Souza on 18/10/23.
//

import Supabase
import SwiftUI
import SwiftUINavigation

@MainActor
final class AppViewModel: ObservableObject {
  enum AuthState {
    case main(MainViewModel)
    case auth(AuthViewModel)
  }

  @Published var authState: AuthState?
  private var authStateListenerTask: Task<Void, Never>?

  init() {
    authStateListenerTask = Task {
      // TODO: Listen for auth state changes, and set authState property accordingly.
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
