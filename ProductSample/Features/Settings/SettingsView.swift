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

  let signOutUseCase: any SignOutUseCase
  let getProfileUseCase: any GetProfileUseCase

  enum NavigationDestination {
    case mfa(MFAViewModel)
  }

  @Published var destination: NavigationDestination?
  @Published var user: User?

  init(
    signOutUseCase: any SignOutUseCase = Dependencies.signOutUseCase,
    getProfileUseCase: any GetProfileUseCase = Dependencies.getProfileUseCase
  ) {
    self.signOutUseCase = signOutUseCase
    self.getProfileUseCase = getProfileUseCase
  }

  func signOutButtonTapped() async {
    await signOutUseCase.execute().value
  }

  func loadProfile() async {
    do {
      user = try await getProfileUseCase.execute().value
    } catch {
      logger.error("Error loading profile: \(error.localizedDescription)")
    }
  }

  func mfaButtonTapped() {
    destination = .mfa(MFAViewModel())
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
      } else {
        ProgressView("Loading profile...")
      }

      Section {
        Button("Multi-Factor Authentication (MFA)") {
          model.mfaButtonTapped()
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
    .navigationDestination(unwrapping: $model.destination) { $destination in
      switch destination {
      case .mfa(let model):
        MFAView(model: model)
      }
    }
  }
}

struct SettingsView_Preview: PreviewProvider {
  static var previews: some View {
    SettingsView(model: SettingsViewModel())
  }
}
