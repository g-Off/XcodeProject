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
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String
}

extension PListArchivable {
	var archiveInPlistOnSingleLine: Bool {
		return false
	}
}

extension ObjectMap: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		func plist(objects: [PBXObject], format: Format) -> String {
			var str = ""
			objects.sorted { (obj1, obj2) -> Bool in
				obj1.globalID < obj2.globalID
			}.forEach {
				str += $0.plistRepresentation(format: format, objectVersion: objectVersion)
			}
			return str
		}
		var str = "{\n"
		objectMap.sorted { (obj1, obj2) -> Bool in
			return obj1.key < obj2.key
		}.forEach { (key, value) in
			str += "\n/* Begin \(key) section */\n"
			format.indented {
				str += plist(objects: value, format: $0)
			}
			str += "/* End \(key) section */\n"
		}
		str += "\(format.indentation)}"
		return str
	}
}

extension NSString: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		return (self as String).plistRepresentation(format: format, objectVersion: objectVersion)
	}
}

extension NSNumber: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		return "\(self.description)"
	}
}

extension NSDictionary: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		return (self as! [String: Any]).plistRepresentation(format: format, objectVersion: objectVersion)
	}
}

extension NSArray: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		return (self as! [Any]).plistRepresentation(format: format, objectVersion: objectVersion)
	}
}

extension String: PListArchivable {
	
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		return self
	}
}

extension UInt: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		return "\(self)"
	}
}

extension Int: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		return "\(self)"
	}
}

extension Int8: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		return "\(self)"
	}
}

extension Int32: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		return "\(self)"
	}
}

extension Bool: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		return self ? "1" : "0"
	}
}

extension PBXObject: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		let objectEncoder = PBXObjectEncoder()
		objectEncoder.objectVersion = objectVersion
		guard let encoded = try? objectEncoder.encode(self).sorted(by: { (obj1, obj2) -> Bool in
			return (obj1.key == "isa") || (obj1.key < obj2.key && obj2.key != "isa")
		}) else {
			return ""
		}
		
		var str = "\(format.indentation)\(self.plistID) = {"
		(archiveInPlistOnSingleLine ? Format.singleLine : format).indented { (format) in
			str += "\(format.startOfLine)"
			encoded.forEach { (key, value) in
				guard let value = value as? PListArchivable else { return }
				str += "\(format.indentation)\(key) = \(value.plistRepresentation(format: format, objectVersion: objectVersion));\(format.endOfLine)"
			}
		}
		if !archiveInPlistOnSingleLine {
			str += "\(format.indentation)"
		}
		str += "};\(format.endOfLine)"
		return str
	}
}

extension Dictionary: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		var str = "{\(format.startOfLine)"
		var plist: [String: String] = [:]
		for (key, value) in self {
			guard let archivableKey = key as? PListArchivable else {
				fatalError("Key `\(key)` of type \(type(of: key)) is not PListArchivable")
			}
			guard let archivableValue = value as? PListArchivable else {
				fatalError("Value `\(value)` of type \(type(of: key)) is not PListArchivable")
			}
			format.indented { (format) in
				let keyString = archivableKey.plistRepresentation(format: format, objectVersion: objectVersion)
				let valueString = archivableValue.plistRepresentation(format: format, objectVersion: objectVersion)
				plist[keyString] = valueString
			}
		}
		
		plist.sorted {
			return $0.key.unquotedString < $1.key.unquotedString
		}.forEach { (keyString, valueString) in
			format.indented { (format) in
				str += "\(format.indentation)\(keyString) = \(valueString);\(format.endOfLine)"
			}
		}
		
		str += "\(format.indentation)}"
		return str
	}
}

extension Array: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		var str = "(\(format.startOfLine)"
		format.indented { (format) in
			for item in self {
				guard let item = item as? PListArchivable else { fatalError() }
				str += "\(format.indentation)\(item.plistRepresentation(format: format, objectVersion: objectVersion)),\(format.endOfLine)"
			}
		}
		str += "\(format.indentation))"
		return str
	}
}

extension PlistID: PListArchivable {
	func plistRepresentation(format: Format, objectVersion: ObjectVersion) -> String {
		return description
	}
}
