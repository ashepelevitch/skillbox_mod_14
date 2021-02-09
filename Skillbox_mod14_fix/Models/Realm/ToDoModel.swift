//
//  ToDoModel.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 29.01.2021.
//

import RealmSwift

// Модель данных в данных на Realm
class ToDoModel: Object {
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var date = NSDate()
    @objc dynamic var eventDate: NSDate?
    @objc dynamic var isCompleted = false
    @objc dynamic var notes: String = ""

    static let instance = ToDoModel()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override init() {
        super.init()
    }
    
    init(title: String, eventDate: NSDate, notes: String) {
        super.init()
        
        let realm = try! Realm()
        
        self.id = UUID().uuidString
        
        self.title = title
        self.eventDate = eventDate
        self.notes = notes
        
        do {
            try realm.write {
                realm.add(self)
            }
//            print(self.id)

        } catch let error as NSError {
            print(error)
        }
    }
    
    func remove() {
        let realm = try! Realm()
        
        try! realm.write {
            realm.delete(self)
        }
    }
    
    static func remove(id: String) {
        if let model = ToDoModel.find(id: id) {
            let realm = try! Realm()
            
            try! realm.write {
                realm.delete(model)
            }
        }
    }
    
    func change(id: String, data: NSDictionary) {
        
    }
    
    static func find(id: String) -> ToDoModel? {
        let myPrimaryKey = id
        let realm = try! Realm()
        return realm.object(ofType: ToDoModel.self, forPrimaryKey: myPrimaryKey)
        
    }

}
