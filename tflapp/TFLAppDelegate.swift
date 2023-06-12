import UIKit
import CoreData
import CoreSpotlight


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    fileprivate let ratingController = TFLRatingController()
    fileprivate var spotlight : (lineRouteList:TFLLineInfoRouteDirectory,provider:TFLCoreSpotLightDataProvider)?
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
        DispatchQueue.global().async{
            let routeList = TFLLineInfoRouteDirectory.infoRouteDirectoryFromCoreData()
            let provider = TFLCoreSpotLightDataProvider(with: routeList)
            self.spotlight = (routeList,provider)
            
            provider.searchableItems { items in
                CSSearchableIndex.default().indexSearchableItems(items) { [weak self] error in
                    self?.spotlight = nil
                    if let _ = error {
                        return
                    }
                }
            }
        }
    }
}
