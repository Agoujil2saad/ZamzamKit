//
//  FileServiceTests.swift
//  ZamzamKit
//
//  Created by Basem Emara on 1/20/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
@testable import ZamzamKit

class FileServiceTests: XCTestCase {
    
    let fileName = "FileServiceTests.txt"
    let fileName2 = "FileServiceTests2.txt"
    var manager: ZamzamManager!
    
    override func setUp() {
        super.setUp()
        
        manager = ZamzamManager()
        
        // Create blank files for testing
        do {
            try "Some text".writeToFile(fileInDocumentsDirectory(fileName), atomically: true, encoding: NSUTF8StringEncoding)
            try "Some text 2".writeToFile(fileInDocumentsDirectory(fileName2), atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            print("Could not create files!")
        }
    }
    
    override func tearDown() {
        super.tearDown()
        
        // Delete blank files after testing
        do {
            try NSFileManager.defaultManager().removeItemAtPath(fileInDocumentsDirectory(fileName))
            try NSFileManager.defaultManager().removeItemAtPath(fileInDocumentsDirectory(fileName2))
        } catch {
            print("Could not delete files!")
        }
    }
    
    func testGetDocumentPath() {
        let value = manager.fileService.getDocumentPath(fileName)
        
        XCTAssert(NSFileManager.defaultManager().fileExistsAtPath(value),
            "The file location path for \(fileName) seems incorrect (file doesn't exist)")
    }
    
    func testGetDocumentPaths() {
        let value = manager.fileService.getDocumentPaths()
        let expectedValue = [
            fileInDocumentsDirectory(fileName),
            fileInDocumentsDirectory(fileName2)
        ]
        
        XCTAssertEqual(value, expectedValue,
            "The file paths for the document directory seems incorrect")
    }
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(
            .DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
    }
}