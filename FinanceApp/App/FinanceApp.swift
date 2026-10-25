import SwiftData
import SwiftUI

@main
struct FinanceApp: App {
    private let container = Persistence.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var lock = AppLock()

    var body: some View {
        ZStack {
            // Quando bloqueado, a tela de dados nem é criada: nada fica visível nem acessível ao VoiceOver.
            if lock.isLocked {
                LockView(lock: lock)
            } else {
                HomeView()
            }
            if scenePhase != .active {
                PrivacyCover()
            }
        }
        .environment(lock)
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background: lock.lock()
            case .active: Task { await lock.sceneBecameActive() }
            default: break
            }
        }
        .task { await lock.sceneBecameActive() }
    }
}
