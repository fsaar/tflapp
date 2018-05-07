import Foundation

typealias TFLTimerHandler = (_ timer : TFLTimer)->()

 @objc public final class TFLTimer: NSObject {
    private var timerInterval : TimeInterval = 0.0
    var currentTimerInterval : TimeInterval {
        return self.timerInterval
    }
    private var timerHandler : TFLTimerHandler? = nil
    private var timer : Timer? = nil
    public var hasStarted : Bool  {
        let enabled = self.timer == nil ? false : true
        return (enabled)
    }
    
    init?(timerInterVal: TimeInterval,timerHandler:TFLTimerHandler?) {
        self.timerInterval = TimeInterval(timerInterVal)
        self.timerHandler = timerHandler
        super.init()
        let isZeroOrNegative =  self.timerInterval <= TimeInterval(0)
        let hasNilHandler = timerHandler == nil
        if isZeroOrNegative || hasNilHandler
        {
            return (nil)
        }
    }
        
    func start()
    {
        stop()
        self.timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [timerHandler] _ in
            timerHandler?(self)
        }
    }
    
    deinit
    {
        stop()
    }
    
    func stop()
    {
        self.timer?.invalidate()
        self.timer=nil
    }
}
