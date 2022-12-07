//
//  Rule.swift
//  Turing Verifier
//
//  Created by Seamus Grealey on 12/2/22.
//

import Foundation
import SwiftUI

class Rule: Hashable, Identifiable, ObservableObject{
    static func == (lhs: Rule, rhs: Rule) -> Bool {
        return lhs.read == rhs.read && lhs.write == rhs.write && lhs.oldState == rhs.oldState && lhs.newState == rhs.newState && lhs.move == rhs.move
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(read)
        hasher.combine(write)
        hasher.combine(oldState)
        hasher.combine(newState)
        hasher.combine(move)
    }
    
    var uuid = UUID()
    
    @Published var number: Int
    
    @Published var read = ""
    
    @Published var write = ""
    
    @Published var oldState = ""
    
    @Published var newState = ""
    
    @Published var move = ""
    
    func toString() -> String {
        return read + "," + oldState + "->" + write + "," + newState + "," + move
    }
    
    init(number: Int) {
        self.number = number
    }
    
    init(number: Int, read: String, oldState: String, write: String, newState: String, move: String) {
        self.number = number
        self.read = read
        self.oldState = oldState
        self.write = write
        self.newState = newState
        self.move = move
    }
}

