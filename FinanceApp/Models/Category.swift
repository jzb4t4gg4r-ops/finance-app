import Foundation

enum Category: String, CaseIterable, Identifiable {
    case food, transport, housing, bills, health, education, leisure, shopping, salary, other

    var id: String { rawValue }

    var name: String {
        switch self {
        case .food: "Alimentação"
        case .transport: "Transporte"
        case .housing: "Moradia"
        case .bills: "Contas"
        case .health: "Saúde"
        case .education: "Educação"
        case .leisure: "Lazer"
        case .shopping: "Compras"
        case .salary: "Salário"
        case .other: "Outros"
        }
    }

    var symbol: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car"
        case .housing: "house"
        case .bills: "doc.text"
        case .health: "cross.case"
        case .education: "book"
        case .leisure: "gamecontroller"
        case .shopping: "bag"
        case .salary: "banknote"
        case .other: "ellipsis.circle"
        }
    }
}
