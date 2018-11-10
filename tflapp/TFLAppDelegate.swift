import UIKit
import CoreData
import CoreSpotlight


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let spotLightDataProvider = TFLCoreSpotLightDataProvider()
    var window: UIWindow?
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        initCoreData()
        setupSpotLight()
        _ = TFLLocationManager.sharedManager
        return true
    }
   
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                print(uniqueIdentifier)
            }
        }
        return true

    }
}


private extension AppDelegate {
    func initCoreData() {
        _ = TFLBusStopStack.sharedDataStack
    }
    
    func setupSpotLight() {
        let items = spotLightDataProvider.searchableItems()
        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let _ = error {
                return
            }
            print("done")
        }
    }
}
