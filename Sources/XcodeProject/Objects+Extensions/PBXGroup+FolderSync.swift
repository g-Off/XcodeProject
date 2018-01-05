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
		guard let url = url else { return nil } // TODO: return an absolute reference? or maybe a project one?
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
		let fileReference = PBXFileReference(globalID: PBXObject.ID(), path: filePathComponents.last)
		currentGroup.add(child: fileReference)
		return fileReference
	}
	
	func addGroup(pathComponent: String) -> PBXGroup {
		let group = PBXGroup(globalID: PBXObject.ID(), name: nil, path: pathComponent, sourceTree: .group)
		children.append(group)
		return group
	}
	
	func sync(recursive: Bool, target: PBXTarget? = nil) {
		let target = target ?? parentProject?.targets.first
		addMissingFiles(recursive: recursive, target: target)
		removeMissingFiles(recursive: recursive)
	}
	
	private func removeMissingFiles(recursive: Bool) {
		//print("Removing missing file: \(url)")
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
		print("Adding missing file: \(url)")
		let childPathItems: [(String, PBXReference)] = children.flatMap {
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
			let additionalFiles = files.flatMap {
				add(file: $0)
			}
			
			if let target = target, !additionalFiles.isEmpty {
				additionalFiles.forEach {
					target.addFile($0)
				}
			}
			
			if recursive {
				let directories = missing.filter { $0.hasDirectoryPath }
				let groups = directories.map {
					addGroup(pathComponent: $0.lastPathComponent)
				}
				
				groups.forEach {
					$0.addMissingFiles(recursive: recursive, target: target)
				}
			}
		} catch {
			
		}
	}
}
