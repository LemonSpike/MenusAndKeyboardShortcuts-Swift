/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The main scene delegate to this sample.
*/

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let splitViewController = window!.rootViewController as? UISplitViewController {
            splitViewController.delegate = self
            splitViewController.preferredDisplayMode = .allVisible
            
            // For Mac Catalyst, make the master view controller's background semi-transparent.
            splitViewController.primaryBackgroundStyle = .sidebar
        }
    }

    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController =
            secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController =
            secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that you have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}

