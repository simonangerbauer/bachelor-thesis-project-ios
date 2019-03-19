
import Foundation

class Proof : Codable {
    var LastChange: String
    var Id: String = UUID().uuidString
    var Title: String
    
    init(title: String, lastChange: String) {
        self.LastChange = lastChange
        self.Title = title
    }
    
    enum CodingKeys: String, CodingKey {
        case LastChange
        case Id
        case Title
    }
}
