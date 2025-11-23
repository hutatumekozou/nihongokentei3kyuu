import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                backgroundView
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    headerView
                    
                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        ForEach(QuizTopic.allCases) { topic in
                            sectionButton(for: topic)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
            .onAppear {
                AdsManager.shared.preload()
            }
        }
    }
    
    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 90), spacing: 12)]
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
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.8))
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundView: some View {
        Image("LaunchBackground")
            .resizable()
            .scaledToFill()
    }
}
