import Foundation
import SwiftData

/// Um lançamento financeiro (receita ou despesa).
@Model
final class Entry {
    var title: String
    /// Valor sempre positivo, em centavos. Inteiros evitam erros de arredondamento de ponto flutuante.
    var amountCents: Int
    var isIncome: Bool
    var categoryRaw: String
    var date: Date
    var note: String

    init(title: String, amountCents: Int, isIncome: Bool, category: Category, date: Date, note: String = "") {
        self.title = title
        self.amountCents = amountCents
        self.isIncome = isIncome
        self.categoryRaw = category.rawValue
        self.date = date
        self.note = note
    }

    var category: Category {
        get { Category(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    /// Valor com sinal: positivo para receitas, negativo para despesas.
    var signedCents: Int { isIncome ? amountCents : -amountCents }
}

extension Entry {
    static let titleMaxLength = 80
    static let noteMaxLength = 500
    /// Limite superior de valor (R$ 1 bilhão) para rejeitar entradas absurdas.
    static let maxAmountCents = 100_000_000_000
}
