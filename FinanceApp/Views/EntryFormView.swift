import SwiftData
import SwiftUI

/// Formulário de criação/edição. Edita uma cópia em @State e só grava ao tocar em "Salvar",
/// então "Cancelar" descarta tudo sem tocar no banco.
struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let entry: Entry?

    @State private var title: String
    @State private var amountText: String
    @State private var isIncome: Bool
    @State private var category: Category
    @State private var date: Date
    @State private var note: String
    @State private var confirmDelete = false
    @FocusState private var amountFocused: Bool

    init(entry: Entry?) {
        self.entry = entry
        _title = State(initialValue: entry?.title ?? "")
        _amountText = State(initialValue: entry.map { Money.editableText(cents: $0.amountCents) } ?? "")
        _isIncome = State(initialValue: entry?.isIncome ?? false)
        _category = State(initialValue: entry?.category ?? .food)
        _date = State(initialValue: entry?.date ?? .now)
        _note = State(initialValue: entry?.note ?? "")
    }

    private var amountCents: Int? { Money.parse(amountText) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Tipo", selection: $isIncome) {
                        Text("Despesa").tag(false)
                        Text("Receita").tag(true)
                    }
                    .pickerStyle(.segmented)

                    TextField("Valor", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(.title2.monospacedDigit())
                        .focused($amountFocused)

                    TextField("Descrição", text: $title)
                        .onChange(of: title) { _, new in
                            if new.count > Entry.titleMaxLength { title = String(new.prefix(Entry.titleMaxLength)) }
                        }
                }

                Section {
                    Picker("Categoria", selection: $category) {
                        ForEach(Category.allCases) { Label($0.name, systemImage: $0.symbol).tag($0) }
                    }
                    DatePicker("Data", selection: $date, displayedComponents: .date)
                }

                Section("Observação") {
                    TextField("Opcional", text: $note, axis: .vertical)
                        .lineLimit(1...4)
                        .onChange(of: note) { _, new in
                            if new.count > Entry.noteMaxLength { note = String(new.prefix(Entry.noteMaxLength)) }
                        }
                }

                if entry != nil {
                    Section {
                        Button("Excluir lançamento", role: .destructive) { confirmDelete = true }
                    }
                }
            }
            .navigationTitle(entry == nil ? "Novo lançamento" : "Editar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar", action: save).disabled(amountCents == nil)
                }
            }
            .confirmationDialog("Excluir este lançamento?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Excluir", role: .destructive, action: delete)
            }
            .onAppear { if entry == nil { amountFocused = true } }
        }
    }

    private func save() {
        guard let cents = amountCents else { return }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmedTitle.isEmpty ? category.name : trimmedTitle
        let finalNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        if let entry {
            entry.title = finalTitle
            entry.amountCents = cents
            entry.isIncome = isIncome
            entry.category = category
            entry.date = date
            entry.note = finalNote
        } else {
            context.insert(Entry(
                title: finalTitle, amountCents: cents, isIncome: isIncome,
                category: category, date: date, note: finalNote
            ))
        }
        try? context.save()
        dismiss()
    }

    private func delete() {
        guard let entry else { return }
        context.delete(entry)
        try? context.save()
        dismiss()
    }
}
