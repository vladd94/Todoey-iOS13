//
//  Data.swift
//  Todoey
//
//  Created by Vlad Stoicoviciu on 12/28/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//
import Foundation
import RealmSwift

class Item: Object {
    static let highDate = Calendar.current.date(from: DateComponents(year: 9999, month: 12, day: 31))!
    @objc dynamic var text : String = ""
    @objc dynamic var complete : Bool = false
    @objc dynamic var dateCreated: Date = highDate
    
    // MARK: Relationship
    var parent = LinkingObjects(fromType: Category.self, property: "items")
}
