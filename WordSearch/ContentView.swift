//
//  ContentView.swift
//  WordSearch
//
//  Created by JFJ on 16/01/2020.
//  Copyright © 2020 JFJ. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        
        NavigationView {
            VStack{
                TextField(" Enter  your world", text: $newWord, onCommit: addNewWord).textFieldStyle(RoundedBorderTextFieldStyle()).padding().autocapitalization(.none)
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
        .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        
        
    }
    
    func addNewWord() {
        //lowercase and trime the word
        let answer =
        newWord.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        //exit if the remaining sting is empty
        guard answer.count > 0 else{
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be Original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognised", message: "Fake Word")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word Not possible", message: "That isn't a real word")
            return 
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        
        //1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt"){
        //2. Load start.txt into a string
        if let startWords = try? String(contentsOf: startWordsURL) {
            //3. Split the string up into an array of strings, splitting on line breaks
            let allWords = startWords.components(separatedBy: "\n")
            
            //4. Pick a random word or use gold as a default
            
            rootWord = allWords.randomElement() ?? "silkworm"
            
            // if we are here everything went well
            return
        }
    }
    
    
    //if we are here then there is a problem and we need to trigger a crash and report the error.
    
    fatalError("Could not load start.txt from app bundle.")
}
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
