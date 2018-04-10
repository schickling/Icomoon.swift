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
        guard
            let data = try? Data(contentsOf: fontURL),
            let provider = CGDataProvider(data: data as CFData),
            let font = CGFont(provider)
            else { return }

        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
            let nsError = error!.takeUnretainedValue() as AnyObject as! NSError
            NSException(name: NSExceptionName.internalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
        }

    }
}

public extension UIFont {
    private static var _loaded = false
    
    public static func iconOfSize(_ fontSize: CGFloat) -> UIFont {
        if !_loaded {
            if UIFont.fontNames(forFamilyName: Font.FontName).count == 0 {
                FontLoader.loadFont()
            }
            _loaded = true
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
            NSAttributedStringKey.font: UIFont.iconOfSize(fontSize),
            NSAttributedStringKey.foregroundColor: textColor,
            NSAttributedStringKey.paragraphStyle: paragraph
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
    public static func icomoonIcon(name: Icon, textColor: UIColor, size: CGSize, backgroundColor: UIColor = UIColor.clear) -> UIImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center
        
        // Taken from FontAwesome.io's Fixed Width Icon CSS
        let fontAspectRatio: CGFloat = 1.28571429
        
        let fontSize = min(size.width / fontAspectRatio, size.height)
        let attributedString = NSAttributedString(
            string: String.iconWithName(name) as String,
            attributes: [
                NSAttributedStringKey.font: UIFont.iconOfSize(fontSize),
                NSAttributedStringKey.foregroundColor: textColor,
                NSAttributedStringKey.backgroundColor: backgroundColor,
                NSAttributedStringKey.paragraphStyle: paragraph
            ]
        )
        UIGraphicsBeginImageContextWithOptions(size, false , 0.0)
        attributedString.draw(in: CGRect(x: 0, y: (size.height - fontSize) / 2, width: size.width, height: fontSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

public extension String {
    public static func iconWithName(_ name: Icon) -> String {
        return String(name.rawValue[..<name.rawValue.index(name.rawValue.startIndex, offsetBy: 1)])
    }
}

private func sizeOfAttributeString(_ str: NSAttributedString) -> CGSize {
    return str.boundingRect(with: CGSize(width: 10000, height: 10000), options:(NSStringDrawingOptions.usesLineFragmentOrigin), context:nil).size
}
