//
//  SettingsView.swift
//  ProductSample
//
//  Created by Guilherme Souza on 31/10/23.
//

import Supabase
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
  @Published var user: User?

  func signOutButtonTapped() async {
    // TODO: Implement sign out.
  }

  func loadProfile() async {
    // TODO: Fetch user from Supabase.
  }
}

struct SettingsView: View {
  @ObservedObject var model: SettingsViewModel

  var body: some View {
    Form {
      if let user = model.user {
        Section("Profile") {
          LabeledContent("Email", value: user.email ?? "")
          LabeledContent("Last signed in", value: user.lastSignInAt?.formatted() ?? "")
        }
      }

      Section {
        AsyncButton("Sign out", role: .destructive) {
          await model.signOutButtonTapped()
        }
      }
    }
    .navigationTitle("Settings")
    .task {
      await model.loadProfile()
    }
  }
}

struct SettingsView_Preview: PreviewProvider {
  static var previews: some View {
    SettingsView(model: SettingsViewModel())
  }
}
