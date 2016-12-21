//
//  SwiftInitializerGeneratorTests.swift
//  SwiftInitializerGeneratorTests
//
//  Created by Bouke Haarsma on 21-12-16.
//  Copyright © 2016 Bouke Haarsma. All rights reserved.
//

import XCTest

class SwiftInitializerGeneratorTests: XCTestCase {
    func _test(input: [String], output: [String], file: StaticString = #file, line: UInt = #line) {
        do {
            let lines = try generate(selection: input, tabWidth: 4, indentationWidth: 4)
            if(lines != output) {
                XCTFail("Output is not correct expected \(output), got \(lines)", file: file, line: line)
            }
        } catch {
            XCTFail("Could not generate initializer", file: file, line: line)
        }
    }

    func testNoAccessModifiers() throws {
        _test(input: ["let a: Int", "let b: Int"], output: [])
    }
}
