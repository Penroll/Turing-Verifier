//
//  Rules.swift
//  Turing Verifier
//
//  Created by Seamus Grealey on 12/2/22.
//

import Foundation
import SwiftUI


struct Rules: View {
    
    @Binding var rules: [Rule]
    
    @State var numRules: Int = 1
    
    var body: some View {
        VStack {
            NavigationView {
                
                List($rules, id: \.self.uuid, editActions: .delete) { rule in
                    NavigationLink("Rule " + String(rule.wrappedValue.number), destination: RuleForm(rule: rule))
                }
                .navigationTitle("Rules")
                    .toolbar {
                        Menu {
                            Button("Binary Increment (HW)") {
                                binaryIncrement()
                            }
                        } label: {
                            Image(systemName: "gear")
                        }
                        .padding(.horizontal, 10)
                        
                        Button {
                            rules = []
                            numRules = 0
                        } label: {
                            Image(systemName: "trash")
                        }
                        .padding(.horizontal, 10)
                        
                        
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
    func deleteItems(at offsets: IndexSet) {
        rules.remove(atOffsets: offsets)
    }
    
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

struct RuleForm: View {
    
    @Binding var rule: Rule
    
    var body: some View {
        Form {
            HStack {
                TextField("Read:", text: $rule.read)
                Divider()
                TextField("Old State:", text: $rule.oldState)

            }
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



extension Binding: Equatable where Value: Equatable {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Binding: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        self.wrappedValue.hash(into: &hasher)
    }
}

