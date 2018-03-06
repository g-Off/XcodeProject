//
//  Workspace.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2018-01-02.
//  Copyright © 2018 Geoffrey Foster. All rights reserved.
//

import Foundation

public protocol WorkspaceReference: class {
	weak var parent: WorkspaceReference? { get }
	var referenceURL: URL? { get }
}

public protocol WorkspaceItem: WorkspaceReference {
	var location: String { get }
}

public extension WorkspaceReference {
	weak var parent: WorkspaceReference? { return nil }
}

extension WorkspaceItem {
	public var referenceURL: URL? {
		print(location)
		var scheme: String = ""
		var path: String = location
		if let index = location.index(of: ":") {
			scheme = String(location[..<index])
			path = String(location[location.index(after: index)...])
		}
		switch scheme {
		case "absolute":
			return URL(fileURLWithPath: path)
		case "container":
			return URL(fileURLWithPath: path, relativeTo: rootItem?.referenceURL)
		case "developer":
			return nil
		case "group":
			return URL(fileURLWithPath: path, relativeTo: parent?.referenceURL)
		case "self":
			return nil
		default:
			return nil
		}
	}
	
	private var rootItem: WorkspaceReference? {
		var parent = self.parent
		while parent?.parent != nil {
			parent = parent?.parent
		}
		return parent
	}
}

public final class Workspace: WorkspaceReference {
	enum Error: Swift.Error {
		case invalid
	}
	let url: URL
	public var referenceURL: URL? { return url.deletingLastPathComponent() }
	public let fileWrapper: FileWrapper
	public var references: [WorkspaceItem] = []
	
	public class FileReference: WorkspaceItem {
		public var location: String
		public weak var parent: WorkspaceReference?
		public init(location: String, parent: WorkspaceReference) {
			self.location = location
			self.parent = parent
		}
	}
	
	public class GroupReference: WorkspaceItem {
		public var location: String
		public var name: String
		public var children: [WorkspaceItem]
		public weak var parent: WorkspaceReference?
		public init(location: String, name: String, children: [WorkspaceItem], parent: WorkspaceReference?) {
			self.location = location
			self.name = name
			self.children = children
			self.parent = parent
		}
	}
	
	public init(url: URL) throws {
		self.url = url
		self.fileWrapper = try FileWrapper(url: url, options: [])
		if fileWrapper.isDirectory == false {
			//throw
		}
		
		guard let workspaceData = fileWrapper.fileWrappers?["contents.xcworkspacedata"], workspaceData.isRegularFile,
			let data = workspaceData.regularFileContents else {
				throw Error.invalid
		}
		
		let document = try XMLDocument(data: data, options: [])
		guard let children = document.rootElement()?.children as? [XMLElement] else { throw Error.invalid }
		self.references = children.flatMap {
			childOf(element: $0, parent: self)
		}
	}
	
	func childOf(element: XMLElement, parent: WorkspaceReference) -> WorkspaceItem? {
		guard let elementType = element.name else { return nil }
		switch elementType {
		case "FileRef":
			guard let location = element.attribute(forName: "location")?.objectValue as? String else { return nil }
			return FileReference(location: location, parent: parent)
		case "Group":
			guard let childrenElements = element.children as? [XMLElement] else { return nil }
			guard let location = element.attribute(forName: "location")?.objectValue as? String else { return nil }
			guard let name = element.attribute(forName: "name")?.objectValue as? String else { return nil }
			let group = GroupReference(location: location, name: name, children: [], parent: parent)
			group.children = childrenElements.flatMap {
				childOf(element: $0, parent: group)
			}
			return group
		default:
			return nil
		}
	}
}
