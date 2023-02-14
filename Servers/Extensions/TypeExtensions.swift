//
//  TypeExtensions.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-01-30.
//

import Foundation
import Network
import CoreData

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}


extension Int{
    
    func times() -> String {
        switch self{
        case 0: return "0 times"
        case 1: return "once"
        case 2: return "twice"
        default: return "\(self) times"
        }
    }
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

