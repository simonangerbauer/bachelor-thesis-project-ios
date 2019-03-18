import Foundation
import RealmSwift
import Realm

/**
 Live Object which is synced by the realm mobile platform
 */
class RealmTask: Object, Codable {
    /** unique id */
    @objc dynamic var Id: String = ""
    /** name of the task */
    @objc dynamic var Title: String = ""
    /** description of the task */
    @objc dynamic var Description: String = ""
    /** activity of the task */
    @objc dynamic var Activity: String = ""
    /** activity of the task */
    @objc dynamic var LastChange: Date = Date()
    /** activity of the task */
    @objc dynamic var Officers: String = ""
    /** progress of the task */
    @objc dynamic var Progress: Int = 0
    /** due date of the task */
    @objc dynamic var Due: Date = Date()
    
    var Proofs = List<String>()
    
    /**
     function to return the primary key property name
     needed by realm
     - Returns: the name of the primary key property
     */
    override class func primaryKey() -> String? {
        return "Id"
    }
    
    enum CodingKeys: String, CodingKey {
        case Title
        case Id
        case Description
        case Activity
        case Officers
        case Progress
        case LastChange
        case Due
        case Proofs
    }
    
    enum CodingKeysProof: String, CodingKey {
        case Title
        case Id
        case LastChange
    }
    
    convenience init(Id: String, Title: String, Description: String, Activity: String, Officer: String, Progress: Int, LastChange: Date, Due: Date, Proofs: List<String>) {
        self.init()
        self.Id = Id
        self.Title = Title
        self.Description = Description
        self.Activity = Activity
        self.Officers = Officer
        self.Progress = Progress
        self.LastChange = LastChange
        self.Due = Due
        self.Proofs = Proofs
    }
    
    convenience required init(from decoder: Decoder) throws {
        let dateFormatter = DateFormatter.iso8601Full
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let Id = try container.decode(String.self, forKey: .Id)
        let Title = try container.decode(String.self, forKey: .Title)
        let Description = try container.decode(String.self, forKey: .Description)
        let Activity = try container.decode(String.self, forKey: .Activity)
        let Officers = try container.decode(String.self, forKey: .Officers)
        let Progress = try container.decode(Int.self, forKey: .Progress)
        let lastChangeString = try container.decode(String.self, forKey: .LastChange)
        let dueString = try container.decode(String.self, forKey: .Due)
        let lastChange = dateFormatter.date(from: lastChangeString)
        let due = dateFormatter.date(from: dueString)
        self.init(Id: Id, Title: Title, Description: Description, Activity: Activity, Officer: Officers, Progress: Progress, LastChange: lastChange ?? Date(), Due: due ?? Date(), Proofs: List<String>())
    }
    
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    func encode(to encoder: Encoder) throws {
        let dateFormatter = DateFormatter.iso8601Full
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Id, forKey: .Id)
        try container.encode(Title, forKey: .Title)
        try container.encode(Description, forKey: .Description)
        try container.encode(Activity, forKey: .Activity)
        try container.encode(Officers, forKey: .Officers)
        try container.encode(Progress, forKey: .Progress)
        let lastChange = dateFormatter.string(from: LastChange)
        try container.encode(lastChange, forKey: .LastChange)
        let due = dateFormatter.string(from: Due)
        try container.encode(due, forKey: .Due)
        
        let proofs = try Proofs.map() { value throws -> Proof in
            return Proof (title: value, lastChange: lastChange)
        }
        
        try container.encode(proofs, forKey: .Proofs)
    }
    
}

struct JsonData : Decodable {
    let data: RealmTask
    let state: Int
    let topic: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case state
        case topic
    }
}
