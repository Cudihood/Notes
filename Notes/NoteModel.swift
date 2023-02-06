//
//  NoteModel.swift
//  Notes
//
//  Created by Даниил Циркунов on 06.02.2023.
//

import RealmSwift

final class Note: Object {
    
    @objc dynamic var titleNote = ""
    @objc dynamic var textNote: Data?
    
    convenience init(titleNote: String, textNote: Data?) {
        self.init()
        self.titleNote = titleNote
        self.textNote = textNote
    }
}
