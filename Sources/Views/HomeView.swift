import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Image("LaunchBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // タイトルセクション
                    VStack(spacing: 8) {
                        Text("日本語検定")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("3級対策クイズ")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("50問演習")
                            .font(.system(size: 48, weight: .bold))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    .padding(.top, 40)
                    
                    // クイズボタングリッド
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(QuizTopic.allCases) { topic in
                                NavigationLink(destination: QuizView(topic: topic)) {
                                    Text(topic.title)
                                        .font(.headline)
                                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.8))
                                        .frame(maxWidth: .infinity, minHeight: 72)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                AdsManager.shared.preload()
            }
        }
    }
}
