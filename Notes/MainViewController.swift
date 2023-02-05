//
//  MainViewController.swift
//  Notes
//
//  Created by Даниил Циркунов on 06.02.2023.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {

    var notes: Results<Note>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notes = realm.objects(Note.self)
        firstStart()
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.isEmpty ? 0 : notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let note = notes[indexPath.row]
        cell.titleLable.text = note.titleNote
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                    .documentType: NSAttributedString.DocumentType.rtfd,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ]
        guard let att = try? NSAttributedString(data: note.textNote!, options: options ,documentAttributes: nil) else{ return cell }
        
        cell.textLable.text = att.string
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let note = notes[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") { _, _ in
            StorageManager.deleteObject(note)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [deleteAction]
    }

   
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let note = notes[indexPath.row]
            let newNoteVC = segue.destination as! NewNoteViewController
            newNoteVC.currentNote = note
        }
    }
    
    @IBAction func unwindSegue (_ segue: UIStoryboardSegue) {
        
        guard let newNoteVC = segue.source as? NewNoteViewController else { return }
        
        newNoteVC.saveNote()
        tableView.reloadData()
        
    }

    private func firstStart(){
        
        let userDefaults = UserDefaults.standard
        let presentationWasViewed = userDefaults.bool(forKey: "firstStart")
        let firstTitle = Bundle.main.localizedString(forKey: "TitleNote", value: "", table: "Localizable")
        let firstText = Bundle.main.localizedString(forKey: "TextNote", value: "", table: "Localizable")
        let normalAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)]
        let attString = NSMutableAttributedString(string: firstText, attributes: normalAttribute)
        let firstTextData = attString.htmlData
        
        if presentationWasViewed == false {
            let note = Note(titleNote: firstTitle, textNote: firstTextData)
            StorageManager.saveObject(note)
            let userDefaults = UserDefaults.standard
            userDefaults.set(true, forKey: "firstStart")
        }
    }
}
