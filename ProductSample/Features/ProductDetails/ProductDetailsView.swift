//
//  ProductDetailsView.swift
//  ProductSample
//
//  Created by Guilherme Souza on 19/10/23.
//

import PhotosUI
import SwiftUI

struct ProductDetailsView: View {
  @ObservedObject var model: ProductDetailsViewModel

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    Form {
      Section {
        HStack {
          Group {
            if let productImage = model.imageSource?.productImage {
              productImage.image
                .resizable()
            } else if model.isDownloadingImage {
              ProgressView()
            } else {
              Color.clear
            }
          }
          .scaledToFit()
          .frame(width: 80, height: 80)

          Spacer()

          PhotosPicker(selection: $model.imageSelection, matching: .images) {
            Image(systemName: "pencil.circle.fill")
              .symbolRenderingMode(.multicolor)
              .font(.system(size: 30))
              .foregroundColor(.accentColor)
          }
        }
      }
      Section {
        TextField("Product Name", text: $model.name)
        MoneyTextField("Product Price", value: $model.price)
      }
    }
    .task { await model.loadProductIfNeeded() }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        if model.isSavingProduct {
          ProgressView()
        } else {
          Button("Save") {
            Task {
              if await model.saveButtonTapped() {
                dismiss()
              }
            }
          }
        }
      }
    }
  }
}
