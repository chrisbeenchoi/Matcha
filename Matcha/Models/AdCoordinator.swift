//
//  AdCoordinator.swift
//  Matcha
//
//  Created by Chris Choi on 9/12/23.
//

import Foundation
import SwiftUI
import GoogleMobileAds

// full screen ad - go thru SwifUI interstitial implementation, rewarded ad guide and combine as well as you can.
class AdCoordinator: NSObject {
    private var ad: GADRewardedAd?

    func loadAd() {
        print("load ad called")
        GADRewardedAd.load( // use test id. need my own ad unit id apparently
            withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest()) { ad, error in
                if let error = error {
                    print("REAL BAD ERROR")
                    return print("Failed to load ad with error: \(error.localizedDescription)")
                }
                self.ad = ad
                print("AD LOADED: INFO HERE", ad ?? "n/a")
        }
    }

    func presentAd(rewardFunction: @escaping () -> Void) -> Bool {
        guard let rewardedAd = ad else {
            print("NO AD HERE!!!!")
            return false
        }
        
        guard let root = UIApplication.shared.keyWindowPresentedController else {
            print("DID NOT GET ROOT")
            return false
        }
        
        print("GOT EVERYTHING AND IT SHOULD WORK TBH")
        rewardedAd.present(fromRootViewController: root, userDidEarnRewardHandler: rewardFunction)
        return true
    }
}

// okay so this is the stuff that takes the ads and passes them
// tbh confused on wtf this does
struct AdViewControllerRepresentable: UIViewControllerRepresentable {
    let viewController = UIViewController()

    func makeUIViewController(context: Context) -> some UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // No implementation needed. Nothing to update.
    }
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    var keyWindowPresentedController: UIViewController? {
        var viewController = self.keyWindow?.rootViewController
        
        if let presentedController = viewController as? UITabBarController {
            viewController = presentedController.selectedViewController
        }
        
        while let presentedController = viewController?.presentedViewController {
            if let presentedController = presentedController as? UITabBarController {
                viewController = presentedController.selectedViewController
            } else {
                viewController = presentedController
            }
        }
        return viewController
    }
}
