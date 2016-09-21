//
//  Icomoon.swift
//  Icomoon
//
//  Created by Johannes Schickling on 25/12/2015.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import UIKit

private class FontLoader {
    class func loadFont() {
        let bundle = NSBundle(forClass: FontLoader.self)
        let fontURL = bundle.URLForResource("font", withExtension: "ttf")!
        let data = NSData(contentsOfURL: fontURL)!
        
        if let provider = CGDataProviderCreateWithCFData(data) {
            let font = CGFontCreateWithDataProvider(provider)
            
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                let errorDescription: CFStringRef = CFErrorCopyDescription(error!.takeUnretainedValue())
                let nsError = error!.takeUnretainedValue() as AnyObject as! NSError
                NSException(name: NSInternalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
            }
        }
    }
}

public extension UIFont {
    public static func iconOfSize(fontSize: CGFloat) -> UIFont {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        
        if (UIFont.fontNamesForFamilyName(Font.FontName).count == 0) {
            dispatch_once(&Static.onceToken) {
                FontLoader.loadFont()
            }
        }
        
        return UIFont(name: Font.FontName, size: fontSize)!
    }
}

public extension UIImage {
    public static func iconWithName(name: Icon, textColor: UIColor, fontSize: CGFloat, offset: CGSize = CGSizeZero) -> UIImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        let attributes = [
            NSFontAttributeName: UIFont.iconOfSize(fontSize),
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: paragraph
        ]
        let attributedString = NSAttributedString(string: String.iconWithName(name) as String, attributes: attributes)
        let stringSize = sizeOfAttributeString(attributedString)
        let size = CGSize(width: stringSize.width + offset.width, height: stringSize.height + offset.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        attributedString.drawInRect(CGRect(origin: CGPointZero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

public extension String {
    public static func iconWithName(name: Icon) -> String {
        return name.rawValue.substringToIndex(name.rawValue.startIndex.advancedBy(1))
    }
}

private func sizeOfAttributeString(str: NSAttributedString) -> CGSize {
    return str.boundingRectWithSize(CGSizeMake(10000, 10000), options:(NSStringDrawingOptions.UsesLineFragmentOrigin), context:nil).size
}
