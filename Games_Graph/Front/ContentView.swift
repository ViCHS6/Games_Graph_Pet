import SwiftUI
import AppKit

struct ContentView: View {
    
    @State private var selectedGameID: Game.ID?
    @State private var store = GameStore()
    @State private var isAddingGame: Bool = false
    @State private var isEditingGame: Bool = false
    
    var selectedGame: Game? {
        store.games.first(where: { $0.id == selectedGameID })
    }
    
    var body: some View {
        
        NavigationSplitView{
            
            List(store.games, selection: $selectedGameID) { game in
                Text(game.title)}
            
            .toolbar {
                ToolbarItem {
                    Button("Add") {
                        isAddingGame = true
                    }
                }
                ToolbarItem {
                    Button("Edit") {
                        isEditingGame = true
                    }
                }
                ToolbarItem {
                    Button("Delete") {
                        store.del(selectedGameID)
                    }
                }
                ToolbarItem {
                    Button("HUI") {
                        HUI()
                    }
                }

            }
            .sheet(isPresented: $isAddingGame) {
                AddGameView(store: store)
            }
            .sheet(isPresented: $isEditingGame) {
                AddGameView(store: store, gameToEdit: selectedGame)
            }
            
        }detail: {
            if let selectedGame {
                
                VStack(alignment: .leading) {
                    if let coverFile = selectedGame.coverFile,
                       let nsImage = NSImage(contentsOf: store.coverURL.appending(path: coverFile)) {
                        Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 350)
                    }
                    Text(selectedGame.title)
                    Text("Year: \(String(selectedGame.year))")
                }
            } else {
                Text ("Choose the game")
            }
        }
    }
}
