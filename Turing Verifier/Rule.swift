//
//  Rule.swift
//  Turing Verifier
//
//  Created by Seamus Grealey on 12/2/22.
//

import Foundation
import SwiftUI

class Rule: Hashable, Identifiable, ObservableObject{
    /**
     * Returns the equality of 2 rules.
     */
    static func == (lhs: Rule, rhs: Rule) -> Bool {
        return lhs.read == rhs.read && lhs.write == rhs.write && lhs.oldState == rhs.oldState && lhs.newState == rhs.newState && lhs.move == rhs.move
    }
    
    /**
     * Returns the hash of the rule.
     */
    func hash(into hasher: inout Hasher) {
        hasher.combine(read)
        hasher.combine(write)
        hasher.combine(oldState)
        hasher.combine(newState)
        hasher.combine(move)
        hasher.combine(uuid)
    }
    
    /**
     * Unique identifier for each rule
     */
    var uuid = UUID()
    
    /**
     * Rule number in the list of rules (e.g. Rule 1, Rule 2, etc)
     */
    @Published var number: Int
    
    /**
     * This is the value that the rule will read from the tape
     */
    @Published var read = ""
    
    /**
     * This is the value that the rule will write to the tape
     */
    @Published var write = ""
    
    /**
     * This is the required state for the rule to be in to be used
     */
    @Published var oldState = ""
    
    /**
     * This is the new state that the Turing Machine will be in once the rule is applied
     */
    @Published var newState = ""
    
    /**
     * This is the direction the rule will move (In this simulation, down is right, and up is left)
     */
    @Published var move = ""
    
    /**
     * Returns the string representation of the rule (for reporting which rule accepted, rejected, or halted.
     */
    func toString() -> String {
        return read + "," + oldState + "->" + write + "," + newState + "," + move
    }
    
    /**
     * Creates a new, blank rule
     */
    init(number: Int) {
        self.number = number
    }
    
    /**
     * Creates a new rule with all fields filled in (used for the presets)
     */
    init(number: Int, read: String, oldState: String, write: String, newState: String, move: String) {
        self.number = number
        self.read = read
        self.oldState = oldState
        self.write = write
        self.newState = newState
        self.move = move
    }
}

