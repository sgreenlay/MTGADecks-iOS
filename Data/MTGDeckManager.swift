
import Foundation
import UIKit

struct MTGColours : OptionSet, Codable, Hashable {
    let rawValue: Int
    public var hashValue: Int {
        return self.rawValue
    }

    static let white  = MTGColours(rawValue: 1 << 0)
    static let blue = MTGColours(rawValue: 1 << 1)
    static let black  = MTGColours(rawValue: 1 << 2)
    static let red  = MTGColours(rawValue: 1 << 3)
    static let green  = MTGColours(rawValue: 1 << 4)
    static let colourless  = MTGColours(rawValue: 1 << 5)
    
    static let none  = MTGColours([])
    static let all  = MTGColours([.white, .blue, .black, .red, .green, .colourless])
}

struct MTGDeck: Codable, Hashable {
    var id: Int
    var name: String
    var colors: MTGColours
    var contents: String
    var tags: Set<String>
    
    init(id: Int, name: String, colors: MTGColours, contents: String, tags: Set<String>) {
        self.id = id
        self.name = name
        self.colors = colors
        self.contents = contents
        self.tags = tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try! container.decodeIfPresent(Int.self, forKey: .id)!
        self.name = try! container.decodeIfPresent(String.self, forKey: .name)!
        
        self.colors = try! container.decodeIfPresent(MTGColours.self, forKey: .colors)!
        self.contents = try! container.decodeIfPresent(String.self, forKey: .contents)!
        
        if let tags = try container.decodeIfPresent(Set<String>.self, forKey: .tags) {
            self.tags = tags
        } else {
            self.tags = []
        }
        
        if (self.name.starts(with: "[S] ")) {
            self.tags.insert("Starter")
            let range = self.name.startIndex..<self.name.index(self.name.startIndex, offsetBy: 4)
            self.name.removeSubrange(range)
        }
        if (self.name.starts(with: "[B] ")) {
            self.tags.insert("Brawl")
            let range = self.name.startIndex..<self.name.index(self.name.startIndex, offsetBy: 4)
            self.name.removeSubrange(range)
        }
    }

    func exportToClipboard() {
        UIPasteboard.general.string = contents
    }
}

struct MTGDeckManager: Codable, Hashable {
    var decks: [MTGDeck]
    
    init(decks: [MTGDeck]) {
        self.decks = decks
    }
    
    var tags: Set<String> {
        self.decks.reduce(Set<String>(), { acc, next in
            acc.union(next.tags)
        })
    }
    
    var nextId: Int {
        if (decks.isEmpty) {
            return 1
        }
        return decks.map(\.id).max()! + 1
    }
    
    static var cachePath: URL {
        let dataDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(Bundle.main.displayName!)
        try! FileManager.default.createDirectory(at: dataDirectory, withIntermediateDirectories: true, attributes: nil)
        return dataDirectory.appendingPathComponent("decks.json")
    }
    
    static func load() -> MTGDeckManager? {
        guard let data = try? Data(contentsOf: cachePath) else {
            return nil
        }
        
        let jsonDecoder = JSONDecoder()
        let deckManger = try? jsonDecoder.decode(MTGDeckManager.self, from: data)

        return deckManger
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(self) else { return }
        do {
            try data.write(to: MTGDeckManager.cachePath)
        } catch {
            print("Couldn't write to save file: " + error.localizedDescription)
        }
    }
}
