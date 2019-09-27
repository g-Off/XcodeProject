//
//  XCSwiftPackageProductDependency.swift
//  
//
//  Created by Geoffrey Foster on 2019-07-03.
//

import Foundation

public final class XCSwiftPackageProductDependency: PBXProductDependency {
	private enum CodingKeys: String, CodingKey {
		case packageReference = "package"
		case productName
	}
	
	var packageReference: XCSwiftPackageReference?
	var productName: String?
	
	override var archiveComment: String {
		return productName ?? super.archiveComment
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		self.productName = plist[CodingKeys.productName]?.string
		self.packageReference = objectCache.object(for: PBXGlobalID(rawValue: plist[CodingKeys.packageReference]?.string))
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(packageReference, forKey: .packageReference)
		try container.encodeIfPresent(productName, forKey: .productName)
	}
}
