//
//  String.swift
//  TransactionsTestTask
//
//

import Foundation

extension String {
    
    var capitalizedSentence: String {
        let firstLetter = prefix(1).capitalized
        let remainingLetters = dropFirst().lowercased()
        return firstLetter + remainingLetters
    }
}
