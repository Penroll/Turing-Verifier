//
//  ContentView.swift
//  Turing Verifier
//
//  Created by Seamus Grealey on 12/2/22.
//

import SwiftUI
import CoreData

//Accepts a set of rules from the user, as well as an input, and runs a turing machine over the values
struct ContentView: View {
    
    //List of rules
    @State var rules = [Rule(number: 1)]
    
    var body: some View {
        TabView {
            //Simulator
            TuringMachine(rules: $rules)
                .tabItem {
                    Label("Simulation", systemImage: "faxmachine")
                }
            
            //List of rules
            Rules(rules: $rules)
                .tabItem {
                    Label("Rules/Vars", systemImage: "list.bullet")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
