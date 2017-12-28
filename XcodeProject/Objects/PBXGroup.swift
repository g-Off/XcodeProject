//
//  PBXGroup.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public class PBXGroup: PBXReference {
	public var children: [PBXReference] = [] {
		didSet {
			children.forEach {
				$0.parent = self
			}
		}
	}
	
	override func willMove(from: PBXObject?) {
		super.willMove(from: from)
		children.forEach {
			$0.willMove(from: from)
		}
	}
	
	override func didMove(to: PBXObject?) {
		super.didMove(to: to)
		children.forEach {
			$0.didMove(to: to)
		}
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		self.children = plist["children"]?.array?.map { return GlobalID(rawValue: $0) }.flatMap { objectCache.object(for: $0) as? PBXReference } ?? []
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		children.forEach {
			visitor.visit(object: $0)
		}
	}
	
	override var plistRepresentation: [String : Any?] {
		var plist = super.plistRepresentation
		plist["children"] = children.map { $0.plistID }
		return plist
	}
	
	public func add(child: PBXReference) {
		children.append(child)
		self.child(child, didMoveTo: self)
	}
	
	public func remove(child: PBXReference) {
		guard child.parent == self else { return }
		guard let index = children.index(of: child) else { return }
		children.remove(at: index)
		self.child(child, didMoveTo: nil)
	}
	
	private func child(_ child: PBXReference, didMoveTo parent: PBXObject?) {
		child.parent = parent
	}
	
	public override var displayName: String {
		if let parent = parent as? PBXProject {
			return parent.name ?? "Unknown Project"
		} else {
			return super.displayName
		}
	}
}
