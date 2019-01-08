//
//  Helper.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit
import Photos

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

typealias Json = [String : Any]

extension AVAsset {
    
    func createThumbnailOfVideo() -> UIImage? {
        let assetImgGenerate = AVAssetImageGenerator(asset: self)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func createThumbnailOfVideoAsync(completion: @escaping (UIImage?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let assetImgGenerate = AVAssetImageGenerator(asset: self)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTimeMakeWithSeconds(0, preferredTimescale: 600)
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                DispatchQueue.main.async {
                    completion(UIImage(cgImage: img))
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    static func createThumbnailOfVideoFromRemoteUrl(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        return asset.createThumbnailOfVideo()
    }
    
    static func createCompositionFromAsset(asset: AVAsset, repeatCount: UInt8 = 16) -> AVMutableComposition {
        let composition = AVMutableComposition()
        let timescale = asset.duration.timescale
        let duration = asset.duration.value
        let editRange = CMTimeRangeMake(start: CMTimeMake(value: 0, timescale: timescale), duration: CMTimeMake(value: duration, timescale: timescale))
        try! composition.insertTimeRange(editRange, of: asset, at: composition.duration)
        for _ in 0 ..< repeatCount - 1 {
            try! composition.insertTimeRange(editRange, of: asset, at: composition.duration)
        }
        return composition
    }
    
    static func compressVideo(inputURL: URL, outputURL: URL, completion: @escaping () -> ()) {
        //setup video writer
        let asset = AVAsset(url: inputURL)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
        let writerSettings: [String : Any] = [AVVideoCodecKey : AVVideoCodecType.h264, AVVideoCompressionPropertiesKey : [AVVideoAverageBitRateKey : 1800000], AVVideoWidthKey : 1280, AVVideoHeightKey : 720]
        
        let writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: writerSettings)
        writerInput.expectsMediaDataInRealTime = true
        writerInput.transform = videoTrack.preferredTransform
        let writer = try! AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
        writer.add(writerInput)
        //setup video reader
        let readerSettings: [String : Any] = [String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]
        
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerSettings)
        let videoReader = try! AVAssetReader(asset: asset)
        videoReader.add(readerOutput)
        //setup audio writer
        let audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
        audioWriterInput.expectsMediaDataInRealTime = false
        writer.add(audioWriterInput)
        //setup audio reader
        let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first!
        let audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        let audioReader = try! AVAssetReader(asset: asset)
        audioReader.add(audioReaderOutput)
        writer.startWriting()
        
        //start writing from video reader
        videoReader.startReading()
        writer.startSession(atSourceTime: CMTime.zero)
        let processingQueue = DispatchQueue(label: "Queue1")
        
        writerInput.requestMediaDataWhenReady(on: processingQueue)
        {
            while writerInput.isReadyForMoreMediaData
            {
                let sampleBuffer: CMSampleBuffer? = readerOutput.copyNextSampleBuffer()
                
                if videoReader.status == .reading && sampleBuffer != nil
                {
                    writerInput.append(sampleBuffer!)
                }
                else
                {
                    writerInput.markAsFinished()
                    if videoReader.status == .completed
                    {
                        //start writing from audio reader
                        audioReader.startReading()
                        writer.startSession(atSourceTime: CMTime.zero)
                        let processingQueue = DispatchQueue(label: "Queue2")
                        audioWriterInput.requestMediaDataWhenReady(on: processingQueue)
                        {
                            while audioWriterInput.isReadyForMoreMediaData
                            {
                                let sampleBuffer:CMSampleBuffer? = audioReaderOutput.copyNextSampleBuffer()
                                if audioReader.status == .reading && sampleBuffer != nil
                                {
                                    audioWriterInput.append(sampleBuffer!)
                                }
                                else
                                {
                                    audioWriterInput.markAsFinished()
                                    if audioReader.status == .completed
                                    {
                                        writer.finishWriting()
                                            {
                                                completion()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension URLSession {
    
    class func getImage(url: URL, completion: @escaping (UIImage?) -> ()) {
        shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(UIImage(data: data!))
                } else {
                    completion(nil)
                }
            }
        }.resume()
    }
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    convenience init(hex: String, alpha: CGFloat = 1) {
        self.init(r: CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF), g: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF), b: CGFloat((Int(hex, radix: 16)!) & 0xFF), a: alpha)
    }
}

extension FileManager {
    
    func directoryExists(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    func changeUrlIfExists(_ url: URL) -> URL {
        var url = url
        var index = 1
        while fileExists(atPath: url.path) {
            var pathComponent = url.deletingPathExtension().lastPathComponent
            if index > 1 {
                pathComponent = pathComponent.replacingOccurrences(of: "\(index - 1)", with: "")
            }
            pathComponent += "\(index)"
            url = url.deletingLastPathComponent().appendingPathComponent(pathComponent)
                .appendingPathExtension(url.pathExtension)
            index += 1
        }
        return url
    }
}

extension UIView {
    
    class func animate(_ duration: Double, delay: Double = 0, damping: CGFloat, velocity: CGFloat, options: UIView.AnimationOptions = [], animation: @escaping () -> (), completion: @escaping (Bool) -> ()) {
        animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: options, animations: animation, completion: completion)
    }
    
    class func animate(_ duration: Double, delay: Double = 0, damping: CGFloat, velocity: CGFloat, options: UIView.AnimationOptions = [], animation: @escaping () -> ()) {
        animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: options, animations: animation)
    }
    
    class func animate(_ duration: Double, options: UIView.AnimationOptions = [], animation: @escaping () -> (), completion: @escaping (Bool) -> ()) {
        animate(withDuration: duration, delay: 0, options: options, animations: animation, completion: completion)
    }
    
    class func animate(_ duration: Double, options: UIView.AnimationOptions = [], animation: @escaping () -> ()) {
        animate(withDuration: duration, delay: 0, options: options, animations: animation)
    }
    
    convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            layer.cornerRadius = radius
            guard !corners.contains(.allCorners) else { return }
            layer.maskedCorners = []
            if corners.contains(.topLeft) {
                layer.maskedCorners.insert(.layerMaxXMinYCorner)
            }
            if corners.contains(.topRight) {
                layer.maskedCorners.insert(.layerMinXMinYCorner)
            }
            if corners.contains(.bottomLeft) {
                layer.maskedCorners.insert(.layerMinXMaxYCorner)
            }
            if corners.contains(.bottomRight) {
                layer.maskedCorners.insert(.layerMaxXMaxYCorner)
            }
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
    
    func makeCard(with cornerRadius: CGFloat = 12, shadowOpacity: Float, shadowRadius: CGFloat, shadowOffset: CGSize = .zero, shadowColor: UIColor) {
        layer.cornerRadius = cornerRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
    }
}

extension UIViewController {
    
    func removeFromParentVC() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    func addChildController(_ childController: UIViewController) {
        addChild(childController)
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    func addChildController(_ childController: UIViewController, parentView: UIView) {
        addChild(childController)
        parentView.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    class func instantiate(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> Self {
        return instantiateHelper(storyboard)
    }
    
    private class func instantiateHelper<T>(_ storyboard: UIStoryboard) -> T {
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! T
    }
}

extension URLSessionDownloadTask {
    
    var id: String? {
        get {
            return getValueOfProperty(with: "id")
        }
        set {
            setValue(newValue, ofPropertyWith: "id")
        }
    }
    
    var title: String? {
        get {
            return getValueOfProperty(with: "title")
        }
        set {
            setValue(newValue, ofPropertyWith: "title")
        }
    }
    
    private func getValueOfProperty(with name: String) -> String? {
        guard let description = taskDescription, !description.isEmpty else { return nil }
        guard let data = description.data(using: .utf8) else { return nil }
        guard let json = (try? JSONSerialization.jsonObject(with: data))
            as? [String : String] else { return nil }
        return json[name]
    }
    
    private func setValue(_ value: String?, ofPropertyWith name: String) {
        var json = [String : String]()
        if let description = taskDescription, !description.isEmpty {
            guard let data = description.data(using: .utf8) else { return }
            guard let jsonObject = (try? JSONSerialization.jsonObject(with: data))
                as? [String : String] else { return }
            json = jsonObject
        }
        json[name] = value
        guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
        taskDescription = String(data: data, encoding: .utf8)
    }
    
    var url: URL? {
        guard let originalRequestUrl = originalRequest?.url else {
            return currentRequest?.url
        }
        return originalRequestUrl
    }
}

extension Array where Element: Hashable {
    
    func after(item: Element) -> Element? {
        if let index = index(of: item), index + 1 < count {
            return self[index + 1]
        }
        return nil
    }
    
    func before(item: Element) -> Element? {
        if let index = index(of: item), index > 0 {
            return self[index - 1]
        }
        return nil
    }
}

extension UIFont {
    
    func sizeOfString(string: String, constrainedToWidth width: CGFloat) -> CGSize {
        let attributes = [NSAttributedString.Key.font : self,]
        let attString = NSAttributedString(string: string,attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attString)
        return CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), nil)
    }
}

extension String {
    
    func sizeForMaxWidth(_ width: CGFloat, font: UIFont) -> CGSize {
        let textView = UITextView()
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.textContainerInset.top = 2
        textView.text = self
        textView.font = font
        let constraintSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let size = textView.sizeThatFits(constraintSize)
        return size
    }
    
    func textSizeForMaxWidth(_ width: CGFloat, font: UIFont) -> CGSize {
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        return self.boundingRect(with: constraintSize, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine, .usesFontLeading], attributes: [.font : font], context: nil).size
    }
    
    func getAttributedString(font: UIFont, lineSpace: CGFloat? = nil) -> NSAttributedString {
//        let paragraphStyle = NSMutableParagraphStyle()
//        if let lineSpace = lineSpace {
//            paragraphStyle.lineSpacing = lineSpace
//        }

        //paragraphStyle.alignment = .natural
        
//        let attributes: [NSAttributedString.Key : Any] = [
//            NSAttributedString.Key.font : font,
//            NSAttributedString.Key.foregroundColor : UIColor.black,
//            NSAttributedString.Key.paragraphStyle : paragraphStyle,
//            ]
        
        let ctfont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        
        let attributes: [NSAttributedString.Key : Any] = [kCTFontAttributeName as NSAttributedString.Key : ctfont]
        
        return NSAttributedString(string: self, attributes: attributes)
    }
    
    var isLink: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        return !matches.isEmpty
    }
    
    var url: URL? {
        guard isLink else {
            return nil
        }
        
        var urlString = self
        guard let components = URLComponents(string: self) else {
            return nil
        }
        if components.scheme == nil {
            urlString = "https://\(urlString)"
        }
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return url
    }
}

extension NSAttributedString {
    
    func textSizeForMaxWidth(_ width: CGFloat) -> CGSize {
        let framesetter = CTFramesetterCreateWithAttributedString(self)
        return CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), nil)
    }
}

extension UIImage {
    
    func squareCropped() -> UIImage {
        let originalWidth  = size.width
        let originalHeight = size.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var edge: CGFloat = 0.0
        
        if (originalWidth > originalHeight) {
            // landscape
            edge = originalHeight
            x = (originalWidth - edge) / 2.0
            y = 0.0
            
        } else if (originalHeight > originalWidth) {
            // portrait
            edge = originalWidth
            x = 0.0
            y = (originalHeight - originalWidth) / 2.0
        } else {
            // square
            edge = originalWidth
        }
        
        let cropSquare = CGRect(x: x, y: y, width: edge, height: edge)
        let imageRef = cgImage!.cropping(to: cropSquare)!
    
        return UIImage(cgImage: imageRef, scale: UIScreen.main.scale, orientation: imageOrientation)
    }
    
    class func roundImage(color: UIColor, diameter: CGFloat, shadow: Bool) -> UIImage {
        
        //we will make circle with this diameter
        let edgeLen: CGFloat = diameter
        
        //circle will be created from UIView
        let circle = UIView(frame: CGRect(x: 0, y: 0, width: edgeLen, height: edgeLen))
        circle.backgroundColor = color
        circle.clipsToBounds = true
        circle.isOpaque = false
        
        //in the layer we add corner radius to make it circle and add shadow
        circle.layer.cornerRadius = edgeLen/2
        
        if shadow {
            circle.layer.shadowColor = UIColor.gray.cgColor
            circle.layer.shadowOffset = .zero
            circle.layer.shadowRadius = 2
            circle.layer.shadowOpacity = 0.4
            circle.layer.masksToBounds = false
        }
        
        //we add circle to a view, that is bigger than circle so we have extra 10 points for the shadow
        let view = UIView(frame: CGRect(x: 0, y: 0, width: edgeLen+10, height: edgeLen+10))
        view.backgroundColor = UIColor.clear
        view.addSubview(circle)
        
        circle.center = view.center
        
        //here we are rendering view to image, so we can use it later
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func resizeAsync(to size: CGSize, completion: @escaping (UIImage) -> ()) {
        guard size.width < self.size.width, size.height < self.size.height else {
            return completion(self)
        }
        
        let width = size.width*UIScreen.main.scale
        let height = size.height*UIScreen.main.scale
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let context = CGContext(data: nil, width: Int(width), height: Int(height),
                                    bitsPerComponent: 8, bytesPerRow: Int(width)*4, space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            
            context.draw(self.cgImage!, in: rect)
            
            let resizedImage = UIImage(cgImage: context.makeImage()!)
            
            DispatchQueue.main.async {
                completion(resizedImage)
            }
        }
    }
    
    func resize(to size: CGSize) -> UIImage {
        guard size.width < self.size.width, size.height < self.size.height else {
            return self
        }
        
        let width = size.width*UIScreen.main.scale
        let height = size.height*UIScreen.main.scale
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        let context = CGContext(data: nil, width: Int(width), height: Int(height),
                                bitsPerComponent: 8, bytesPerRow: Int(width)*4, space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        context.draw(self.cgImage!, in: rect)
        
        let resizedImage = UIImage(cgImage: context.makeImage()!)
        
        return resizedImage
    }
    
    func imageData() -> Data? {
        return jpegData(compressionQuality: 1)
    }
    
    func fixedOrientation() -> UIImage {
        // No-op if the orientation is already correct
        if (imageOrientation == UIImage.Orientation.up) {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
        
        if (imageOrientation == UIImage.Orientation.down
            || imageOrientation == UIImage.Orientation.downMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        }
        
        if (imageOrientation == UIImage.Orientation.left
            || imageOrientation == UIImage.Orientation.leftMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi/2)
        }
        
        if (imageOrientation == UIImage.Orientation.right
            || imageOrientation == UIImage.Orientation.rightMirrored) {
            
            transform = transform.translatedBy(x: 0, y: size.height);
            transform = transform.rotated(by: -CGFloat.pi/2);
        }
        
        if (imageOrientation == UIImage.Orientation.upMirrored
            || imageOrientation == UIImage.Orientation.downMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (imageOrientation == UIImage.Orientation.leftMirrored
            || imageOrientation == UIImage.Orientation.rightMirrored) {
            
            transform = transform.translatedBy(x: size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx:CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                      bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: cgImage!.colorSpace!,
                                      bitmapInfo: cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        if (imageOrientation == UIImage.Orientation.left
            || imageOrientation == UIImage.Orientation.leftMirrored
            || imageOrientation == UIImage.Orientation.right
            || imageOrientation == UIImage.Orientation.rightMirrored
            ) {
            
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.height,height:size.width))
            
        } else {
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.width,height:size.height))
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)
        
        return imgEnd
    }
    
    func height(for width: CGFloat) -> CGFloat {
        let scaleFactor = width/size.width
        let height = size.height*scaleFactor
        return height.rounded()
    }
    
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resize(to: newSize)
        return resized
    }
}

extension PHPhotoLibrary {
    
    class func checkStatus(completion: @escaping (Bool) -> ()) {
        if authorizationStatus() == .authorized {
            completion(true)
        } else {
            requestAuthorization { status in
                if status == .authorized {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}

extension Date {
    
    func timeAgoDisplay(shortVersion: Bool = false) -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return shortVersion ? "\(diff) sec" : "\(diff) seconds ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return shortVersion ? "\(diff) min" : "\(diff) minutes ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return shortVersion ? "\(diff) hours" : "\(diff) hours ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return shortVersion ? "\(diff) days" : "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return shortVersion ? "\(diff) weeks" : "\(diff) weeks ago"
    }
}

extension CALayer {
    
    func disableAnimation() {
        actions = ["position": NSNull(), "onOrderIn": NSNull(), "onOrderOut": NSNull(), "sublayers": NSNull(), "contents": NSNull(), "bounds": NSNull()]
    }
}

class WaitVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

struct Policy {
    
    static func checkPassword(_ password: String) -> Bool {
        return !(password.count < 6) /////8!!!!
    }
    
    static func checkEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    static func checkUsername(_ username: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^(?=.{3,18}$)(?![0-9_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$", options: .caseInsensitive)
        return regex.matches(in: username, options: [], range: NSMakeRange(0, username.count)).count > 0
    }
}

extension UIDevice {
    
    var modelName: String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
            
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad7,5", "iPad7,6":                      return "iPad 6"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}


