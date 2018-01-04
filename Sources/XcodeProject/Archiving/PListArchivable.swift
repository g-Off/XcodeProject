//
//  PListArchivable.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-06.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

protocol PListArchivable {
	var archiveInPlistOnSingleLine: Bool { get }
	func plistRepresentation(format: Format) -> String
}

extension PListArchivable {
	var archiveInPlistOnSingleLine: Bool {
		return false
	}
}

extension ObjectMap: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		func plist(objects: [PBXObject], format: Format) -> String {
			var str = ""
			objects.sorted { (obj1, obj2) -> Bool in
				obj1.globalID.rawValue < obj2.globalID.rawValue
			}.forEach {
				str += $0.plistRepresentation(format: format)
			}
			return str
		}
		var str = "{\n"
		objectMap.sorted { (obj1, obj2) -> Bool in
			return obj1.key.description < obj2.key.description
		}.forEach { (key, value) in
			str += "\n/* Begin \(key) section */\n"
			var format = format
			format.indentation.increase()
			str += plist(objects: value, format: format)
			format.indentation.decrease()
			str += "/* End \(key) section */\n"
		}
		str += "\(format.indentation)}"
		return str
	}
}

extension NSString: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		return (self as String).plistRepresentation(format: format)
	}
}

extension NSDictionary: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		return (self as! [AnyHashable: Any]).plistRepresentation(format: format)
	}
}

extension NSArray: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		return (self as! [Any]).plistRepresentation(format: format)
	}
}

extension String: PListArchivable {
	static let replacements: [(String, String)] = [
		("\\", "\\\\"),
		("\"", "\\\""),
		("\n", "\\n"),
		("\t", "\\t"),
		]
	
	var quotedString: String {
		var string = self
		
		let characterSet = CharacterSet(charactersIn: "+-<>@$()=,:").union(CharacterSet.whitespacesAndNewlines)
		
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
	
	fileprivate var unquotedString: String {
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
	
	func plistRepresentation(format: Format) -> String {
		return self.quotedString
	}
}

extension UInt: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		return "\(self)"
	}
}

extension Int: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		return "\(self)"
	}
}

extension Int8: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		return "\(self)"
	}
}

extension Int32: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		return "\(self)"
	}
}

extension Bool: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		return self ? "1" : "0"
	}
}

extension PBXObject: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		let singleLine = archiveInPlistOnSingleLine
		var subformat = format
		if singleLine {
			subformat.startOfLine = ""
			subformat.endOfLine = " "
			subformat.indentation.character = ""
			subformat.indentation.level = 0
			subformat.indentation.enabled = false
		}
		var str = "\(format.indentation)\(self.plistID) = {\(subformat.startOfLine)"
		
		subformat.indentation.increase()
		
		plistRepresentation.sorted { (obj1, obj2) -> Bool in
			return (obj1.key == "isa") || (obj1.key < obj2.key && obj2.key != "isa")
		}.forEach { (key, value) in
			if value == nil { return }
			guard let value = value as? PListArchivable else {
				return
			}
			
			str += "\(subformat.indentation)\(key) = \(value.plistRepresentation(format: subformat));\(subformat.endOfLine)"
		}
		
		subformat.indentation.decrease()
		str += "\(subformat.indentation)};\n"
		return str
	}
}

extension Dictionary: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		var format = format
		var str = "{\(format.startOfLine)"
		
		var plist: [String: String] = [:]
		
		for (key, value) in self {
			guard let key = key as? PListArchivable else {
				fatalError()
			}
			guard let thevalue = value as? PListArchivable else {
				fatalError()
			}
			format.indentation.increase()
			let keyString = key.plistRepresentation(format: format)
			let valueString = thevalue.plistRepresentation(format: format)
			
			plist[keyString] = valueString
			
			format.indentation.decrease()
		}
		
		plist.sorted {
			return $0.key.unquotedString < $1.key.unquotedString
		}.forEach { (keyString, valueString) in
			format.indentation.increase()
			str += "\(format.indentation)\(keyString) = \(valueString);\(format.endOfLine)"
			format.indentation.decrease()
		}
		
		str += "\(format.indentation)}"
		return str
	}
}

extension Array: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		var format = format
		var str = "(\(format.startOfLine)"
		format.indentation.increase()
		for item in self {
			guard let item = item as? PListArchivable else { fatalError() }
			str += "\(format.indentation)\(item.plistRepresentation(format: format)),\(format.endOfLine)"
		}
		format.indentation.decrease()
		str += "\(format.indentation))"
		return str
	}
}

extension PlistID: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		return rawValue
	}
}

extension PlistISA: PListArchivable {
	func plistRepresentation(format: Format) -> String {
		return rawValue
	}
}
