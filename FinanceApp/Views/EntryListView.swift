import SwiftData
import SwiftUI

struct EntryListView: View {
    @Environment(\.modelContext) private var context
    @Query private var entries: [Entry]
    @Binding var month: Date
    let onSelect: (Entry) -> Void
    @State private var pendingDelete: Entry?

    init(month: Binding<Date>, onSelect: @escaping (Entry) -> Void) {
        _month = month
        self.onSelect = onSelect
        let start = month.wrappedValue
        let end = start.addingMonths(1)
        // Filtro e ordenação feitos pelo SQLite: só o mês selecionado é carregado.
        _entries = Query(
            filter: #Predicate<Entry> { $0.date >= start && $0.date < end },
            sort: \Entry.date,
            order: .reverse
        )
    }

    var body: some View {
        List {
            Section {
                MonthSelector(month: $month)
                SummaryView(entries: entries)
            }

            if entries.isEmpty {
                ContentUnavailableView(
                    "Nenhum lançamento",
                    systemImage: "tray",
                    description: Text("Toque em + para adicionar.")
                )
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(entries) { entry in
                        Button { onSelect(entry) } label: { EntryRow(entry: entry) }
                            .tint(.primary)
                            .swipeActions {
                                Button("Excluir", systemImage: "trash", role: .destructive) {
                                    pendingDelete = entry
                                }
                            }
                    }
                }
            }
        }
        .confirmationDialog(
            "Excluir este lançamento?",
            isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
            titleVisibility: .visible,
            presenting: pendingDelete
        ) { entry in
            Button("Excluir", role: .destructive) {
                context.delete(entry)
                try? context.save()
            }
        }
    }
}

private struct MonthSelector: View {
    @Binding var month: Date

    var body: some View {
        HStack {
            Button("Mês anterior", systemImage: "chevron.left") { month = month.addingMonths(-1) }
            Spacer()
            Text(month.formatted(.dateTime.month(.wide).year()).capitalized)
                .font(.headline)
            Spacer()
            Button("Próximo mês", systemImage: "chevron.right") { month = month.addingMonths(1) }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
    }
}

private struct SummaryView: View {
    let entries: [Entry]

    var body: some View {
        // Um único laço sobre os lançamentos do mês.
        let (income, expense) = entries.reduce(into: (0, 0)) { totals, entry in
            if entry.isIncome { totals.0 += entry.amountCents } else { totals.1 += entry.amountCents }
        }
        VStack(spacing: 8) {
            Text(Money.format(cents: income - expense))
                .font(.largeTitle.bold())
                .monospacedDigit()
                .foregroundStyle(income - expense < 0 ? .red : .primary)
            HStack {
                Label(Money.format(cents: income), systemImage: "arrow.down")
                    .foregroundStyle(.green)
                Spacer()
                Label(Money.format(cents: expense), systemImage: "arrow.up")
                    .foregroundStyle(.red)
            }
            .font(.subheadline)
            .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

private struct EntryRow: View {
    let entry: Entry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.category.symbol)
                .frame(width: 28)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title).lineLimit(1)
                Text(entry.date, format: .dateTime.day().month(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(Money.format(cents: entry.signedCents))
                .monospacedDigit()
                .foregroundStyle(entry.isIncome ? .green : .primary)
        }
        .accessibilityElement(children: .combine)
    }
}
