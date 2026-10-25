import LocalAuthentication
import Observation

/// Bloqueio opcional do app usando biometria com fallback para o código do aparelho.
/// A autenticação é feita pelo próprio iOS (Secure Enclave); o app nunca vê dados biométricos nem o código.
@MainActor
@Observable
final class AppLock {
    private static let enabledKey = "appLockEnabled"

    private(set) var isEnabled: Bool
    private(set) var isLocked: Bool
    private(set) var isAuthenticating = false
    /// Evita repetir o pedido de autenticação em loop quando o usuário cancela
    /// (o prompt do sistema deixa a cena inativa e ativa de novo).
    private var shouldPromptOnActive: Bool

    init() {
        let enabled = UserDefaults.standard.bool(forKey: Self.enabledKey)
        isEnabled = enabled
        isLocked = enabled
        shouldPromptOnActive = enabled
    }

    /// Nome do método disponível, para exibir na interface.
    var methodName: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "código do aparelho"
        }
    }

    /// Chamado quando o app vai para segundo plano.
    func lock() {
        guard isEnabled else { return }
        isLocked = true
        shouldPromptOnActive = true
    }

    /// Chamado quando o app volta a ficar ativo: pede autenticação uma única vez.
    func sceneBecameActive() async {
        guard isLocked, shouldPromptOnActive else { return }
        shouldPromptOnActive = false
        await unlock()
    }

    func unlock() async {
        guard isLocked, !isAuthenticating else { return }
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            // Sem código configurado no aparelho não existe como autenticar. Os dados também deixam
            // de ser criptografados pelo iOS nesse caso, então o bloqueio não protegeria nada:
            // desligamos para não trancar o usuário fora dos próprios dados.
            if (error as? LAError)?.code == .passcodeNotSet {
                setStoredEnabled(false)
                isLocked = false
            }
            return
        }
        if await authenticate(context, reason: "Desbloqueie para ver suas finanças.") {
            isLocked = false
        }
    }

    /// Ligar ou desligar o bloqueio sempre exige autenticação.
    func setEnabled(_ enabled: Bool) async {
        guard enabled != isEnabled else { return }
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else { return }
        let reason = enabled ? "Confirme para ativar o bloqueio." : "Confirme para desativar o bloqueio."
        if await authenticate(context, reason: reason) {
            setStoredEnabled(enabled)
        }
    }

    var canUseLock: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    private func authenticate(_ context: LAContext, reason: String) async -> Bool {
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        } catch {
            return false
        }
    }

    private func setStoredEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: Self.enabledKey)
    }
}
