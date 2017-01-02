//
//  SourceEditorCommand.swift
//  SourceEditorExtension
//
//  Created by Bouke Haarsma on 11-09-16.
//  Copyright © 2016 Bouke Haarsma. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Swift.Error?) -> Void ) -> Void {
        guard invocation.buffer.contentUTI == "public.swift-source" else {
            return completionHandler(SIGError.notSwiftLanguage)
        }
        guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            return completionHandler(SIGError.noSelection)
        }

        print(selection.start.line, selection.start.column)
        print(selection.end.line, selection.end.column)

        let selectedText: [String]
        if selection.start.line == selection.end.line {
            selectedText = [String(
                (invocation.buffer.lines[selection.start.line] as! String).utf8
                    .prefix(selection.end.column)
                    .dropFirst(selection.start.column)
                )!]
        } else {
            selectedText = [String((invocation.buffer.lines[selection.start.line] as! String).utf8.dropFirst(selection.start.column))!]
                + ((selection.start.line+1)..<selection.end.line).map { invocation.buffer.lines[$0] as! String }
                + [String((invocation.buffer.lines[selection.end.line] as! String).utf8.prefix(selection.end.column))!]
        }

        let initializer: [String]
        do {
            initializer = try generate(selection: selectedText,
                                       tabWidth: invocation.buffer.tabWidth,
                                       indentationWidth: invocation.buffer.indentationWidth)
        } catch {
            return completionHandler(error)
        }

        let targetRange = selection.end.line + 1..<selection.end.line + 1 + initializer.count
        invocation.buffer.lines.insert(initializer, at: IndexSet(integersIn: targetRange))
        
        completionHandler(nil)
    }
}
