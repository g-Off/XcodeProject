//
//  XCBuildConfiguration.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

final class XCBuildConfiguration: PBXObject {
	var name: String?
	var buildSettings = BuildSettings([:])
	var baseConfigurationReference: PBXFileReference?
	
	public convenience init(name: String, buildSettings: BuildSettings) {
		self.init(globalID: GlobalID())
		
		self.name = name
		self.buildSettings = buildSettings
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		guard
			let name = plist["name"]?.string,
			let buildSettings = plist["buildSettings"]?.dictionary
			else {
				fatalError()
		}
		
		self.name = name
		self.buildSettings = BuildSettings(buildSettings)
		self.baseConfigurationReference = objectCache.object(for: plist["baseConfigurationReference"]?.globalID)
	}
	
	override var archiveComment: String {
		return name ?? super.archiveComment
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		visitor.visit(object: baseConfigurationReference)
	}
	
	override var plistRepresentation: [String : Any?] {
		var plist = super.plistRepresentation
		plist["name"] = name
		plist["buildSettings"] = buildSettings
		plist["baseConfigurationReference"] = baseConfigurationReference?.plistID
		return plist
	}
}

struct BuildSettings: PListArchivable {
	
//	CODE_SIGN_IDENTITY = "iPhone Developer";
//	"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
	
	// sdk=
	// *
	// iphoneos*
	// iphonesimulator*
	// macosx*
	// appletvos*
	// appletvsimulator*
	// watchos*
	// watchsimulator*
	
	enum SDK: CustomStringConvertible {
		case any
		case iphoneos(version: OperatingSystemVersion?)
		case iphonesimulator(version: OperatingSystemVersion?)
		case macosx(version: OperatingSystemVersion?)
		case appletvos(version: OperatingSystemVersion?)
		case appletvsimulator(version: OperatingSystemVersion?)
		case watchos(version: OperatingSystemVersion?)
		case watchsimulator(version: OperatingSystemVersion?)
		
		var description: String {
			func sdkString() -> String {
				func versionString(from osVersion: OperatingSystemVersion?) -> String {
					guard let osVersion = osVersion else {
						return ""
					}
					return "\(osVersion.majorVersion).\(osVersion.minorVersion)"
				}
				switch self {
				case .any:
					return "*"
				case .iphoneos(let version):
					return "iphoneos\(versionString(from: version))"
				case .iphonesimulator(let version):
					return "iphonesimulator\(versionString(from: version))"
				case .macosx(let version):
					return "macosx\(versionString(from: version))"
				case .appletvos(let version):
					return "appletvos\(versionString(from: version))"
				case .appletvsimulator(let version):
					return "appletvsimulator\(versionString(from: version))"
				case .watchos(let version):
					return "watchos\(versionString(from: version))"
				case .watchsimulator(let version):
					return "watchsimulator\(versionString(from: version))"
				}
			}
			return "[sdk=\(sdkString())]"
		}
	}
	
	// where * in the sdk = 10.2, 10.12, 3.1, etc
	struct Value: PListArchivable {
		let value: Any
		init?(_ value: Any) {
			if value is String || value is [String] {
				self.value = value
			} else {
				return nil
			}
		}
		
		var string: String? {
			return value as? String
		}
		
		var array: [String]? {
			return value as? [String]
		}
		
		func plistRepresentation(format: Format) -> String {
			guard let value = value as? PListArchivable else {
				fatalError()
			}
			return value.plistRepresentation(format: format)
		}
	}
	
	var settings: [String: Value] = [:]
	
	init(_ settings: [String: Any]) {
		settings.forEach { (key, value) in
			if let value = Value(value) {
				self.settings[key] = value
			}
		}
	}
	
	subscript(setting: String, sdk: SDK?) -> Value? {
		var sdkString = ""
		if let sdk = sdk {
			sdkString = sdk.description
		}
		return settings[sdkString]
	}
	
	func plistRepresentation(format: Format) -> String {
		return settings.plistRepresentation(format: format)
	}
}
