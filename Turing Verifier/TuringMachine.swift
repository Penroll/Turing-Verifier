//
//  TuringMachine.swift
//  Turing Verifier
//
//  Created by Seamus Grealey on 12/2/22.
//

import Foundation
import SwiftUI

struct TuringMachine: View {
    
    @Binding var rules: [Rule]
    
    var body: some View {
        VStack {
            Text("Turing Machine Simulator").font(.title)
                .fontWeight(.bold)
            TuringTape(rules: $rules)
        }
    }
}

struct TuringTape: View {
    
    @State var borderY: CGFloat = 0.0
    
    @Binding var rules: [Rule]
    
    @State var tapeChars: [String] = ["_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_"]
    
    @State var showValidRulesAlert = false
    
    @State var currentState = 1
    
    @State var inputChars = ""
    
    @State var showInputPrompt = false
    
    @State var showAccept = false
    
    @State var showReject = false
    
    @State var showHalt = false
    
    @State var finalRule: Rule = Rule(number: 0)
    
    var body: some View {
        VStack {
            
            Button(action: {
                borderY = 0.0
                for index in 0..<19 {
                    tapeChars[index] = "_"
                }
                let valid = checkValidRules()
                if(!valid) {
                    showValidRulesAlert = true
                }
                else {
                    showInputPrompt = true
                }
                
                //HERE WE NEED TO START RUNNING WITH THE RULES: CALL THE DAMN FUNCTION
                //  It will:
                //      - Prompt for an entry                                   DONE
                //      - Fill it in, centered in the set of tape boxes.        DONE
                //      - Start at Rule 1 and the start of the entry            HALF
                //      - Then, while it finds a valid entry, find a match to the state and read value from the list of rules.
                //      - If it finds accept or reject, tell them. If it goes 100 times through without halting, let them know and give an option to cancel the simulation.
                //      - If it halts, report the rule that it halted (name and summary)
                
            }, label: {
                Text("Run Simulation")
            })
            .disabled(showInputPrompt)
            .alert("Make sure there are accept and reject states, and the first rule starts at state 1.", isPresented: $showValidRulesAlert) {
                Button("Ok", role: .cancel) {}
            }
            .alert("Accepted at rule \(String(finalRule.number)) \n (\(finalRule.toString()))", isPresented: $showAccept) {
                Button("Ok", role: .cancel) {}
            }
            .alert("Rejected at rule \(String(finalRule.number)) \n (\(finalRule.toString()))", isPresented: $showReject) {
                Button("Ok", role: .cancel) {}
            }
            .alert("Halted at rule \(String(finalRule.number)) \n (\(finalRule.toString()))", isPresented: $showHalt) {
                Button("Ok", role: .cancel) {}
            }
            
            ZStack {
                VStack(spacing: 0) {
                    ForEach(1..<20) { index in
                        TuringTapeBox(index: index, text: $tapeChars[index - 1])
                    }
                }
                //Do the overlay here lol
                Rectangle()
                    .opacity(0)
                    .frame(width: 30, height: 30)
                    .border(.red, width: 2)
                    .offset(y: borderY)
                
                InputCharsPrompt(tapeChars: $tapeChars, showInputPrompt: $showInputPrompt, inputText: $inputChars, borderY: $borderY, rules: $rules, currentRule: $finalRule, showAccept: $showAccept, showReject: $showReject, showHalt: $showHalt)
                    
            }
            
        }
        
    }
    
    private func moveBorderLeft() {
        withAnimation(.default) {
            borderY = borderY - 30
        }
    }
    
    //This one is down
    private func moveBorderRight() {
        withAnimation(.default) {
            borderY = borderY + 30
        }
    }
    
    private func addNewTapeBox() {
        tapeChars.append("_")
    }
    
    private func checkValidRules() -> Bool {
        var hasAccept = false
        var hasReject = false
        for rule in rules {
            if(rule.newState.lowercased() == "accept") {
                hasAccept = true
            }
            if(rule.newState.lowercased() == "reject") {
                hasReject = true
            }
        }
        if(rules.isEmpty) {
            return false
        }
        else if(rules[0].oldState != "1") {
            return false
        }
        return hasAccept && hasReject
    }
    
    
    
}


struct TuringTapeBox: View {
    
    @State var index: Int
    
    @Binding var text: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Text(text)
            .padding(3)
            .frame(width: 30, height: 30)
            .background(.white)
            .foregroundColor(.black)
            .border(.black, width: 2)
            .transition(.opacity)
            .id("TapeBox" + String(index))
        
    }
}

struct InputCharsPrompt: View {
    
    @Binding var tapeChars: [String]
    
    @Binding var showInputPrompt: Bool
    
    @Binding var inputText: String
    
    @Binding var borderY: CGFloat
    
    @Binding var rules: [Rule]
    
    @Binding var currentRule: Rule
    
    @Binding var showAccept: Bool
    
    @Binding var showReject: Bool
    
    @Binding var showHalt: Bool
    
    @State var readyToRun: Bool = false
    
    @FocusState private var focusInput: Bool
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @State var indexHeld: Int = 0
    
    @State var hasNext: Bool = true
    
    @State var state: Int = 1
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .background(.white)
                .foregroundColor(.white)
                .frame(width: 250, height: 150)
                
            VStack {
                TextField("Input", text: $inputText)
                    .foregroundColor(.black)
                    .padding(10)
                    .frame(width: 225)
                    .border(.black, width: 1)
                    .padding(10)
                    .focused($focusInput)
                    
                Button(action: {
                    if(inputText != "") {
                        focusInput = false
                        showInputPrompt = false
                        fillInTape()
                        //move to start
                    }
                }, label: {
                    Text("Submit")
                })
                .onReceive(timer) { time in
                    if(readyToRun) {
                        timerLoop()
                    }
                }
                
            }
            
            
        }
        .frame(width: 250, height: 150)
        .border(.black, width: 3)
        .opacity(showInputPrompt ? 1 : 0)
    }
    
    private func fillInTape() {
        let start = 9 - (inputText.count / 2)
        let chars = Array(inputText)
        for index in 0..<inputText.count {
            tapeChars[index + start] = String(chars[index])
        }
        for _ in 0..<(inputText.count / 2) {
            moveBorderLeft()
        }
        state = 1
        indexHeld = start
        hasNext = true
        currentRule = rules[0]
        readyToRun = true
        
    }
    
    
    private func timerLoop() {
        var foundOne = false
        for rule in rules {
            if(rule.oldState == String(state) && rule.read == tapeChars[indexHeld]) {
                currentRule = rule
                if(rule.newState == "Accept") {
                    hasNext = false
                    tapeChars[indexHeld] = rule.write
                    reportAccept(rule: rule)
                    readyToRun = false
                    break
                }
                else if(rule.newState == "Reject") {
                    hasNext = false
                    tapeChars[indexHeld] = rule.write
                    reportReject(rule: rule)
                    readyToRun = false
                    break
                }
                else {
                    state = Int(rule.newState) ?? -1
                    tapeChars[indexHeld] = rule.write
                    if(rule.move == "R") {
                        indexHeld += 1
                        moveBorderRight()
                    }
                    else if(rule.move == "L") {
                        indexHeld -= 1
                        moveBorderLeft()
                    }
                    foundOne = true
                    
                    break
                }
            }
        }
        if(!foundOne && hasNext) {
            hasNext = false
            reportHalt(rule: currentRule)
            readyToRun = false
        }
    }
    
    
    private func reportHalt(rule: Rule) {
        showHalt = true
        print("That halted")
        print(rule.toString())
    }
    
    private func reportAccept(rule: Rule) {
        showAccept = true
        print("This Accepts:")
        print(rule.toString())
    }
    
    private func reportReject(rule: Rule) {
        showReject = true
        print("That shit rejected")
        print(rule.toString())
    }
    
    private func moveBorderLeft() {
        withAnimation(.default) {
            borderY = borderY - 30
        }
    }
    
    //This one is down
    private func moveBorderRight() {
        withAnimation(.default) {
            borderY = borderY + 30
        }
    }
}

