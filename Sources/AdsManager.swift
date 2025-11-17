import Foundation
import UIKit
import SwiftUI

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

class AdsManager: NSObject, ObservableObject {
    static let shared = AdsManager()
    
    #if canImport(GoogleMobileAds)
    private var interstitial: GADInterstitialAd?
    #endif
    
    private var afterDismissCallback: (() -> Void)?
    private var isPresenting = false
    
    private override init() {
        super.init()
    }
    
    private var adUnitID: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/4411468910" // テスト用
        #else
        return "ca-app-pub-8365176591962448/5587845545" // 本番用
        #endif
    }
    
    func preload() {
        #if canImport(GoogleMobileAds)
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                #if DEBUG
                print("[Ads] Failed to load interstitial: \(error.localizedDescription)")
                #endif
                self.interstitial = nil
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            #if DEBUG
            print("[Ads] ✅ Interstitial loaded successfully")
            #endif
        }
        #endif
    }
    
    /// 広告表示後に確実に初期画面に戻る
    func showInterstitialAndReturnToRoot() {
        // 二重実行防止
        guard !isPresenting else {
            #if DEBUG
            print("[Ads] ⚠️ Already presenting, forcing return to root immediately")
            #endif
            returnToRootScreen()
            return
        }
        
        self.afterDismissCallback = { [weak self] in
            guard let self = self else { return }
            self.isPresenting = false
            #if DEBUG
            print("[Ads] 🔄 Executing afterDismiss callback - returning to root")
            #endif
            DispatchQueue.main.async {
                self.returnToRootScreen()
            }
        }
        
        #if canImport(GoogleMobileAds)
        guard let interstitial = interstitial,
              let topViewController = Self.getTopViewController() else {
            #if DEBUG
            print("[Ads] ⚠️ Interstitial not ready or no top VC, returning to root immediately")
            #endif
            self.returnToRootScreen()
            return
        }
        
        isPresenting = true
        #if DEBUG
        print("[Ads] 🎬 Presenting interstitial ad")
        #endif
        interstitial.present(fromRootViewController: topViewController)
        #else
        // GoogleMobileAds が利用できない場合のシミュレーション
        #if DEBUG
        print("[Ads] 🎭 Simulating ad display")
        #endif
        isPresenting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.afterDismissCallback?()
            self.afterDismissCallback = nil
        }
        #endif
    }
    
    /// 確実に初期画面（HomeView）に戻る
    private func returnToRootScreen() {
        DispatchQueue.main.async {
            #if DEBUG
            print("[Ads] 🏠 Returning to root screen - creating new HomeView")
            #endif
            
            // UIWindowのrootViewControllerを直接操作して確実に初期画面に戻る
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                #if DEBUG
                print("[Ads] ❌ Cannot get window")
                #endif
                return
            }
            
            // 新しいHomeViewを作成してrootViewControllerに設定
            let newHomeView = HomeView()
            let hostingController = UIHostingController(rootView: newHomeView)
            
            // NavigationControllerでラップ
            let navigationController = UINavigationController(rootViewController: hostingController)
            navigationController.setNavigationBarHidden(true, animated: false)
            
            // アニメーション付きで切り替え
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = navigationController
            } completion: { _ in
                #if DEBUG
                print("[Ads] ✅ Successfully returned to root screen")
                #endif
            }
        }
    }
    
    /// 最上位のViewControllerを取得
    static func getTopViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.rootViewController }
            .first
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController,
           let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

#if canImport(GoogleMobileAds)
extension AdsManager: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        #if DEBUG
        print("[Ads] 🚪 Interstitial dismissed by user")
        #endif
        interstitial = nil
        afterDismissCallback?()
        afterDismissCallback = nil
        
        // 次の広告をプリロード
        preload()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        #if DEBUG
        print("[Ads] ❌ Failed to present interstitial: \(error.localizedDescription)")
        #endif
        interstitial = nil
        afterDismissCallback?()
        afterDismissCallback = nil
        
        // 失敗時も次の広告をプリロード
        preload()
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        #if DEBUG
        print("[Ads] 🎬 Interstitial will present")
        #endif
    }
}
#endif
