import UIKit
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var viewController: ViewController?
    var userInfoViewController: UserInfoViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        viewController = ViewController()
        let navigationController = UINavigationController(rootViewController: viewController!)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.scheme == "myapp" else {
            print("URL scheme not recognizes: \(url.scheme ?? "nil")")
            return false
        }
                
        if url.absoluteString.contains("callback/logout") {
            if let navController = window?.rootViewController as? UINavigationController,
               let userInfoVC = navController.viewControllers.compactMap({ $0 as? UserInfoViewController }).last {
                userInfoVC.handleLogout()
                return true
            } else {
                return false
            }
           
        } else {
            viewController?.handleCallbackURL(url)
        }
    
        return true
    }
}
