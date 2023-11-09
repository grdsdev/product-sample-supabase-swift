//
//  MoneyTextField.swift
//  ProductSample
//
//  Created by Guilherme Souza on 09/11/23.
//

import SwiftUI

struct MoneyTextField: View {
  let title: String
  private let text: Binding<String>

  init(_ title: String, value: Binding<Double>) {
    self.title = title
    self.text = Binding {
      value.wrappedValue.formatted(.currency(code: "USD"))
    } set: { newValue, transaction in
      let numbersOnly = newValue.replacingOccurrences(
        of: "[^0-9]", with: "", options: .regularExpression)
      value.transaction(transaction).wrappedValue = (Double(numbersOnly) ?? 0) / 100
    }
  }

  var body: some View {
    TextField(title, text: text)
      .keyboardType(.numberPad)
  }
}
