//
//  XCLocalSwiftPackageReference.swift
//  
//
//  Created by Geoffrey Foster on 2019-07-03.
//

import Foundation

final class XCLocalSwiftPackageReference: XCSwiftPackageReference {
	var packageName: String?
	
	override var archiveComment: String {
		guard let packageName = packageName else { return super.archiveComment }
		return #"\#(super.archiveComment) "\#(packageName)""#
	}
}
