//
//  NoteViewController.swift
//  Notes
//
//  Created by Даниил Циркунов on 06.02.2023.
//

import UIKit

final class NewNoteViewController: UIViewController {

    var currentNote: Note?
    private var menuEdit, menuEditSize: UIMenu?
    private var fontSize: CGFloat = 19
    
    @IBOutlet weak var titleNote: UITextField!
    @IBOutlet weak var textNote: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleNote.delegate = self
        textNote.delegate = self
        
        saveButton.isEnabled = false
        titleNote.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
        if titleNote.text == "" {
            titleNote.becomeFirstResponder()
        }
        swipesObservers()
        setupEditMenu()
    }
    
    private func setupEditMenu(){
        menuEdit = UIMenu(children: [
            UIAction(title: Bundle.main.localizedString(forKey: "Bold",
                                                        value: "",
                                                        table: "Localizable"),
                     image: UIImage(systemName: "bold"),
                     handler: {_ in
                         self.editText(style: "Bold")
                     }),
            UIAction(title: Bundle.main.localizedString(forKey: "Italic",
                                                        value: "",
                                                        table: "Localizable"),
                     image: UIImage(systemName: "italic"),
                     handler: {_ in
                         self.editText(style: "Italic")
                     }),
            UIAction(title: Bundle.main.localizedString(forKey: "Underline",
                                                        value: "",
                                                        table: "Localizable"),
                     image: UIImage(systemName: "underline"),
                     handler: {_ in
                         self.editText(style: "Underline")
                     }),
            UIAction(title: Bundle.main.localizedString(forKey: "Standart",
                                                        value: "",
                                                        table: "Localizable"),
                     image: UIImage(systemName: "textformat.size.larger"),
                     handler: {_ in
                         self.editText(style: "Standart")
                     })])
        
        menuEditSize = UIMenu(children: [
            UIAction(title: Bundle.main.localizedString(forKey: "Reduce",
                                                        value: "",
                                                        table: "Localizable"),
                     image: UIImage(systemName: "chevron.down.circle"),
                     handler: {_ in
                         self.editText(style: "Reduce")
                     }),
            UIAction(title: Bundle.main.localizedString(forKey: "Increase",
                                                                     value: "",
                                                                     table: "Localizable"),
                                  image: UIImage(systemName: "chevron.up.circle"),
                                  handler: {_ in
                                      self.editText(style: "Increase")
                                  })])
    }
    
    private func editText(style: String){
        let range = textNote.selectedRange
        let string = NSMutableAttributedString(attributedString: textNote.attributedText)
        switch style {
        case "Bold":
            let boldAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize:  fontSize)]
            string.addAttributes(boldAttribute, range: textNote.selectedRange)
        case "Italic":
            let italicAttribute = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize:  fontSize)]
            
            string.addAttributes(italicAttribute, range: textNote.selectedRange)
        case "Underline":
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue.nonzeroBitCount]
            string.addAttributes(underlineAttribute, range: textNote.selectedRange)
        case "Increase":
            fontSize += 1
            string.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize), range: range)
        case "Reduce":
            fontSize -= 1
            string.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize), range: range)
        case "Standart":
            fontSize = 19
            let normalAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]
            let attributedString = NSAttributedString(string: string.string, attributes: normalAttribute)
            textNote.attributedText = attributedString
            textNote.selectedRange = range
            return
        default:
            return
        }
        
        textNote.attributedText = string
        textNote.selectedRange = range
    }
    
    func saveNote(){
        let newNote = Note(titleNote: titleNote.text!, textNote: textNote.attributedText.htmlData)
        
        if currentNote != nil {
            try! realm.write{
                currentNote?.titleNote = newNote.titleNote
                currentNote?.textNote = newNote.textNote
            }
        } else {
            StorageManager.saveObject(newNote)
        }
    }
    
    private func setupEditScreen(){
        if currentNote != nil {
            
            saveButton.isEnabled = true
            
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                        .documentType: NSAttributedString.DocumentType.rtfd,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ]
            guard let att = try? NSAttributedString(data: (currentNote?.textNote!)!, options: options ,documentAttributes: nil) else{return}
            
            textNote.attributedText = att
            titleNote.text = currentNote?.titleNote
        }
    }
    
    private func swipesObservers(){
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleSwipes(gester: UISwipeGestureRecognizer){
        
        switch gester.direction {
        case .down:
            view.endEditing(true)
        default:
            break
        }
    }
}

//MARK: - Text field delegate

extension NewNoteViewController: UITextFieldDelegate{
    
    //Скрываем клаву по нажатию на Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        if titleNote.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

//MARK: - Text view delegate

extension NewNoteViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        checkKeyboard()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        addInputAccessoryView()
        return true
    }
    
    private func checkKeyboard(){
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeShown(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillBeShown(note: Notification) {
        let userInfo = note.userInfo
        let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0)
        textNote.contentInset = contentInset
        textNote.scrollIndicatorInsets = contentInset
        textNote.scrollRectToVisible(textNote.frame, animated: true)
        
    }
    
    @objc private func keyboardWillBeHidden(note: Notification) {
     let contentInset = UIEdgeInsets.zero
     textNote.contentInset = contentInset
     textNote.scrollIndicatorInsets = contentInset
    }

    private func addInputAccessoryView(){
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 50.0))
        let textEdit = UIBarButtonItem(image: UIImage(systemName: "textformat"),
                                       menu: menuEdit)
        let textEditSize = UIBarButtonItem(image: UIImage(systemName: "textformat.size"),
                                       menu: menuEditSize)
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                       target: nil,
                                       action: nil)
        let barButton = UIBarButtonItem(title: "Done",
                                        style: .plain,
                                        target: self,
                                        action: #selector(tapDone))
        toolBar.setItems([textEdit, flexible, textEditSize, flexible, barButton], animated: false)
        toolBar.tintColor = #colorLiteral(red: 1, green: 0.2156862745, blue: 0.3725490196, alpha: 1)
        textNote.inputAccessoryView = toolBar
    }
    
    @objc private func tapDone() {
        self.view.endEditing(true)
    }
}

