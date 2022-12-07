//
//  ContentView.swift
//  Turing Verifier
//
//  Created by Seamus Grealey on 12/2/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State var rules = [Rule(number: 1)]
    
    @State var r: Int = 1
    
    var body: some View {
        TabView {
            TuringMachine(rules: $rules)
                .tabItem {
                    Label("Simulation", systemImage: "faxmachine")
                }
            
            Rules(rules: $rules)
                .tabItem {
                    Label("Rules/Vars", systemImage: "list.bullet")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
