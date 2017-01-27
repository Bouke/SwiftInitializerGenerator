//
//  SIG.swift
//  SwiftInitializerGenerator
//
//  Created by Bouke Haarsma on 21-12-16.
//  Copyright © 2016 Bouke Haarsma. All rights reserved.
//

import Foundation

enum SIGError: Swift.Error {
    case notSwiftLanguage
    case noSelection
    case invalidSelection
    case parseError
}

let accessModifiers = ["open", "public", "internal", "private", "fileprivate"]

func generate(selection: [String], tabWidth: Int, indentationWidth: Int) throws -> [String] {
    var variables = [(String, String)]()

    for line in selection {
        let scanner = Scanner(string: line)

        var weak = scanner.scanString("weak", into: nil)
        for modifier in accessModifiers {
            if scanner.scanString(modifier, into: nil) {
                break
            }
        }
        for modifier in accessModifiers {
            if scanner.scanString(modifier, into: nil) {
                guard let _ = scanner.scanUpTo(")"), let _ = scanner.scanString(")") else {
                    throw SIGError.parseError
                }
            }
        }
        weak = weak || scanner.scanString("weak", into: nil)

        guard scanner.scanString("let", into: nil) || scanner.scanString("var", into: nil) || scanner.scanString("dynamic var", into: nil) else {
            continue
        }
        guard let variableName = scanner.scanUpTo(":"),
            scanner.scanString(":", into: nil),
            let variableType = scanner.scanUpTo("\n") else {
                throw SIGError.parseError
        }
        variables.append((variableName, variableType))
    }

    let arguments = variables.map { "\($0.0): \($0.1)" }.joined(separator: ", ")

    let indentExpressions = String(repeating: " ", count: tabWidth)
    let expressions = variables.map { "\(indentExpressions)self.\($0.0) = \($0.0)" }

    let indentLines = String(repeating: " ", count: indentationWidth)
    let lines = (["public init(\(arguments)) {"] + expressions + ["}"]).map { "\(indentLines)\($0)" }

    return lines
}
