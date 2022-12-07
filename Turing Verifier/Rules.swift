//
//  Rules.swift
//  Turing Verifier
//
//  Created by Seamus Grealey on 12/2/22.
//

import Foundation
import SwiftUI


struct Rules: View {
    
    //List of rules for the simulation
    @Binding var rules: [Rule]
    
    //Holds the number of rules for this simulation
    @State var numRules: Int = 1
    
    var body: some View {
        VStack {
            //This navigation view routes each rule displayed to a screen where the user can access the fields
            NavigationView {
                //Lists each rule
                List($rules, id: \.self.uuid, editActions: .delete) { rule in
                    NavigationLink("Rule " + String(rule.wrappedValue.number), destination: RuleForm(rule: rule))
                }
                .navigationTitle("Rules")
                    .toolbar {
                        //List of premade rulesets
                        Menu {
                            //Replaces a binary string with its lexographically next value (e.g. 0, 1, 00, 01, 10, 11, 000...)
                            Button("Binary Increment (HW)") {
                                binaryIncrement()
                            }
                        } label: {
                            Image(systemName: "gear")
                        }
                        .padding(.horizontal, 10)
                        
                        //Clears all current rules
                        Button {
                            rules = []
                            numRules = 0
                        } label: {
                            Image(systemName: "trash")
                        }
                        .padding(.horizontal, 10)
                        
                        //Adds a new, blank rule to the list of rules.
                        Button {
                            numRules += 1
                            rules.append(Rule(number: numRules))
                            
                        } label: {
                            Image(systemName: "plus")
                        }
                        .padding(.horizontal, 10)
                    }
            }
        }
        
    }
    
    //Adds rules to replace a binary string with the lexographically next binary string.
    private func binaryIncrement() {
        rules = []
        rules.append(Rule(number: 1, read: "1", oldState: "1", write: "1", newState: "2", move: "R"))
        rules.append(Rule(number: 2, read: "0", oldState: "1", write: "0", newState: "2", move: "R"))
        rules.append(Rule(number: 3, read: "_", oldState: "1", write: "_", newState: "Reject", move: "R"))
        rules.append(Rule(number: 4, read: "1", oldState: "2", write: "1", newState: "2", move: "R"))
        rules.append(Rule(number: 5, read: "0", oldState: "2", write: "0", newState: "2", move: "R"))
        rules.append(Rule(number: 6, read: "_", oldState: "2", write: "_", newState: "3", move: "L"))
        rules.append(Rule(number: 7, read: "1", oldState: "3", write: "0", newState: "3", move: "L"))
        rules.append(Rule(number: 8, read: "_", oldState: "3", write: "0", newState: "Accept", move: "L"))
        rules.append(Rule(number: 9, read: "0", oldState: "3", write: "1", newState: "Accept", move: "L"))
        numRules = 9
    }
}

//Form the edit rule values
struct RuleForm: View {
    
    @Binding var rule: Rule
    
    var body: some View {
        Form {
            //Fields to edit the read value, and state the machine must be in for the rule to apply.
            HStack {
                TextField("Read:", text: $rule.read)
                Divider()
                TextField("Old State:", text: $rule.oldState)

            }
            //Fields to edit the written value, new state, and direction of movement
            HStack {
                TextField("Write:", text: $rule.write)
                Divider()
                TextField("New State:", text: $rule.newState)
                Divider()
                TextField("Move:", text: $rule.move)
            }
        }
    }
}

//Exension to compare equality of binding variables
extension Binding: Equatable where Value: Equatable {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
}

//Extension to hash the value of a binding variable
extension Binding: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        self.wrappedValue.hash(into: &hasher)
    }
}

