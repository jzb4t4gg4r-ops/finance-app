import SwiftUI

struct HomeView: View {
    @State private var month = Date.now.startOfMonth
    @State private var isAdding = false
    @State private var editing: Entry?
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            // A lista é recriada a cada mês, então só os lançamentos do mês ficam em memória.
            EntryListView(month: $month, onSelect: { editing = $0 })
                .navigationTitle("Finanças")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Ajustes", systemImage: "gearshape") { showSettings = true }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Novo lançamento", systemImage: "plus") { isAdding = true }
                    }
                }
                .sheet(isPresented: $isAdding) { EntryFormView(entry: nil) }
                .sheet(item: $editing) { EntryFormView(entry: $0) }
                .sheet(isPresented: $showSettings) { SettingsView() }
        }
    }
}
