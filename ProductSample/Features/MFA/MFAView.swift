//
//  MFAView.swift
//  ProductSample
//
//  Created by Guilherme Souza on 31/10/23.
//

import Supabase
import SwiftUI

@MainActor
final class MFAViewModel: ObservableObject {

  enum Status {
    case loading
    case enroll(MFAEnrollViewModel)
    case verify
    case verified(verified: Factor?, others: [Factor])
  }

  @Published var status: Status = .loading

  func load() async {
    do {
      let aal = try await Dependencies.supabase.auth.mfa.getAuthenticatorAssuranceLevel()

      if aal.currentLevel == "aal1", aal.nextLevel == "aal1" {
        status = .enroll(MFAEnrollViewModel())
      } else if aal.currentLevel == "aal1", aal.nextLevel == "aal2" {
        status = .verify
      } else {
        let factors = try await Dependencies.supabase.auth.mfa.listFactors()
        let verified = factors.totp.first
        status = .verified(verified: verified, others: factors.all.filter { $0.id != verified?.id })
      }
    } catch {

    }
  }
}

struct MFAView: View {
  @ObservedObject var model: MFAViewModel

  var body: some View {
    switch model.status {
    case .enroll(let model):
      MFAEnrollView(model: model)
    case .verify:
      Text("Verify MFA")
    case .verified(let verified, let others):
      List {
        if let verified {
          Section {
            factorView(verified)
          }
        }

        Section {
          ForEach(others) { factor in
            factorView(factor)
          }
        }
      }
    case .loading:
      ProgressView()
        .task { await model.load() }
    }
  }

  func factorView(_ factor: Factor) -> some View {
    VStack {
      LabeledContent("Name", value: factor.friendlyName ?? "")
      LabeledContent("Status", value: factor.status.rawValue)
      LabeledContent("Created at", value: factor.createdAt.formatted())
    }
  }
}
