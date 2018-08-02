import UIKit

private extension Selector {
    static let notificationHandler = #selector(TFLNotificationObserver.notificationHandler(_:))
}

public typealias TFLNotificationObserverBlock = (_ notification : Notification)-> Void

@objc public final class TFLNotificationObserver: NSObject {

    fileprivate let handlerBlock : TFLNotificationObserverBlock
    fileprivate var notification : String
    fileprivate var object : AnyObject? = nil
    public var enabled : Bool = true
    public init(notification: String,object : AnyObject? ,handlerBlock: @escaping TFLNotificationObserverBlock)
    {
        self.handlerBlock=handlerBlock
        self.object = object
        self.notification=notification
        super.init()
        __addObserver()
    }

    public convenience init(notification: Notification.Name,handlerBlock: @escaping TFLNotificationObserverBlock)
    {
        self.init(notification: notification.rawValue,object: nil,handlerBlock: handlerBlock)
    }

    deinit
    {
        __removeObserver()
    }
}

// MARK: Observer Handling

extension TFLNotificationObserver {
    fileprivate func __addObserver()
    {
        NotificationCenter.default.addObserver(self, selector: .notificationHandler, name:NSNotification.Name(rawValue: self.notification), object: self.object)
    }

    fileprivate func __removeObserver()
    {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func notificationHandler(_ notification : Notification)
    {
        if enabled
        {
            handlerBlock(notification)
        }
    }
}
