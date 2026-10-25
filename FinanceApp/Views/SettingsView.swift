import SwiftUI

struct SettingsView: View {
    @Environment(AppLock.self) private var lock
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Bloquear com \(lock.methodName)", isOn: Binding(
                        get: { lock.isEnabled },
                        set: { newValue in Task { await lock.setEnabled(newValue) } }
                    ))
                    .disabled(!lock.canUseLock || lock.isAuthenticating)
                } header: {
                    Text("Segurança")
                } footer: {
                    Text(lock.canUseLock
                         ? "Pede autenticação ao abrir o app e ao voltar do segundo plano."
                         : "Configure um código no iPhone para usar o bloqueio.")
                }

                Section {
                    Label("Os dados ficam só neste iPhone, criptografados enquanto ele está bloqueado.",
                          systemImage: "iphone")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }
                }
            }
        }
    }
}
