//
//  XCProjectReferenceInfo.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2019-06-23.
//

import Foundation

final class XCProjectReferenceInfo: Hashable, Encodable { // PBXProjectItem
	static func == (lhs: XCProjectReferenceInfo, rhs: XCProjectReferenceInfo) -> Bool {
		return lhs.productGroup == rhs.productGroup && lhs.projectReference == rhs.projectReference
	}
	
	private enum CodingKeys: String, CodingKey {
		case productGroup = "ProductGroup"
		case projectReference = "ProjectRef"
	}
	
	var productGroup: PBXGroup
	var projectReference: PBXFileReference
	
	init(with plist: PropertyList, objectCache: ObjectCache) {
		guard let productGroupID = PBXGlobalID(rawValue: plist[CodingKeys.productGroup.rawValue]?.string),
			let productGroup = objectCache.object(for: productGroupID) as? PBXGroup else {
				fatalError()
		}
		guard let projectReferenceId = PBXGlobalID(rawValue: plist[CodingKeys.projectReference.rawValue]?.string),
			let projectReference = objectCache.object(for: projectReferenceId) as? PBXFileReference else {
				fatalError()
		}
		
		self.productGroup = productGroup
		self.projectReference = projectReference
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(productGroup)
		hasher.combine(projectReference)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(productGroup, forKey: .productGroup)
		try container.encode(projectReference, forKey: .projectReference)
	}
}
