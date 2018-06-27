import Foundation
import UIKit
import Fabric
import Crashlytics

extension Crashlytics {
    class func log(_ message : String, file: String = #file ,function: String = #function,line: Int = #line)
    {
        let validFile=URL(fileURLWithPath: file).lastPathComponent
        CLSLogv("%@:%d:%@:%@",getVaList([validFile,line,function,message]))
    }

    class func notify(_ file: String = #file ,function: String = #function ,line: Int = #line)
    {
        CLSLogv("%@:%@:%d",getVaList([file,function,line]))
    }
}

extension Answers {
    enum TFLEventType : String {
        case refresh
        case mapSlider
    }
}
