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
        let selectionRange = selection.start.line...selection.end.line
        let selectedText = selectionRange.map({ invocation.buffer.lines[$0] as! String })

        let lines: [String]
        do {
            lines = try generate(selection: selectedText,
                                 tabWidth: invocation.buffer.tabWidth,
                                 indentationWidth: invocation.buffer.indentationWidth)
        } catch {
            return completionHandler(error)
        }

        let targetRange = selection.end.line + 1..<selection.end.line + 1 + lines.count
        invocation.buffer.lines.insert(lines, at: IndexSet(integersIn: targetRange))
        
        completionHandler(nil)
    }
}
