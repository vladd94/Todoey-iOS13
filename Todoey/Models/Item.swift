import Foundation
struct Item {
    var title: String
    var isCompleted: Bool
    var dateCreated: Date
    
    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = false
        self.dateCreated = Date()
    }
} 
