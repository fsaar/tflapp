import UIKit
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        initCoreData()
        initFabric()
        return true
    }
}


private extension AppDelegate {
    func initCoreData() {
        _ = TFLBusStopStack.sharedDataStack
    }
    func initFabric() {
        Fabric.with([Crashlytics.self])
    }
}
