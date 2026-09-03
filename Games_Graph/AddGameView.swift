import SwiftUI


struct AddGameView: View {
    
    var store: GameStore
    var gameToEdit: Game?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var yearText: String
    @State private var genresText: String
    
    var body: some View{
        Form {
            TextField("Title", text: $title)
            TextField("Year", text: $yearText)
            TextField("Genres ( , sep )", text: $genresText)
        }
        Button("Save") {
            saveGame()
        }
    }
    
    init(store: GameStore, gameToEdit: Game? = nil) {
        self.store = store
        self.gameToEdit = gameToEdit
        _title = State(initialValue: gameToEdit?.title ?? "")
        _yearText = State(initialValue: gameToEdit.map { String($0.year ) } ?? "" )
        _genresText = State(initialValue: gameToEdit?.genres.joined(separator: ", ") ?? "" )
    }
    
    func saveGame() {
        let genres = genresText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces)}
        let newGame = Game(
            id: gameToEdit?.id ?? UUID(),
            title: title,
            year: Int(yearText) ?? 0,
            genres: genres,
            status: .completed
            )
        if let gameToEdit, let index = store.games.firstIndex(where: { $0.id == gameToEdit.id }) {
            store.games[index] = newGame
        } else {
            store.games.append(newGame)

        }
        store.save()
        dismiss()
    }
}
