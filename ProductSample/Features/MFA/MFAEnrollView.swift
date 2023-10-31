//
//  MFAEnrollView.swift
//  ProductSample
//
//  Created by Guilherme Souza on 31/10/23.
//

import OSLog
import Supabase
import SwiftUI
import XCTestDynamicOverlay

@MainActor
final class MFAEnrollViewModel: ObservableObject {
  let logger = Logger.make(category: "MFAEnrollViewModel")

  enum Status {
    case loading
    case success(TOTP)
    case failure(Error)
  }

  struct TOTP {
    let id: String
    let secret: String
    let qrCode: String
  }

  @Published var status: Status?
  @Published var code: String = ""

  var onEnroll: () -> Void = unimplemented("\(MFAEnrollViewModel.self).onEnroll")

  func load() async {
    status = .loading
    do {
      let response = try await Dependencies.supabase.auth.mfa.enroll(params: MFAEnrollParams())
      status = .success(
        TOTP(
          id: response.id,
          secret: response.totp?.secret ?? "", qrCode: response.totp?.qrCode ?? "")
      )
    } catch {
      logger.error("Error enrolling MFA: \(error)")
      status = .failure(error)
    }
  }

  func enrollButtonTapped() async {
    do {
      guard case let .success(totp) = status else {
        return
      }

      try await Dependencies.supabase.auth.mfa.challengeAndVerify(
        params: MFAChallengeAndVerifyParams(factorId: totp.id, code: code))
      onEnroll()
    } catch {
      logger.error("Error verifying code: \(error)")
    }
  }
}

struct MFAEnrollView: View {
  @ObservedObject var model: MFAEnrollViewModel

  var body: some View {
    Group {
      switch model.status {
      case .none: Color.clear
      case .loading: ProgressView()
      case .failure(let error): Text(error.localizedDescription).foregroundStyle(.red)
      case .success(let totp):
        Form {
          Section {
            VStack(alignment: .leading) {
              Text("Secret")
                .foregroundStyle(.secondary)

              HStack(alignment: .top) {
                Text(totp.secret)
                  .frame(maxWidth: .infinity, alignment: .leading)

                Button("Copy") {
                  UIPasteboard.general.string = totp.secret
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
              }
            }
          }

          Section {
            TextField("Code", text: $model.code)
              .keyboardType(.numberPad)
          }
        }
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            AsyncButton("Enroll") {
              await model.enrollButtonTapped()
            }
          }
        }
      }
    }
    .task { await model.load() }
    .navigationTitle("Enroll MFA")
  }
}
