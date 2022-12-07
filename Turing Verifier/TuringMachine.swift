//
//  TuringMachine.swift
//  Turing Verifier
//
//  Created by Seamus Grealey on 12/2/22.
//

import Foundation
import SwiftUI

//Main struct for the turing machine simulator
struct TuringMachine: View {
    
    //Ruleset for the simulation
    @Binding var rules: [Rule]
    
    var body: some View {
        VStack {
            Text("Turing Machine Simulator").font(.title)
                .fontWeight(.bold)
            TuringTape(rules: $rules)
        }
    }
}

//Actual tape that the simulation will be run on
struct TuringTape: View {
    
    //Offset of the highlighting square, used to show which value is being iterated over
    @State var borderY: CGFloat = 0.0
    
    //Ruleset for the simulation
    @Binding var rules: [Rule]
    
    //Characters stored on the tape, by default, all are blank
    @State var tapeChars: [String] = ["_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_"]
    
    //State variable to show an alert if the rules are insufficient to run the simulation
    @State var showValidRulesAlert = false
    
    //Current state of the turing machine, by default it is in the first state
    @State var currentState = 1
    
    //String to hold the characters that are input to the simulation
    @State var inputChars = ""
    
    //State variable to show the prompt to the user for input
    @State var showInputPrompt = false
    
    //State variable to show the user that the simulation accepted
    @State var showAccept = false
    
    //State variable to show the user that the simulation rejected
    @State var showReject = false
    
    //State variable to show the user that the simulation halted
    @State var showHalt = false
    
    //Records the last rule executed, to show the user the rule where the turing machine stopped.
    @State var finalRule: Rule = Rule(number: 0)
    
    var body: some View {
        VStack {
            //Button to run the simulation
            Button(action: {
                borderY = 0.0
                //Fills in the tape characters
                for index in 0..<19 {
                    tapeChars[index] = "_"
                }
                //Checks if the rules are valid, if they are, it runs the simulation
                let valid = checkValidRules()
                if(!valid) {
                    showValidRulesAlert = true
                }
                else {
                    showInputPrompt = true
                }
            }, label: {
                Text("Run Simulation")
            })
            .disabled(showInputPrompt)
            //Alert to let the user know the rules are invalid
            .alert("Make sure there are accept and reject states, and the first rule starts at state 1.", isPresented: $showValidRulesAlert) {
                Button("Ok", role: .cancel) {}
            }
            //Alert to let the user know the simulation accepted
            .alert("Accepted at rule \(String(finalRule.number)) \n (\(finalRule.toString()))", isPresented: $showAccept) {
                Button("Ok", role: .cancel) {}
            }
            //Alert to let the user know the simulation rejected
            .alert("Rejected at rule \(String(finalRule.number)) \n (\(finalRule.toString()))", isPresented: $showReject) {
                Button("Ok", role: .cancel) {}
            }
            //Alert to let the user know the simulation halted
            .alert("Halted at rule \(String(finalRule.number)) \n (\(finalRule.toString()))", isPresented: $showHalt) {
                Button("Ok", role: .cancel) {}
            }
            
            ZStack {
                //List of tape spaces (first iteration uses 19)
                VStack(spacing: 0) {
                    ForEach(1..<20) { index in
                        TuringTapeBox(index: index, text: $tapeChars[index - 1])
                    }
                }
                //Highlighting rectangle, tracks the currently edited tape piece
                Rectangle()
                    .opacity(0)
                    .frame(width: 30, height: 30)
                    .border(.red, width: 2)
                    .offset(y: borderY)
                
                //Prompt to input the characters, this call also runs the actualy simulation
                InputCharsPrompt(tapeChars: $tapeChars, showInputPrompt: $showInputPrompt, inputText: $inputChars, borderY: $borderY, rules: $rules, currentRule: $finalRule, showAccept: $showAccept, showReject: $showReject, showHalt: $showHalt)
            }
        }
    }
    
    //Adds a new tape box to the list
    private func addNewTapeBox() {
        tapeChars.append("_")
    }
    
    //Checks for a valid set of rules
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
        ///The ruleset must be nonempty, have the first rule start at state 1,
        ///and include a reject and accept state.
        if(rules.isEmpty) {
            return false
        }
        else if(rules[0].oldState != "1") {
            return false
        }
        return hasAccept && hasReject
    }
}

//Struct for each turing tape box
struct TuringTapeBox: View {
    
    //Index to track which index of the character array this box is assigned to
    @State var index: Int
    
    //Text being displayed in the box
    @Binding var text: String
    
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

//Struct to get user input, as well as run the simulation
struct InputCharsPrompt: View {
    
    //List of the tape characters
    @Binding var tapeChars: [String]
    
    //Boolean to show the user an input prompt
    @Binding var showInputPrompt: Bool
    
    //Input text the user gives the simulation
    @Binding var inputText: String
    
    //Offset of the highlighted tape box
    @Binding var borderY: CGFloat
    
    //List of rules for the simluation
    @Binding var rules: [Rule]
    
    //Rule currently being iterated over
    @Binding var currentRule: Rule
    
    //Variable to show the user the simulation accepted
    @Binding var showAccept: Bool
    
    //Variable to show the user the simulation rejected
    @Binding var showReject: Bool
    
    //Variable to show the user the simulation halted
    @Binding var showHalt: Bool
    
    //State variable to let the timer begin running the simulation
    @State var readyToRun: Bool = false
    
    //FocusState variable to show/hide the keyboard
    @FocusState private var focusInput: Bool
    
    //Index of the tape being iterated over
    @State var indexHeld: Int = 0
    
    //Sees if there is a rule that is able to be accessed
    @State var hasNext: Bool = true
    
    //Holds the current state of the simulation
    @State var state: Int = 1
    
    //Timer to keep the simulation going to the next step each half second
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
    
    //Fills in the tape, resets variables to original values
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
    
    //Goes through a single step of the simulation
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
    
    //Reports a halt in the simulation to the console
    private func reportHalt(rule: Rule) {
        showHalt = true
        print("That halted")
        print(rule.toString())
    }
    
    //Reports an accept in the simulation to the console
    private func reportAccept(rule: Rule) {
        showAccept = true
        print("This Accepts:")
        print(rule.toString())
    }
    
    //Reports a rejection in the simulation to the console
    private func reportReject(rule: Rule) {
        showReject = true
        print("That shit rejected")
        print(rule.toString())
    }
    
    //Moves the cursor for the tape to the left(up)
    private func moveBorderLeft() {
        withAnimation(.default) {
            borderY = borderY - 30
        }
    }
    
    //Moves the cursor for the tape to the right(down)
    private func moveBorderRight() {
        withAnimation(.default) {
            borderY = borderY + 30
        }
    }
}

