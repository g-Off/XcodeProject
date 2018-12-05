//
//  PBXGlobalID.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2018-12-02.
//

import Foundation

public struct PBXGlobalID: RawRepresentable {
	public let rawValue: String
	
	public init(rawValue: String) {
		self.rawValue = rawValue
	}
	
	public init?(rawValue: String?) {
		guard let rawValue = rawValue else { return nil }
		self.init(rawValue: rawValue)
	}
	
	public init() {
		self.rawValue = PBXGlobalID.generator.next()
	}
	
	static func ids(from strings: [String]?) -> [PBXGlobalID]? {
		return strings?.compactMap { return PBXGlobalID(rawValue: $0) }
	}
	
	private static var randomNumberGenerator: RandomNumberGenerator = SystemRandomNumberGenerator()
	private static var generator: PBXGlobalID.Generator = PBXGlobalID.Generator(random: &randomNumberGenerator)
}

extension PBXGlobalID: Hashable {
	public var hashValue: Int {
		return rawValue.hashValue
	}
	
	public static func ==(lhs: PBXGlobalID, rhs: PBXGlobalID) -> Bool {
		return lhs.rawValue == rhs.rawValue
	}
}

extension PBXGlobalID: Comparable {
	public static func <(lhs: PBXGlobalID, rhs: PBXGlobalID) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
}

extension PropertyList {
	var globalID: PBXGlobalID? {
		return PBXGlobalID(rawValue: self.string)
	}
}
