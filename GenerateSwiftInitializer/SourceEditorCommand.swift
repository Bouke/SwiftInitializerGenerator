//
//  SourceEditorCommand.swift
//  GenerateSwiftInitializer
//
//  Created by Bouke Haarsma on 11-09-16.
//  Copyright © 2016 Bouke Haarsma. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    enum Error: Swift.Error {
        case notSwiftLanguage
        case noSelection
        case invalidSelection
        case parseError
    }

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Swift.Error?) -> Void ) -> Void {
        guard invocation.buffer.contentUTI == "public.swift-source" else {
            return completionHandler(Error.notSwiftLanguage)
        }
        guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            return completionHandler(Error.noSelection)
        }
        let selectionRange = selection.start.line...selection.end.line

        var variables = [(String, String)]()
        for line in selectionRange.map({ invocation.buffer.lines[$0] as! String }) {
            let scanner = Scanner(string: line)
            _ = scanner.scanString("public", into: nil) || scanner.scanString("internal", into: nil)
            guard scanner.scanString("let", into: nil) || scanner.scanString("var", into: nil) else {
                return completionHandler(Error.parseError)
            }
            guard let variableName = scanner.scanUpTo(":"),
                scanner.scanString(":", into: nil),
                let variableType = scanner.scanUpTo("\n") else {
                    return completionHandler(Error.parseError)
            }
            variables.append((variableName, variableType))
        }

        let arguments = variables.map { "\($0.0): \($0.1)" }.joined(separator: ", ")

        let indentExpressions = String(repeating: " ", count: invocation.buffer.tabWidth)
        let expressions = variables.map { "\(indentExpressions)self.\($0.0) = \($0.0)" }

        let indentLines = String(repeating: " ", count: invocation.buffer.indentationWidth)
        let lines = (["public init(\(arguments)) {"] + expressions + ["}"]).map { "\(indentLines)\($0)" }

        let targetRange = selection.end.line + 1..<selection.end.line + 1 + lines.count
        invocation.buffer.lines.insert(lines, at: IndexSet(integersIn: targetRange))

        completionHandler(nil)
    }
}
