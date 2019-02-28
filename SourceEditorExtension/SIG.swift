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

func generate(selection: [String], indentation: String, leadingIndent: String) throws -> [String] {
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
        
        // In case multiple variables defined in a line.
        let variableNames = variableName.components(separatedBy: ",")
        for vname in variableNames {
            variables.append((vname.trimmingCharacters(in: .whitespaces), variableType))
        }
    }

    let arguments = variables.map { "\($0.0): \(addEscapingAttributeIfNeeded(to: $0.1))" }.joined(separator: ", ")

    let expressions = variables.map { "\(indentation)self.\($0.0) = \($0.0)" }

    let lines = (["public init(\(arguments)) {"] + expressions + ["}"]).map { "\(leadingIndent)\($0)" }

    return lines
}

private func addEscapingAttributeIfNeeded(to typeString: String) -> String {
    let predicate = NSPredicate(format: "SELF MATCHES %@", "\\(.*\\)->.*")
    if predicate.evaluate(with: typeString.replacingOccurrences(of: " ", with: "")),
        !isOptional(typeString: typeString) {
        return "@escaping " + typeString
    } else {
        return typeString
    }
}

private func isOptional(typeString: String) -> Bool {
    guard typeString.hasSuffix("!") || typeString.hasSuffix("?") else {
        return false
    }
    var balance = 0
    var indexOfClosingBraceMatchingFirstOpenBrace: Int?

    for (index, character) in typeString.enumerated() {
        if character == "(" {
            balance += 1
        } else if character == ")" {
            balance -= 1
        }
        if balance == 0 {
            indexOfClosingBraceMatchingFirstOpenBrace = index
            break
        }
    }

    return indexOfClosingBraceMatchingFirstOpenBrace == typeString.characters.count - 2
}
