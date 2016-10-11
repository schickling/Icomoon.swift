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
        let bundle = Bundle(for: FontLoader.self)
        let fontURL = bundle.url(forResource: "font", withExtension: "ttf")!
        let data = try! Data(contentsOf: fontURL)
        
        if let provider = CGDataProvider(data: data as CFData) {
            let font = CGFont(provider)
            
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
                let nsError = error!.takeUnretainedValue() as AnyObject as! NSError
                NSException(name: NSExceptionName.internalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
            }
        }
    }
}

public extension UIFont {
    public static func iconOfSize(_ fontSize: CGFloat) -> UIFont {
        struct Static {
            static var onceToken : Int = {
                if UIFont.fontNames(forFamilyName: Font.FontName).count == 0 {
                    FontLoader.loadFont()
                }
                return 0
            }()
        }
        
        return UIFont(name: Font.FontName, size: fontSize)!
    }
}

public extension UIImage {
    public static func iconWithName(_ name: Icon, textColor: UIColor, fontSize: CGFloat, offset: CGSize = CGSize.zero) -> UIImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [
            NSFontAttributeName: UIFont.iconOfSize(fontSize),
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: paragraph
        ]
        let attributedString = NSAttributedString(string: String.iconWithName(name) as String, attributes: attributes)
        let stringSize = sizeOfAttributeString(attributedString)
        let size = CGSize(width: stringSize.width + offset.width, height: stringSize.height + offset.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        attributedString.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

public extension String {
    public static func iconWithName(_ name: Icon) -> String {
        return name.rawValue.substring(to: name.rawValue.characters.index(name.rawValue.startIndex, offsetBy: 1))
    }
}

private func sizeOfAttributeString(_ str: NSAttributedString) -> CGSize {
    return str.boundingRect(with: CGSize(width: 10000, height: 10000), options:(NSStringDrawingOptions.usesLineFragmentOrigin), context:nil).size
}
