//
//  NSCodingTransformer.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 08.09.24.
//

import Foundation
import UIKit

@objc(PreferencesTransformer)
public final class PreferencesTransformer: ValueTransformer {

    override public func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? Preferences else { return nil }
        do {
            let data = try JSONEncoder().encode(value)
            return data
        } catch {
            print("Failed to encode Preferences: \(error)")
            return nil
        }
    }

    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let object = try JSONDecoder().decode(Preferences.self, from: data)
            return object
        } catch {
            print("Failed to decode Preferences: \(error)")
            return nil
        }
    }

    override public class func allowsReverseTransformation() -> Bool {
        return true
    }

    override public class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
}
