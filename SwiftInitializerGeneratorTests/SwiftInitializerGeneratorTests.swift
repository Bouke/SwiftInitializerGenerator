//
//  SwiftInitializerGeneratorTests.swift
//  SwiftInitializerGeneratorTests
//
//  Created by Bouke Haarsma on 21-12-16.
//  Copyright © 2016 Bouke Haarsma. All rights reserved.
//

import XCTest

class SwiftInitializerGeneratorTests: XCTestCase {
    func assert(input: [String], output: [String], file: StaticString = #file, line: UInt = #line) {
        do {
            let lines = try generate(selection: input, tabWidth: 4, indentationWidth: 0)
            if(lines != output) {
                XCTFail("Output is not correct; expected:\n\(output.joined(separator: "\n"))\n\ngot:\n\(lines.joined(separator: "\n"))", file: file, line: line)
            }
        } catch {
            XCTFail("Could not generate initializer: \(error)", file: file, line: line)
        }
    }

    func testNoAccessModifiers() {
        assert(
            input: [
                "let a: Int",
                "let b: Int"
            ],
            output: [
                "public init(a: Int, b: Int) {",
                "    self.a = a",
                "    self.b = b",
                "}"
            ])
    }

    func testNoProperties() {
        assert(
            input: [
                "",
                ""
            ],
            output: [
                "public init() {",
                "}"
            ])
    }

    func testEmptyLineInBetween() {
        assert(
            input: [
                "let a: Int",
                "",
                "let b: Int"
            ],
            output: [
                "public init(a: Int, b: Int) {",
                "    self.a = a",
                "    self.b = b",
                "}"
            ])
    }

    func testSingleAccessModifier() {
        assert(
            input: [
                "internal let a: Int",
                "private let b: Int"
            ],
            output: [
                "public init(a: Int, b: Int) {",
                "    self.a = a",
                "    self.b = b",
                "}"
            ])
    }

    func testDoubleAccessModifier() {
        assert(
            input: [
                "public internal(set) let a: Int",
                "public private(set) let b: Int"
            ],
            output: [
                "public init(a: Int, b: Int) {",
                "    self.a = a",
                "    self.b = b",
                "}"
            ])
    }


    func testCommentLine() {
        assert(
            input: [
                "/// a very important property",
                "let a: Int",
                "// this one, not so much",
                "let b: Int",
                "/*",
                " * pay attention to this one",
                " */",
                "let c: IBOutlet!"
            ],
            output: [
                "public init(a: Int, b: Int, c: IBOutlet!) {",
                "    self.a = a",
                "    self.b = b",
                "    self.c = c",
                "}"
            ])
    }
  
    func testDynamicVar() {
        assert(
            input: ["dynamic var hello: String",
                    "dynamic var a: Int?",
                    "var b: Float"],
            output: [
                "public init(hello: String, a: Int?, b: Float) {",
                "    self.hello = hello",
                "    self.a = a",
                "    self.b = b",
                "}"
            ])
    }
}
