import SwiftUI

struct QuizView: View {
    let topic: QuizTopic
    @State private var questions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showExplanation = false
    @State private var correctAnswers = 0
    @State private var navigateToResult = false
    
    var body: some View {
        ZStack {
            Image("LaunchBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if !questions.isEmpty {
                    // 問題番号表示
                    HStack {
                        Text("第\(currentQuestionIndex + 1)問")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                        Text("\(currentQuestionIndex + 1) / \(questions.count)")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    // 問題文
                    Text(questions[currentQuestionIndex].question)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    // 選択肢
                    VStack(spacing: 12) {
                        ForEach(0..<questions[currentQuestionIndex].choices.count, id: \.self) { index in
                            Button(action: {
                                if selectedAnswer == nil {
                                    selectedAnswer = index
                                    showExplanation = true
                                }
                            }) {
                                HStack(alignment: .top, spacing: 12) {
                                    Text(questions[currentQuestionIndex].choices[index])
                                        .font(.body)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(
                                    Group {
                                        if showExplanation {
                                            if index == questions[currentQuestionIndex].answerIndex {
                                                Color.green.opacity(0.3)
                                            } else if index == selectedAnswer {
                                                Color.red.opacity(0.3)
                                            } else {
                                                Color.white
                                            }
                                        } else {
                                            Color.white
                                        }
                                    }
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            }
                            .disabled(selectedAnswer != nil)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 正解・不正解表示と解説
                    if showExplanation {
                        VStack(spacing: 12) {
                            // 正解・不正解表示
                            Text(selectedAnswer == questions[currentQuestionIndex].answerIndex ? "正解！" : "不正解")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(selectedAnswer == questions[currentQuestionIndex].answerIndex ? .black : .red)
                                .padding(.horizontal)
                            
                            // 解説
                            Text(questions[currentQuestionIndex].explanation)
                                .font(.body)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        
                        Button(action: nextQuestion) {
                            Text(currentQuestionIndex == questions.count - 1 ? "結果を見る" : "次の問題")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color(red: 0.2, green: 0.4, blue: 0.8))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(topic.title)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadQuestions()
        }
        .background(
            NavigationLink(
                destination: ResultView(topic: topic, correctAnswers: correctAnswers, totalQuestions: questions.count),
                isActive: $navigateToResult,
                label: { EmptyView() }
            )
        )
    }
    
    private func loadQuestions() {
        questions = QuizRepository.shared.loadQuestions(for: topic)
    }
    
    private func nextQuestion() {
        if let selected = selectedAnswer, selected == questions[currentQuestionIndex].answerIndex {
            correctAnswers += 1
        }
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showExplanation = false
        } else {
            navigateToResult = true
        }
    }
}
