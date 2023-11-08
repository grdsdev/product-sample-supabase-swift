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
    case authenticated(ProductListViewModel)
    case notAuthenticated(AuthViewModel)
  }

  enum Destination {
    case productDetail(ProductDetailsViewModel)
    case addProduct(ProductDetailsViewModel)
    case settings(SettingsViewModel)
  }

  @Published var destination: Destination? {
    didSet {
      bindDestination()
    }
  }
  @Published var authState: AuthState? {
    didSet {
      bindAuthState()
    }
  }

  private var authStateListenerTask: Task<Void, Never>?

  init(authenticationRepository: AuthenticationRepository = Dependencies.supabase.auth) {
    authStateListenerTask = Task {
      for await state in await authenticationRepository.authStateListener() {
        logger.debug("auth state changed: \(String(describing: state))")

        if Task.isCancelled {
          logger.debug("auth state task cancelled, returning.")
          return
        }

        switch state {
        case .signedIn: self.authState = .authenticated(.init())
        case .signedOut: self.authState = .notAuthenticated(.init())
        }
      }
    }
  }

  deinit {
    authStateListenerTask?.cancel()
  }

  func settingsButtonTapped() {
    destination = .settings(SettingsViewModel())
  }

  func addProductButtonTapped() {
    destination = .addProduct(ProductDetailsViewModel(productId: nil))
  }

  private func bindDestination() {
    switch destination {
    case .productDetail(let productDetailsViewModel), .addProduct(let productDetailsViewModel):
      productDetailsViewModel.onCompletion = { [weak self] _ in
        Task {
          if case let .authenticated(model) = self?.authState {
            await model.loadProducts()
          }
        }
      }

    default: break
    }
  }

  private func bindAuthState() {
    switch authState {
    case .authenticated(let productListViewModel):
      productListViewModel.onProductTapped = { [weak self] in
        self?.destination = .productDetail(ProductDetailsViewModel(productId: $0.id))
      }

    default: break
    }
  }
}

struct AppView: View {
  @StateObject var model = AppViewModel()

  var body: some View {
    NavigationStack {
      switch model.authState {
      case let .authenticated(model):
        authenticatedView(model: model)
      case let .notAuthenticated(model):
        notAuthenticatedView(model: model)
      case .none:
        ProgressView()
      }
    }
  }

  func authenticatedView(model: ProductListViewModel) -> some View {
    ProductListView(model: model)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            self.model.settingsButtonTapped()
          } label: {
            Label("Settings", systemImage: "gear")
          }
        }
        ToolbarItem(placement: .primaryAction) {
          Button {
            self.model.addProductButtonTapped()
          } label: {
            Label("Add", systemImage: "plus")
          }
        }
      }
      .navigationDestination(
        unwrapping: self.$model.destination, case: /AppViewModel.Destination.productDetail
      ) { $model in
        ProductDetailsView(model: model)
      }
      .sheet(unwrapping: self.$model.destination, case: /AppViewModel.Destination.addProduct) {
        $model in
        NavigationStack {
          ProductDetailsView(model: model)
        }
      }
      .sheet(unwrapping: self.$model.destination, case: /AppViewModel.Destination.settings) {
        $model in
        NavigationStack {
          SettingsView(model: model)
        }
      }
  }

  func notAuthenticatedView(model: AuthViewModel) -> some View {
    AuthView(model: model)
  }
}
