//
//  StorageManager.swift
//  Notes
//
//  Created by Даниил Циркунов on 06.02.2023.
//

import RealmSwift

let realm = try! Realm()

final class StorageManager{
    
    static func saveObject(_ note: Note){
        try! realm.write {
            realm.add(note)
        }
    }
    
    static func deleteObject(_ note: Note){
        try! realm.write {
            realm.delete (note)
        }
    }
}
