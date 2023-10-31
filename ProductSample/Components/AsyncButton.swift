//
//  AsyncButton.swift
//  ProductSample
//
//  Created by Guilherme Souza on 31/10/23.
//

import SwiftUI

struct AsyncButton<Label: View>: View {
  let role: ButtonRole?
  let action: () async -> Void
  @ViewBuilder var label: Label

  @State private var task: Task<Void, Never>?
  private var isLoading: Bool {
    task != nil
  }

  var body: some View {
    Button(role: role) {
      task = Task(priority: .userInitiated) {
        defer { task = nil }
        await action()
      }
    } label: {
      ZStack {
        label.opacity(isLoading ? 0 : 1)

        if isLoading {
          ProgressView()
        }
      }
    }
    .onDisappear {
      task?.cancel()
    }
  }
}

extension AsyncButton where Label == Text {
  init(_ title: some StringProtocol, role: ButtonRole? = nil, action: @escaping () async -> Void) {
    self.init(role: role, action: action) {
      Text(title)
    }
  }
}
