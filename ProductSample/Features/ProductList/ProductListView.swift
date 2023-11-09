//
//  ProductListView.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import SwiftUI

struct ProductListView: View {
  @ObservedObject var model: ProductListViewModel

  var body: some View {
    List {
      if let error = model.error {
        Text(error.localizedDescription)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .background(Color.red.opacity(0.5))
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .padding()
          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          .listRowSeparator(.hidden)
      }

      if model.isLoading {
        ProgressView()
          .frame(maxWidth: .infinity)
      }

      ForEach(model.products) { product in
        Button {
          model.didTapProduct(product)
        } label: {
          LabeledContent(product.name, value: product.price.formatted(.currency(code: "USD")))
        }
      }
      .onDelete { indexSet in
        Task {
          await model.didSwipeToDelete(indexSet)
        }
      }
    }
    .animation(.easeIn, value: model.isLoading)
    .animation(.easeIn, value: model.products.count)
    .animation(.easeIn, value: model.error != nil)
    .listStyle(.plain)
    .overlay {
      if model.products.isEmpty {
        Text("Product list empty.")
      }
    }
    .task {
      await model.loadProducts()
    }
    .refreshable {
      await model.loadProducts()
    }
  }
}
