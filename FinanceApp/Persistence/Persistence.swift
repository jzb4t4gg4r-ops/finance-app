import Foundation
import SwiftData

enum Persistence {
    /// Cria o banco local em Application Support/Store com proteção de arquivo `.complete`:
    /// os dados ficam criptografados e inacessíveis sempre que o aparelho está bloqueado.
    /// Arquivos novos criados pelo SQLite (-wal, -shm) herdam a proteção do diretório.
    static func makeContainer() -> ModelContainer {
        let fileManager = FileManager.default
        let directory = URL.applicationSupportDirectory.appending(path: "Store", directoryHint: .isDirectory)
        let protection: [FileAttributeKey: Any] = [.protectionKey: FileProtectionType.complete]

        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: protection)
            try fileManager.setAttributes(protection, ofItemAtPath: directory.path)

            let configuration = ModelConfiguration(
                schema: Schema([Entry.self]),
                url: directory.appending(path: "finance.store"),
                cloudKitDatabase: .none
            )
            let container = try ModelContainer(for: Entry.self, configurations: configuration)

            for file in try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
                try fileManager.setAttributes(protection, ofItemAtPath: file.path)
            }
            return container
        } catch {
            // Sem banco não há como o app funcionar; a mensagem não inclui dados do usuário.
            fatalError("Falha ao abrir o armazenamento local: \(error.localizedDescription)")
        }
    }
}
