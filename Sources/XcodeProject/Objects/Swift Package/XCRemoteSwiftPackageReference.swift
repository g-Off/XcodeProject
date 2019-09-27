//
//  XCRemoteSwiftPackageReference.swift
//  
//
//  Created by Geoffrey Foster on 2019-07-03.
//

import Foundation

public final class XCRemoteSwiftPackageReference: XCSwiftPackageReference {
	public enum Requirement: Encodable {
		private enum CodingKeys: String, CodingKey {
			case kind
			case minimumVersion
			case maximumVersion
			case version
			case branch
			case revision
		}

		public struct Version: CustomStringConvertible, Encodable {
			let major: Int
			let minor: Int
			let patch: Int

			public init(major: Int, minor: Int, patch: Int) {
				self.major = major
				self.minor = minor
				self.patch = patch
			}
			
			init?(_ value: String) {
				var integerValues = value.components(separatedBy: ".").compactMap { Int($0) }
				guard integerValues.count == 3 else { return nil }
				self.init(major: integerValues.removeFirst(), minor: integerValues.removeFirst(), patch: integerValues.removeFirst())
			}
			
			public var description: String {
				return "\(major).\(minor).\(patch)"
			}
			
			public func encode(to encoder: Encoder) throws {
				var container = encoder.singleValueContainer()
				try container.encode(description)
			}
		}
		
		public struct GitHash: Encodable, CustomStringConvertible {
			private var value: String
			init?(_ value: String) {
				// TODO: verify [0-9a-zA-Z] and exactly 40 characters, SHA-1 hash
				//value.trimmingCharacters(in: CharacterSet.)
				self.value = value
			}
			
			public var description: String {
				return value
			}
			
			public func encode(to encoder: Encoder) throws {
				var container = encoder.singleValueContainer()
				try container.encode(description)
			}
		}
		case upToNextMinorVersion(Version)
		case upToNextMajorVersion(Version)
		case versionRange(from: Version, to: Version)
		case exactVersion(Version)
		case branch(String)
		case revision(GitHash)
		
		init?(plist: PropertyList) {
			guard let kind = plist[CodingKeys.kind]?.string else { return nil }
			switch kind {
			case "upToNextMinorVersion":
				guard let versionString = plist[CodingKeys.minimumVersion]?.string, let version = Version(versionString) else { return nil }
				self = .upToNextMinorVersion(version)
			case "upToNextMajorVersion":
				guard let versionString = plist[CodingKeys.minimumVersion]?.string, let version = Version(versionString) else { return nil }
				self = .upToNextMajorVersion(version)
			case "versionRange":
				guard let minimumVersionString = plist[CodingKeys.minimumVersion]?.string,
					let minimumVersion = Version(minimumVersionString),
					let maximumVersionString = plist[CodingKeys.maximumVersion]?.string,
					let maximumVersion = Version(maximumVersionString) else {
						return nil
				}
				self = .versionRange(from: minimumVersion, to: maximumVersion)
			case "exactVersion":
				guard let versionString = plist[CodingKeys.version]?.string, let version = Version(versionString) else { return nil }
				self = .exactVersion(version)
			case "branch":
				guard let branch = plist[CodingKeys.branch]?.string else { return nil }
				self = .branch(branch)
			case "revision":
				guard let revisionString = plist[CodingKeys.revision]?.string, let revision = GitHash(revisionString) else { return nil }
				self = .revision(revision)
			default:
				return nil
			}
		}
		
		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			switch self {
			case .upToNextMinorVersion(let version):
				try container.encode("upToNextMinorVersion", forKey: .kind)
				try container.encode(version, forKey: .minimumVersion)
			case .upToNextMajorVersion(let version):
				try container.encode("upToNextMajorVersion", forKey: .kind)
				try container.encode(version, forKey: .minimumVersion)
			case .versionRange(let from, let to):
				try container.encode("versionRange", forKey: .kind)
				try container.encode(from, forKey: .minimumVersion)
				try container.encode(to, forKey: .maximumVersion)
			case .exactVersion(let version):
				try container.encode("exactVersion", forKey: .kind)
				try container.encode(version, forKey: .version)
			case .branch(let branch):
				try container.encode("branch", forKey: .kind)
				try container.encode(branch, forKey: .branch)
			case .revision(let revision):
				try container.encode("revision", forKey: .kind)
				try container.encode(revision, forKey: .revision)
			}
		}
	}
	
	private enum CodingKeys: String, CodingKey {
		case repositoryURL
		case requirement
	}

	var repositoryURL: String?
	var requirement: Requirement?
	
	override var archiveComment: String {
		guard let repositoryURL = repositoryURL, let url = URL(string: repositoryURL) else { return super.archiveComment }
		return #"\#(super.archiveComment) "\#(url.deletingPathExtension().lastPathComponent)""#
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		self.repositoryURL = plist[CodingKeys.repositoryURL]?.string
		if let requirementPlist = plist[CodingKeys.requirement] {
			self.requirement = Requirement(plist: requirementPlist)
		}
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(repositoryURL, forKey: .repositoryURL)
		try container.encodeIfPresent(requirement, forKey: .requirement)
	}
}
