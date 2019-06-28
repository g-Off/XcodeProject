//
//  String+Extensions.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2019-06-23.
//

import Foundation

extension String {
	static let replacements: [(String, String)] = [
		("\\", "\\\\"),
		("\"", "\\\""),
		("\n", "\\n"),
		("\t", "\\t"),
	]
	
	var quotedString: String {
		var string = self
		
		let characterSet = CharacterSet(charactersIn: "+-<>@$()=,:~").union(CharacterSet.whitespacesAndNewlines)
		
		var requiresQuotes = string.isEmpty
		if !requiresQuotes {
			for character in string.unicodeScalars where characterSet.contains(character) {
				requiresQuotes = true
				break
			}
		}
		
		String.replacements.forEach {
			string = string.replacingOccurrences(of: $0.0, with: $0.1)
		}
		
		if requiresQuotes {
			string = "\"\(string)\""
		}
		
		return string
	}
	
	var unquotedString: String {
		var string = self
		if let firstRange = string.range(of: ("\""), options: []), firstRange.lowerBound == startIndex,
			let lastRange = string.range(of: ("\""), options: [.backwards]), lastRange.upperBound == endIndex {
			string.removeSubrange(lastRange)
			string.removeSubrange(firstRange)
		}
		
		String.replacements.reversed().forEach {
			string = string.replacingOccurrences(of: $0.1, with: $0.0)
		}
		
		return string
	}
}
