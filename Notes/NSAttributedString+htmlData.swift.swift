//
//  NSAttributedString+htmlData.swift.swift
//  Notes
//
//  Created by Даниил Циркунов on 06.02.2023.
//

import Foundation

extension NSAttributedString {
    var htmlData: Data? {
        do {
            let htmlData = try self.data(from: NSRange(location: 0, length: self.length), documentAttributes:[.documentType: NSAttributedString.DocumentType.rtfd])
            return htmlData
        } catch {
            print("error:", error)
            return nil
        }
    }
}
