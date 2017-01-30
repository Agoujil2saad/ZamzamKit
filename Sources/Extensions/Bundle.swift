//
//  NSBundle.swift
//  ZamzamKit
//
//  Created by Basem Emara on 3/4/16.
//  Copyright © 2016 Zamzam. All rights reserved.
//

import Foundation

public extension Bundle {
    
    /**
     Gets the contents of the specified file.
     
     - parameter fileName: Name of file to retrieve contents from.
     - parameter bundle: Bundle where defaults reside.
     - parameter encoding: Encoding of string from file.
     
     - returns: Contents of file.
     */
    static func stringOfFile(_ fileName: String, inDirectory: String? = nil, bundle: Bundle? = nil, encoding: String.Encoding = String.Encoding.utf8) -> String? {
        guard let resourcePath = (bundle ?? Bundle.main).path(forResource: fileName, ofType: nil, inDirectory: inDirectory) else { return nil }
        return try? String(contentsOfFile: resourcePath, encoding: encoding)
    }
    
    /**
     Gets the contents of the specified plist file.
     
     - parameter plistName: property list where defaults are declared
     - parameter bundle: bundle where defaults reside
     
     - returns: dictionary of values
     */
    static func contentsOfFile(_ plistName: String, inDirectory: String? = nil, bundle: Bundle? = nil) -> [String : Any] {
        guard let resourcePath = (bundle ?? Bundle.main).path(forResource: plistName, ofType: nil, inDirectory: inDirectory),
            let contents = NSDictionary(contentsOfFile: resourcePath) as? [String : Any]
                else { return [:] }
        
        return contents
    }
    
    /**
     Gets the contents of the specified bundle URL.
     
     - parameter bundleURL: bundle URL where defaults reside
     - parameter plistName: property list where defaults are declared
     
     - returns: dictionary of values
     */
    static func contentsOfFile(bundleURL: URL, plistName: String = "Root.plist") -> [String : Any] {
        // Extract plist file from bundle
        guard let contents = NSDictionary(contentsOf: bundleURL.appendingPathComponent(plistName)) else { return [:] }
        
        // Collect default values
        guard let preferences = contents.value(forKey: "PreferenceSpecifiers") as? [String: Any] else { return [:] }
        
        return preferences
    }
    
    /**
     Gets the contents of the specified bundle name.
     
     - parameter bundleName: bundle name where defaults reside
     - parameter plistName: property list where defaults are declared
     
     - returns: dictionary of values
     */
    static func contentsOfFile(bundleName: String, plistName: String = "Root.plist") -> [String : Any] {
        guard let bundleURL = Bundle.main.url(forResource: bundleName, withExtension: "bundle") else { return [:] }
        return contentsOfFile(bundleURL: bundleURL, plistName: plistName)
    }
    
    /**
     Gets the contents of the specified bundle.
     
     - parameter bundle: bundle where defaults reside
     - parameter bundleName: bundle name where defaults reside
     - parameter plistName: property list where defaults are declared
     
     - returns: dictionary of values
     */
    static func contentsOfFile(bundle: Bundle, bundleName: String = "Settings", plistName: String = "Root.plist") -> [String : Any] {
        guard let bundleURL = bundle.url(forResource: bundleName, withExtension: "bundle") else { return [:] }
        return contentsOfFile(bundleURL: bundleURL, plistName: plistName)
    }
    
}
