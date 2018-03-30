//
//  PBXPListArchiver.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-27.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public protocol StreamWritable: class {
	func write(_ string: String) throws
}

public class ConsoleStreamWriter: StreamWritable {
	public init() {
		
	}
	
	public func write(_ string: String) {
		print(string, terminator: "")
	}
}

public class StringStreamWriter: StreamWritable {
	var string: String = ""
	public func write(_ string: String) {
		self.string.append(string)
	}
}

public class DataStreamWriter: StreamWritable {
	public private(set) var data: Data = Data()
	
	public func write(_ string: String) {
		guard let stringData = string.data(using: .utf8) else { return }
		data.append(stringData)
	}
}

public class OutputStreamWriter: StreamWritable {
	private let stream: OutputStream
	public init(stream: OutputStream) {
		self.stream = stream
	}
	
	public func write(_ string: String) {
		guard let stringData = string.data(using: .utf8) else { return }
		// TODO: deal with errors
		_ = stringData.withUnsafeBytes {
			stream.write($0, maxLength: stringData.count)
		}
	}
}

struct Format {
	struct Indentation: CustomStringConvertible {
		var enabled = true
		var character: String = "\t"
		var level: Int = 0
		mutating func increase() {
			if enabled {
				level += 1
				precondition(level > 0, "indentation level overflow")
			}
		}
		mutating func decrease() {
			if enabled {
				precondition(level > 0, "indentation level underflow")
				level -= 1
			}
		}
		var description: String {
			return String(repeating: character, count: level)
		}
	}
	
	var startOfLine: String = "\n"
	var endOfLine: String = "\n"
	var indentation: Indentation = Indentation()
}

struct ObjectMap {
	let objectMap: [String: [PBXObject]]
	
	init(project: PBXProject) {
		var buckets: [String: [PBXObject]] = [:]
		
		let visitor = ObjectVisitor()
		visitor.visit(object: project)
		
		visitor.allObjects.forEach { object in
			buckets[String(describing: type(of: object)), default: []].append(object)
		}
		
		self.objectMap = buckets
	}
}

public final class PBXPListArchiver {
	let projectFile: ProjectFile
	private var archiveDictionary: [String: PListArchivable?] = [:]
	
	public init(projectFile: ProjectFile) {
		self.projectFile = projectFile
		archiveDictionary[ProjectFile.RootKey.archiveVersion] = projectFile.archiveVersion
		archiveDictionary[ProjectFile.RootKey.objectVersion] = projectFile.objectVersion.rawValue
		archiveDictionary[ProjectFile.RootKey.classes] = projectFile.classes
		archiveDictionary[ProjectFile.RootKey.objects] = ObjectMap(project: projectFile.project)
		archiveDictionary[ProjectFile.RootKey.rootObject] = projectFile.project.plistID
	}
	
	public func write(stream: StreamWritable) throws {
		var format = Format()
		
		try stream.write("// !$*UTF8*$!\(format.endOfLine)")
		try stream.write("{\(format.endOfLine)")
		format.indentation.increase()
		try archiveDictionary.sorted { (obj1, obj2) in
			return obj1.key < obj2.key
		}.forEach { (key, value) in
			guard let value = value else { return }
			try stream.write("\(format.indentation)\(key) = ")
			try stream.write(value.plistRepresentation(format: format))
			try stream.write(";\(format.endOfLine)")
		}
		format.indentation.decrease()
		
		try stream.write("}\(format.endOfLine)")
	}
}

final class ObjectVisitor {
	private var objectMap: [PBXObject.ID: PBXObject] = [:]
	private var visited = Set<PBXObject.ID>()
	
	func visit(object: PBXObject?, where predicate: @escaping (_ object: PBXObject) -> Bool = { _ in return true}) {
		guard let object = object else { return }
		guard !visited.contains(object.globalID) else { return }
		if predicate(object) {
			objectMap[object.globalID] = object
		}
		visited.insert(object.globalID)
		object.visit(self)
	}
	
	var allObjects: [PBXObject] {
		return objects()
	}
	
	func objects<T: PBXObject>() -> [T] {
		return objectMap.compactMap { return $0.value as? T }
	}
}

extension PBXObject {
	func objects<T: PBXObject>() -> [T] {
		let visitor = ObjectVisitor()
		visitor.visit(object: self)
		return visitor.objects()
	}
}
