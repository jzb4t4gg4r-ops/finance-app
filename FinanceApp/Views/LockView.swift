import SwiftUI

struct LockView: View {
    let lock: AppLock

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Finanças bloqueado")
                .font(.title2.bold())
            Button("Desbloquear") { Task { await lock.unlock() } }
                .buttonStyle(.borderedProminent)
                .disabled(lock.isAuthenticating)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

/// Cobre o conteúdo quando o app não está ativo, para que valores não apareçam no seletor de apps.
struct PrivacyCover: View {
    var body: some View {
        Image(systemName: "lock.shield")
            .font(.system(size: 48))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background)
    }
}
