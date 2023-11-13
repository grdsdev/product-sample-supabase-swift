//
//  MainView.swift
//  ProductSample
//
//  Created by Guilherme Souza on 09/11/23.
//

import SwiftUI
import SwiftUINavigation

@MainActor
final class MainViewModel: ObservableObject {
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

  let productListViewModel = ProductListViewModel()

  init() {
    productListViewModel.onProductTapped = { [weak self] in
      self?.destination = .productDetail(ProductDetailsViewModel(productId: $0.id))
    }
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
          await self?.productListViewModel.loadProducts()
        }
      }

    default: break
    }
  }

}

struct MainView: View {
  @ObservedObject var model: MainViewModel

  var body: some View {
    ProductListView(model: model.productListViewModel)
      .navigationTitle("Products")
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
        unwrapping: self.$model.destination, case: /MainViewModel.Destination.productDetail
      ) { $model in
        ProductDetailsView(model: model)
          .navigationTitle("Edit Product")
      }
      .sheet(unwrapping: self.$model.destination, case: /MainViewModel.Destination.addProduct) {
        $model in
        NavigationStack {
          ProductDetailsView(model: model)
            .navigationTitle("Add Product")
        }
      }
      .sheet(unwrapping: self.$model.destination, case: /MainViewModel.Destination.settings) {
        $model in
        NavigationStack {
          SettingsView(model: model)
        }
      }
  }
}
