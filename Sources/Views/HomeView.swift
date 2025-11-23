import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                backgroundView
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 16) {
                        headerView
                        
                        LazyVGrid(columns: gridColumns, spacing: 10) {
                            ForEach(regularTopics) { topic in
                                sectionButton(for: topic)
                            }
                        }
                        
                        VStack(spacing: 12) {
                            Text("3回間違えたら終了モード")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: gridColumns, spacing: 10) {
                                ForEach(suddenDeathTopics) { topic in
                                    sectionButton(for: topic)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                AdsManager.shared.preload()
            }
        }
    }
    
    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 70), spacing: 8)]
    }
    
    private var headerView: some View {
        VStack(spacing: 6) {
            Text("日本語検定3級")
                .font(.system(size: 51, weight: .bold))
                .foregroundColor(.black)
            
            Text("本番テスト対策")
                .font(.system(size: 51, weight: .bold))
                .foregroundColor(.black)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 16)
    }
    
    private func sectionButton(for topic: QuizTopic) -> some View {
        NavigationLink(destination: QuizView(topic: topic)) {
            Text(topic.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.8))
                .frame(maxWidth: .infinity, minHeight: 34)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.15), radius: 1, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundView: some View {
        Image("LaunchBackground")
            .resizable()
            .scaledToFill()
    }
    
    private var regularTopics: [QuizTopic] {
        QuizTopic.allCases.filter { !$0.isSuddenDeath }
    }
    
    private var suddenDeathTopics: [QuizTopic] {
        QuizTopic.allCases.filter { $0.isSuddenDeath }
    }
}
