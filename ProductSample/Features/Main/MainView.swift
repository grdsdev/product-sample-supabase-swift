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

  @Published var destination: Destination?

  private(set) lazy var productListViewModel = ProductListViewModel { [weak self] in
    let model = ProductDetailsViewModel(productId: $0.id) { [weak self] saved in
      self?.productSaved(saved)
    }

    self?.destination = .productDetail(model)
  }

  func settingsButtonTapped() {
    destination = .settings(SettingsViewModel())
  }

  func addProductButtonTapped() {
    destination = .addProduct(
      ProductDetailsViewModel(productId: nil) { [weak self] in
        self?.productSaved($0)
      }
    )
  }

  private func productSaved(_ saved: Bool) {
    guard saved else { return }

    Task {
      await productListViewModel.loadProducts()
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
