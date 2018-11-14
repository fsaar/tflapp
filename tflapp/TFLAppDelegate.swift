import UIKit
import CoreData
import CoreSpotlight


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 
    var window: UIWindow?
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        initCoreData()
        setupSpotLight()
        _ = TFLLocationManager.sharedManager
        return true
    }
   
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            NotificationCenter.default.post(name: NSNotification.Name.spotLightLineLookupNotification, object: nil, userInfo: userActivity.userInfo)
            return true
        }
        return false
    }
}


private extension AppDelegate {
    func initCoreData() {
        _ = TFLBusStopStack.sharedDataStack
    }
    
    func setupSpotLight() {
        DispatchQueue.global().async {
            let lineRouteList = TFLLineInfoRouteDirectory()
            let provider = TFLCoreSpotLightDataProvider(with: lineRouteList)
            provider.searchableItems { items in
                CSSearchableIndex.default().indexSearchableItems(items) { error in
                    if let _ = error {
                        return
                    }
                }
            }
        }
    }
}
