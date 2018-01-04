//
//  PBXObject.ID.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-16.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation
import GameplayKit

extension PBXObject {
	public struct ID: RawRepresentable {
		public let rawValue: String
		
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		public init?(rawValue: String?) {
			guard let rawValue = rawValue else { return nil }
			self.init(rawValue: rawValue)
		}
		
		public init() {
			self.rawValue = PBXObject.ID.generator.next()
		}
		
		static func ids(from strings: [String]?) -> [PBXObject.ID]? {
			return strings?.flatMap({ return PBXObject.ID(rawValue: $0) })
		}
		
		private static var generator: IDGenerator = IDGenerator()
		struct IDGenerator {
			let userHash: UInt8
			let pidByte: UInt8
			let referenceDateFunc: () -> UInt32
			
			private var initialSequence: UInt32 = 0
			private var randomSequence: UInt32 = 0
			private var lastTime: UInt32 = 0
			
			private var randomConst: UInt32 = 0
			
			init(userName: String = NSUserName(), processId: pid_t = getpid(), referenceDateFunc: @escaping () -> UInt32 = IDGenerator.referenceDate) {
				self.userHash = IDGenerator.userHash(userName: userName)
				self.pidByte = UInt8(truncatingIfNeeded: processId)
				self.referenceDateFunc = referenceDateFunc
				
				let seed = UInt32(processId) << 16 | UInt32(gethostid()) ^ referenceDateFunc()
				let source = GKLinearCongruentialRandomSource(seed: UInt64(seed))
				let random = GKRandomDistribution(randomSource: source, lowestValue: 0, highestValue: Int(Int32.max))
				
				self.randomConst = UInt32(random.nextInt(upperBound: 0xff_ff_ff))
				self.randomSequence = UInt32(random.nextInt(upperBound: 0xff_ff))
			}
			
			mutating func next() -> String {
				var refDate = referenceDateFunc()
				randomSequence += 1
				if refDate > lastTime {
					initialSequence = randomSequence
					lastTime = refDate
				} else {
					if randomSequence == initialSequence {
						lastTime += 1
					}
					refDate = lastTime
				}
				
				let components = [
					userHash.hexString,
					pidByte.hexString,
					randomSequence.hexString(size: 2),
					refDate.hexString(size: 4),
					randomConst.hexString(size: 4),
					]
				return components.joined()
			}
			
			static func referenceDate() -> UInt32 {
				let timeInterval = Date().timeIntervalSinceReferenceDate
				return UInt32(timeInterval)
			}
			
			static func userHash(userName: String) -> UInt8 {
				func hash(character: UnicodeScalar) -> Int32 {
					switch character {
					case "A"..."Z":
						return character.ordinal - "A".ordinal
					case "a"..."z":
						return character.ordinal - "a".ordinal
					case "0"..."9":
						return "Z".ordinal - "A".ordinal + 1 + (Int32(character.ordinal - "0".ordinal) % 5)
					default:
						return 31
					}
				}
				
				var userHash: Int32 = 0
				var hashValue: Int32 = 0
				
				for character in userName.unicodeScalars {
					var h = hash(character: character)
					if h != 0 {
						h = ((h << hashValue) >> 8) | (h << hashValue)
					}
					hashValue = (hashValue + 5) & 7
					userHash = userHash ^ h
				}
				return UInt8(truncatingIfNeeded: userHash)
			}
		}
	}
}

extension PBXObject.ID: Hashable {
	public var hashValue: Int {
		return rawValue.hashValue
	}
	
	public static func ==(lhs: PBXObject.ID, rhs: PBXObject.ID) -> Bool {
		return lhs.rawValue == rhs.rawValue
	}
}

extension PropertyList {
	var globalID: PBXObject.ID? {
		return PBXObject.ID(rawValue: self.string)
	}
}

private extension String {
	var ordinal: Int32 {
		return Int32(UnicodeScalar(self)!.value)
	}
}

private extension UnicodeScalar {
	var ordinal: Int32 {
		return Int32(value)
	}
}

private extension UInt8 {
	var hexString: String {
		return String(format: "%02X", self)
	}
}

private extension UInt32 {
	func hexString(size: UInt) -> String {
		var value = self
		var result: [String] = []
		for _ in 0..<size {
			result.append(UInt8(value & 0xff).hexString)
			value = value >> 8
		}
		result.reverse()
		return result.joined()
	}
}
