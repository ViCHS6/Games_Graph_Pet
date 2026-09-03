import Foundation
import SwiftUI

struct Game: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var year: Int
    var developer: String?
    var publisher: String?
    var franchise: String?
    var genres: [String]
    var tags: [String]?
    var steamAppID: Int?
    var status: GameStatus
    var hoursPlayed: Int?
    var coverFile: String?
    var note: String?
    
    enum GameStatus: Codable, Hashable {
        case completed
        case inProgress
        case dropped
    }
}

