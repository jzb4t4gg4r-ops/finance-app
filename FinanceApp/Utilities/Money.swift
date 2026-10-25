import Foundation

/// Conversão entre centavos e texto. Os FormatStyles são cacheados pelo sistema, então chamar
/// `format` em cada linha da lista é barato.
enum Money {
    static let currencyCode = Locale.current.currency?.identifier ?? "BRL"

    static func format(cents: Int) -> String {
        (Decimal(cents) / 100).formatted(.currency(code: currencyCode))
    }

    /// Texto editável sem símbolo de moeda nem separador de milhar, ex.: "1234,50".
    static func editableText(cents: Int) -> String {
        (Decimal(cents) / 100).formatted(.number.precision(.fractionLength(2)).grouping(.never))
    }

    /// Converte o texto digitado em centavos. Retorna `nil` se for inválido, zero, negativo ou acima do limite.
    static func parse(_ text: String, locale: Locale = .current) -> Int? {
        var normalized = text.trimmingCharacters(in: .whitespaces)
        if let grouping = locale.groupingSeparator, grouping != locale.decimalSeparator {
            normalized = normalized.replacingOccurrences(of: grouping, with: "")
        }
        if let decimal = locale.decimalSeparator, decimal != "." {
            normalized = normalized.replacingOccurrences(of: decimal, with: ".")
        }
        // Aceita apenas dígitos e um ponto decimal com até 2 casas.
        guard normalized.range(of: #"^\d{1,12}(\.\d{0,2})?$"#, options: .regularExpression) != nil,
              let value = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
        else { return nil }

        var scaled = value * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &scaled, 0, .plain)
        let cents = NSDecimalNumber(decimal: rounded).intValue
        guard cents > 0, cents <= Entry.maxAmountCents else { return nil }
        return cents
    }
}
