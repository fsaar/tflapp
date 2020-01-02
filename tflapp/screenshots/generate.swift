#!/usr/bin/swift

import Cocoa
import Foundation

let titles = [
    "Nearby arrivals at a glance\nby day ...      ",
    "... or by night",
    "Easy access to\nnearby bus stops",
    "Detailed information\na tap away",
    "Remind yourself\nwhen you need it"
]

extension CGSize {
    var formatString : String {
        return "\(self.width)x\(self.height)"
    }
}

enum ScreenSize : CaseIterable {
    case inch_4
    case inch_4_7
    case inch5_5
    case inch5_8
    case inch6_1
    case inch6_5
    
    var folder : String {
        switch self {
        case .inch_4:
            return "4_0"
        case .inch_4_7:
            return "4_7"
        case .inch5_5:
            return "5_5"
        case .inch5_8:
            return "5_8"
        case .inch6_1:
            return "6_1"
        case .inch6_5:
            return "6_5"
        }
    }
    var imageSize : CGSize {
        switch self {
        case .inch_4:
            return CGSize(width: 640, height: 1136)
        case .inch_4_7:
            return CGSize(width: 750,height: 1334)
        case .inch5_5:
            return CGSize(width: 1242,height: 2208)
        case .inch5_8:
            return CGSize(width: 1125,height: 2436)
        case .inch6_1:
            return CGSize(width: 828,height: 1792)
        case .inch6_5:
            return CGSize(width: 1242,height: 2688)
        }
    }
        
    var frameSize : CGSize {
        switch self {
        case .inch_4:
            return CGSize(width: 840, height: 1696)
        case .inch_4_7:
            return CGSize(width: 990,height: 1934)
        case .inch5_5:
            return CGSize(width: 1842,height: 3408)
        case .inch5_8:
            return CGSize(width: 1385,height: 2676)
        case .inch6_1:
            return CGSize(width: 1048,height: 2025)
        case .inch6_5:
            return CGSize(width: 1522,height: 2968)
        }
    }
    
    var frameFileName : String {
        switch self {
        case .inch_4:
            return "grey.png"
        case .inch_4_7:
            return "gold.png"
        case .inch5_5:
            return "black.png"
        case .inch5_8:
            return "gold.png"
        case .inch6_1:
            return "red.png"
        case .inch6_5:
            return "gold.png"
        }
    }
    
    var scaleInPercent : String {
        switch self {
        case .inch_4:
            return "60%"
        case .inch_4_7:
            return "65%"
        case .inch5_5:
            return "65%"
        case .inch5_8:
            return "80%"
        case .inch6_1:
            return "78%"
        case .inch6_5:
            return "80%"
        }
    }
    
    var frameOffSetString : String {
        switch self {
        case .inch_4:
            return "+0+60"
        case .inch_4_7:
            return "+0+60"
        case .inch5_5:
            return "+0+90"
        case .inch5_8:
            return "+0+100"
        case .inch6_1:
            return "+0+90"
        case .inch6_5:
            return "+0+90"
        }
    }
    
    var textSize : String {
        switch self {
        case .inch_4:
            return "700x140"
        case .inch_4_7:
            return "700x140"
        case .inch5_5:
            return "1000x220"
        case .inch5_8:
            return "900x300"
        case .inch6_1:
            return "750x210"
        case .inch6_5:
            return "1000x250"
        }
    }
    
    var fontSize : String {
        switch self {
        case .inch_4:
            return "40"
        case .inch_4_7:
            return "40"
        case .inch5_5:
            return "60"
        case .inch5_8:
            return "70"
        case .inch6_1:
            return "50"
        case .inch6_5:
            return "70"
        }
    }
}


func generateBackground(size : ScreenSize,for closure: @escaping (_ background : String,_ emptyFile : String) -> Void) {
    let imageSizeString = size.imageSize.formatString
    let frameSize = size.frameSize.formatString
    let generateBackgroundCmd = "magick -size \(imageSizeString) gradient:red-'rgb(50,0,0)' background.png"
    let generateEmptyCmd = "magick -size \(frameSize) xc:none empty.png"
    _ = shell(generateBackgroundCmd)
    _ = shell(generateEmptyCmd)
    closure("background.png","empty.png")
    _ = try? FileManager.default.removeItem(atPath: "background.png")
    _ = try? FileManager.default.removeItem(atPath: "empty.png")
}

func generateScreenShots(size : ScreenSize, _ background : String,_ emptyFile : String) {
    let currentURL = URL(fileURLWithPath: ".")
    guard let enumerator = FileManager.default.enumerator(at: currentURL, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey], options: [.skipsPackageDescendants,.skipsHiddenFiles],errorHandler: { _,_ in true }) else {
        return
    }
    let imageURLS =  enumerator.compactMap { $0 as? URL }.map { $0.lastPathComponent }.filter { $0.hasSuffix(".png") && $0.hasPrefix("iphone") }.sorted()
    
    for imageURL in imageURLS {
        let range = (imageURL as NSString).range(of: "\\d+\\.png", options: .regularExpression)
        guard range.location != NSNotFound else {
            continue
        }
        let index = ((imageURL as NSString).substring(with: range) as NSString).deletingPathExtension
        guard let idx = Int(index), 0..<titles.count ~= idx else {
            continue
        }
        let title = titles[idx]
        generateScreenShot(imageURL: imageURL, size: size,background:background,emptyFile: emptyFile, title: title)
    }
}

func generateScreenShot(imageURL : String,size : ScreenSize,background : String,emptyFile : String, title : String) {
    let newName = "\((imageURL as NSString).deletingPathExtension)_frame.png"
    
    let embedCMD = "magick composite -gravity center \(imageURL) \(emptyFile) \(newName)"
    let frameCMD = "magick composite -gravity center \(size.frameFileName) \(newName) \(newName)"
    let resizeCMD = "magick \(newName) -resize \(size.scaleInPercent) \(newName)"
    let mergeCMD = "magick composite -gravity center -geometry \(size.frameOffSetString) \(newName) \(background) \(newName)"
    let convertCMD = "convert -size \(size.textSize) xc:none -font Arial -pointsize \(size.fontSize) -fill white -gravity center -annotate +0+0 \"\(title)\" caption.png"
    let compositeCMD = "magick composite -gravity north caption.png \(newName) \(newName)"
    let removeCMD = "rm caption.png"
    let moveCMD = "mv \(newName) .."
    let commands = [embedCMD,frameCMD,resizeCMD,mergeCMD,convertCMD,compositeCMD,removeCMD,moveCMD]
    let cmd = commands.joined(separator: " && ")
    print("processing \(imageURL) ...")
    _ = shell(cmd)
    print("Generated \(newName)")
}

func shell(_ arguments: String...) -> String?
{
    let task = Process()
    task.launchPath =  "/bin/bash"
    task.arguments = ["-c"] + arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
     let output = String(data: data, encoding: .utf8)
    task.waitUntilExit()
    return output
}

let customDirectoryString = CommandLine.arguments.count > 1 ?  CommandLine.arguments[1] : "."
let baseURL = URL(string: customDirectoryString)

for size in ScreenSize.allCases {
    guard let folderURL = baseURL?.appendingPathComponent(size.folder, isDirectory: true) else {
        continue
    }
    guard FileManager.default.changeCurrentDirectoryPath(folderURL.absoluteString) else {
        continue
    }
    generateBackground(size: size) { background,emptyFile in
        generateScreenShots(size: size,background,emptyFile)
    }
    _ = FileManager.default.changeCurrentDirectoryPath("..")
}
