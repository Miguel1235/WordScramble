import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = "Something"
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    private var totalScore: Int {
        return usedWords.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord).textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
                Section {
                    Text("Your total score is \(totalScore)")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button("Restart game") {
                        startGame()
                    }
                }
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) { }
            message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isOriginal(answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard !isShort(answer) else {
            wordError(title: "Short word", message: "You cant write such short word")
            return
        }
        
        guard !isSameWord(answer) else {
            wordError(title: "Same word", message: "The word you enter is the same as the starting one, be more creative!!")
                return
        }
        
        
        guard answer.count > 0 else { return }
        withAnimation(.spring.speed(0.1)) {
            usedWords.insert(answer, at: 0)
            newWord = ""
        }
    }
    
    func startGame() {
        guard let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") else {
            fatalError("Can't find start words file")
        }
        guard let startWords = try? String(contentsOf: startWordsUrl) else {
            fatalError("No starting words found")
        }
        
        let allWords = startWords.components(separatedBy: "\n")
        rootWord = allWords.randomElement() ?? "silkworm"
        usedWords = []
    }
    
    func isOriginal(_ word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            guard let pos = tempWord.firstIndex(of: letter) else { return false }
            tempWord.remove(at: pos)
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
        newWord = ""
    }
    
    func isShort(_ word: String) -> Bool {
        return word.count <= 3
    }
    func isSameWord(_ word: String) -> Bool {
        return word == rootWord
    }
}

#Preview {
    ContentView()
}
