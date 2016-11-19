import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        initCoreData()
        return true
    }
}


private extension AppDelegate {
    func initCoreData() {
        _ = TFLBusStopStack.sharedDataStack
    }
}
