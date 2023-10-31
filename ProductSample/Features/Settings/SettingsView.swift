//
//  SettingsView.swift
//  ProductSample
//
//  Created by Guilherme Souza on 31/10/23.
//

import OSLog
import Supabase
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
  private let logger = Logger.make(category: "SettingsViewModel")
  let authenticationRepository: AuthenticationRepository

  @Published var user: User?

  init(authenticationRepository: AuthenticationRepository = Dependencies.authenticationRepository) {
    self.authenticationRepository = authenticationRepository
  }

  func signOutButtonTapped() async {
    await authenticationRepository.signOut()
  }

  func loadProfile() async {
    do {
      user = try await Dependencies.supabase.auth.user()
    } catch {
      logger.error("Error loading profile: \(error.localizedDescription)")
    }
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
