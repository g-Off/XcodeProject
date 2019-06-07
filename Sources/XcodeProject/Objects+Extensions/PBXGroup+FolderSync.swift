//
//  PBXGroup+FolderSync.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2017-12-19.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public extension PBXGroup {
	@discardableResult
	func add(file: URL, createGroupsRecursively: Bool = true) -> PBXFileReference? {
		guard let url = url else { return nil }
		var matchingComponentsCount = 0
		var filePathComponents = file.pathComponents
		for components in zip(url.pathComponents, filePathComponents) {
			guard components.0 == components.1 else { break }
			matchingComponentsCount += 1
		}
		filePathComponents.removeFirst(matchingComponentsCount)
		var currentGroup: PBXGroup = self
		if createGroupsRecursively {
			var groups = filePathComponents
			groups.removeLast()
			groups.forEach {
				currentGroup = currentGroup.addGroup(pathComponent: $0)
			}
		}
		let fileReference = PBXFileReference(globalID: PBXGlobalID(), path: filePathComponents.last)
		currentGroup.add(child: fileReference)
		return fileReference
	}
	
	@discardableResult
	func addGroup(pathComponent: String) -> PBXGroup {
		let group = PBXGroup(globalID: PBXGlobalID(), name: nil, path: pathComponent, sourceTree: .group)
		children.append(group)
		return group
	}
	
	func sync(recursive: Bool, target: PBXTarget? = nil) {
		let target = target ?? parentProject?.targets.first
		removeDuplicateFiles(recursive: recursive)
		removeDuplicateFilesByPath(recursive: recursive)
		addMissingFiles(recursive: recursive, target: target)
		removeMissingFiles(recursive: recursive)
	}
	
	private func removeDuplicateFiles(recursive: Bool) {
		var seen: Set<PBXReference> = []
		var duplicates: [Int] = []
		for i in 0..<children.count {
			let child = children[i]
			if seen.contains(child) {
				duplicates.append(i)
			} else {
				seen.insert(child)
				if recursive, let group = child as? PBXGroup {
					group.removeDuplicateFiles(recursive: recursive)
				}
			}
		}
		duplicates.reversed().forEach {
			children.remove(at: $0)
		}
	}
	
	private func removeDuplicateFilesByPath(recursive: Bool) {
		var itemsByPath: [String: [PBXReference]] = [:]
		for i in 0..<children.count {
			let child = children[i]
			if let path = child.path {
				itemsByPath[path, default: []].append(child)
			}
			if recursive, let group = child as? PBXGroup {
				group.removeDuplicateFilesByPath(recursive: recursive)
			}
		}
		let duplicatePathItems = itemsByPath.filter { $0.value.count > 1 }
		duplicatePathItems.forEach { (path, references) in
			references.forEach { reference in
				if reference.buildFiles.isEmpty {
					remove(child: reference)
				}
			}
		}
	}
	
	private func removeMissingFiles(recursive: Bool) {
		var newChildren: [PBXReference] = []
		children.forEach {
			var keepChild = true
			if let group = $0 as? PBXGroup {
				if recursive {
					group.removeMissingFiles(recursive: recursive)
				}
				if group.children.isEmpty {
					// remove the group, delete the directory
					keepChild = false
					if let url = group.url {
						do {
							try FileManager.default.removeItem(at: url)
						} catch let error {
							print(error)
						}
					}
				}
			} else if let fileReference = $0 as? PBXFileReference, let url = fileReference.url {
				if !FileManager.default.fileExists(atPath: url.path) {
					let buildFiles = fileReference.buildFiles
					buildFiles.forEach {
						$0.buildPhase?.remove(file: $0)
						fileReference.unregister(buildFile: $0)
					}
					keepChild = false
				}
			}
			if keepChild {
				newChildren.append($0)
			}
		}
		children = newChildren
	}
	
	private func addMissingFiles(recursive: Bool, target: PBXTarget?) {
		guard let url = self.url else { return }
		
		let childPathItems: [(String, PBXReference)] = children.compactMap {
			guard let childURL = $0.url else { return nil }
			return (childURL.path, $0)
		}
		let childPathMap = Dictionary(uniqueKeysWithValues: childPathItems)
		do {
			let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
			let missing = contents.filter {
				return childPathMap[$0.path] == nil
			}
			let files = missing.filter { !$0.hasDirectoryPath }
			let additionalFiles = files.compactMap {
				add(file: $0)
			}
			
			if let target = target, !additionalFiles.isEmpty {
				additionalFiles.forEach {
					target.addFile($0)
				}
			}
			
			if recursive {
				let directories = missing.filter { $0.hasDirectoryPath }
				directories.forEach {
					addGroup(pathComponent: $0.lastPathComponent)
				}
				children.compactMap { $0 as? PBXGroup }.forEach {
					$0.addMissingFiles(recursive: recursive, target: target)
				}
			}
		} catch {
			
		}
	}
}
