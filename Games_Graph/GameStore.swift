import Foundation
import Observation

@Observable class GameStore {
    
    var games: [Game] = []
    let fileURL = URL.applicationSupportDirectory
        .appending(path: "GameGraph")
        .appending(path: "games.json")
    
    func save() {
        
        do {
            let data = try JSONEncoder().encode(games)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true )
            try data.write(to: fileURL)
        } catch {
            print("Failed: \(error)")
        }
        
    }
    
    func load() {
        
        do {
            let data = try Data(contentsOf: fileURL)
            games = try JSONDecoder().decode([Game].self, from: data)
        } catch {
            games = []
        }
    }
    
    func del(_ id: Game.ID?) {
        
        games.removeAll{ $0.id == id }
        save()
        
    }
    
    init() {
        load()
    }
}

