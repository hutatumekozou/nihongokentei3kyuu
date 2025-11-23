import Foundation

class QuizRepository: ObservableObject {
    static let shared = QuizRepository()
    
    private init() {}
    
    func loadQuestions(for topic: QuizTopic) -> [Question] {
        guard let url = Bundle.main.url(forResource: topic.fileName, withExtension: "json", subdirectory: "questions"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load questions for \(topic.fileName)")
            return []
        }
        
        do {
            let allQuestions = try JSONDecoder().decode([Question].self, from: data)
            let filtered = allQuestions.filter { $0.category == topic.category }
            let source = filtered.isEmpty ? allQuestions : filtered
            if filtered.isEmpty {
                print("Warning: No category match for \(topic.category). Falling back to full question set.")
            }
            
            let sorted = source.sorted { $0.id < $1.id }
            guard !sorted.isEmpty else { return [] }
            
            if topic.isSuddenDeath {
                return sorted
            }
            
            let lowerBound = min(topic.questionRange.lowerBound, sorted.count)
            let upperBound = min(topic.questionRange.upperBound, sorted.count)
            if lowerBound >= upperBound {
                return Array(sorted.prefix(min(10, sorted.count)))
            }
            return Array(sorted[lowerBound..<upperBound])
        } catch {
            print("Decoding error for \(topic.fileName): \(error)")
            return []
        }
    }
}
