//
//  PBXNativeTarget.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class PBXNativeTarget: PBXTarget {
	private enum CodingKeys: String, CodingKey {
		case productType
	}

	public enum ProductType: String, Encodable {
		case application = "com.apple.product-type.application"
		case framework = "com.apple.product-type.framework"
		case dynamicLibrary = "com.apple.product-type.library.dynamic"
		case staticLibrary = "com.apple.product-type.library.static"
		case bundle = "com.apple.product-type.bundle"
		//case octest_bundle = "com.apple.product-type.bundle"
		case unitTestBundle = "com.apple.product-type.bundle.unit-test"
		case uiTestBundle = "com.apple.product-type.bundle.ui-testing"
		case appExtension = "com.apple.product-type.app-extension"
		case commandLineTool = "com.apple.product-type.tool"
		case watchApp = "com.apple.product-type.application.watchapp"
		case watch2App = "com.apple.product-type.application.watchapp2"
		case watchExtension = "com.apple.product-type.watchkit-extension"
		case watch2Extension = "com.apple.product-type.watchkit2-extension"
		case tvExtension = "com.apple.product-type.tv-app-extension"
		case messagesApplication = "com.apple.product-type.application.messages"
		case messagesExtension = "com.apple.product-type.app-extension.messages"
		case stickerPack = "com.apple.product-type.app-extension.messages-sticker-pack"
		case xpcService = "com.apple.product-type.xpc-service"
	}
	
	var productType: ProductType = .application
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		guard
			let productType = ProductType(rawValue: plist[CodingKeys.productType]?.string ?? "")
			else {
				fatalError()
		}
		self.productType = productType
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(productType, forKey: .productType)
	}
	
	public override func addBuildPhase<T: PBXBuildPhase>() -> T? {
		var phase: T?
		if T.self == PBXCopyFilesBuildPhase.self || T.self == PBXShellScriptBuildPhase.self {
			phase = T(globalID: PBXGlobalID())
		}
		
		let acceptablePhases: [PBXBuildPhase.Type] = [
			PBXFrameworksBuildPhase.self,
			PBXHeadersBuildPhase.self,
			PBXResourcesBuildPhase.self,
			PBXSourcesBuildPhase.self,
		]
		if acceptablePhases.contains(where: { return T.self == $0 }) &&
			!buildPhases.contains(where: { type(of: $0) == T.self }) {
			phase = T(globalID: PBXGlobalID())
		}
		
		if let phase = phase {
			buildPhases.append(phase)
		}
		
		return phase
	}
}
