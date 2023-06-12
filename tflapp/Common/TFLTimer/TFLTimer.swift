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
    var repeats : Bool = true
    let queue : DispatchQueue
    init?(timerInterVal: TimeInterval,repeats : Bool = true,using queue : DispatchQueue = DispatchQueue.main,timerHandler:TFLTimerHandler?) {
        self.timerInterval = TimeInterval(timerInterVal)
        self.timerHandler = timerHandler
        self.queue = queue
        self.repeats = repeats
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
        self.timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: self.repeats) { [weak self] _ in
            self?.queue.async{
                if let self = self {
                    self.timerHandler?(self)
                }
            }
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
