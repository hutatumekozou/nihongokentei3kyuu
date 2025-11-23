import SwiftUI

struct ResultView: View {
    let topic: QuizTopic
    let correctAnswers: Int
    let totalQuestions: Int
    let wrongAnswers: Int
    let isSuddenDeath: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    private var scorePercentage: Double {
        Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    private var resultMessage: String {
        switch scorePercentage {
        case 81...100:
            return "素晴らしい！完璧に理解されています！\nこの調子で頑張ってください！"
        case 61...80:
            return "よくできました！\nもう少し勉強すれば満点も夢じゃありません！"
        case 41...60:
            return "まずまずの結果ですね。\n基礎をしっかり固めて再挑戦しましょう！"
        case 21...40:
            return "もう少し頑張りましょう！\n諦めずに勉強を続ければ必ず上達します！"
        default: // 0-20%
            return "大丈夫です、最初は誰でもこんなものです。\n一歩ずつ着実に学んでいきましょう！"
        }
    }
    
    private var illustrationColor: Color {
        switch scorePercentage {
        case 81...100:
            return Color.green
        case 61...80:
            return Color.blue
        case 41...60:
            return Color.orange
        case 21...40:
            return Color.purple
        default: // 0-20%
            return Color.pink
        }
    }
    
    private var suddenDeathMessage: String? {
        guard isSuddenDeath, wrongAnswers >= 3 else { return nil }
        return "3回間違えたため終了しました。"
    }
    
    var body: some View {
        ZStack {
            // グラデーション背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.6, green: 0.8, blue: 1.0),
                    Color(red: 0.4, green: 0.6, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // タイトル
                Text("クイズ結果")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                // トピック名
                Text(topic.title)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                // スコア表示
                VStack(spacing: 15) {
                    Text("\(correctAnswers) / \(totalQuestions)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(String(format: "%.0f%%", scorePercentage))
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    if let suddenDeathMessage {
                        Text(suddenDeathMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(20)
                
                // イラストと激励メッセージエリア
                VStack(spacing: 15) {
                    // メッセージ
                    Text(resultMessage)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true) // メッセージを複数行で全文表示できるように修正
                    
                    // 女性のイラスト
                    if let uiImage = UIImage(named: "woman_illustration") ?? 
                       UIImage(contentsOfFile: Bundle.main.path(forResource: "woman_illustration", ofType: "png") ?? "") ?? 
                       UIImage(contentsOfFile: "/Users/kukkiiboy/Desktop/Claude code/FK2QuizApp/Resources/Assets/woman_illustration.png") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 240)
                            .padding(.horizontal, 8)
                            .clipShape(RoundedRectangle(cornerRadius: 15)) // イラストをカード幅いっぱいに近いサイズへ拡大
                    } else {
                        // フォールバック用のSF Symbol
                        Image(systemName: "figure.seated.side")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(illustrationColor)
                            .frame(maxWidth: .infinity, maxHeight: 240)
                            .padding(.horizontal, 8) // フォールバックも同じサイズ感で表示
                    }
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                
                Spacer()
                
                // ボタン
                Button(action: {
                    // 広告表示後に確実に初期画面（メニュー）に戻る
                    AdsManager.shared.showInterstitialAndReturnToRoot()
                }) {
                    Text("最初に戻る")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color(red: 0.2, green: 0.4, blue: 0.8))
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}
