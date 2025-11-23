import Foundation

struct QuizTopic: Identifiable, Hashable {
    enum Mode {
        case regular
        case suddenDeath
    }
    
    let id: String
    let title: String
    let category: String
    let questionRange: Range<Int>
    let fileName: String
    let mode: Mode
    
    var isSuddenDeath: Bool { mode == .suddenDeath }
    
    init(
        id: String,
        title: String,
        category: String,
        questionRange: Range<Int>,
        fileName: String = "questions_ja3",
        mode: Mode = .regular
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.questionRange = questionRange
        self.fileName = fileName
        self.mode = mode
    }
}

extension QuizTopic: CaseIterable {
    static var allCases: [QuizTopic] = {
        guard let questions = loadAllQuestions() else {
            print("Warning: Failed to load questions for building topics. Falling back to default topics.")
            return defaultTopics
        }
        
        let preferredOrder = ["敬語", "文法", "語彙", "意味", "表記", "漢字", "総合"]
        let grouped = Dictionary(grouping: questions) { $0.category }
        
        var orderedEntries: [(String, [Question])] = []
        
        for category in preferredOrder {
            if let list = grouped[category] {
                orderedEntries.append((category, list))
            }
        }
        
        let remainingEntries = grouped
            .filter { !preferredOrder.contains($0.key) }
            .sorted { $0.key < $1.key }
        orderedEntries.append(contentsOf: remainingEntries)
        
        var topicSections: [QuizTopic] = []
        orderedEntries.forEach { category, list in
            topicSections.append(contentsOf: topics(for: category, questions: list))
        }
        
        orderedEntries.forEach { category, list in
            if let sudden = suddenDeathTopic(for: category, questions: list) {
                topicSections.append(sudden)
            }
        }
        
        return topicSections
    }()
    
    private static func loadAllQuestions() -> [Question]? {
        guard let url = Bundle.main.url(forResource: "questions_ja3", withExtension: "json", subdirectory: "questions"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        return try? JSONDecoder().decode([Question].self, from: data)
    }
    
    private static func topics(for category: String, questions: [Question]) -> [QuizTopic] {
        let sorted = questions.sorted { $0.id < $1.id }
        guard !sorted.isEmpty else { return [] }
        let chunkCount = Int(ceil(Double(sorted.count) / 10.0))
        var topics: [QuizTopic] = []
        
        for chunk in 0..<chunkCount {
            let start = chunk * 10
            let end = min(start + 10, sorted.count)
            let title = chunkCount == 1 ? category : "\(category) 第\(chunk + 1)セット"
            let topic = QuizTopic(
                id: "\(category)-\(chunk + 1)",
                title: title,
                category: category,
                questionRange: start..<end,
                mode: .regular
            )
            topics.append(topic)
        }
        
        return topics
    }
    
    private static func suddenDeathTopic(for category: String, questions: [Question]) -> QuizTopic? {
        guard !questions.isEmpty else { return nil }
        return QuizTopic(
            id: "\(category)-sudden",
            title: "\(category)（3ミス終了）",
            category: category,
            questionRange: 0..<questions.count,
            mode: .suddenDeath
        )
    }
    
    private static var defaultTopics: [QuizTopic] {
        let categories = ["敬語", "文法", "語彙", "意味", "表記", "漢字", "総合"]
        return categories.map {
            QuizTopic(
                id: "\($0)-1",
                title: $0,
                category: $0,
                questionRange: 0..<10,
                mode: .regular
            )
        }
    }
}
