//
//  PBXGlobalID+Generator.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2018-12-02.
//

import Foundation

extension PBXGlobalID {
	struct Generator {
		private struct GlobalIdentifier: CustomStringConvertible {
			let userHash: UInt8
			let pidByte: UInt8
			var random: UInt16
			var time: UInt32
			let zero: UInt8 = 0
			let hostShift: UInt8
			let hostHigh: UInt8
			let hostLow: UInt8
			
			var description: String {
				let components = [
					userHash.hexRepresentation,
					pidByte.hexRepresentation,
					random.hexRepresentation,
					time.hexRepresentation,
					zero.hexRepresentation,
					hostShift.hexRepresentation,
					hostHigh.hexRepresentation,
					hostLow.hexRepresentation,
					]
				return components.joined()
			}
		}
		
		private var gid: GlobalIdentifier
		
		private var randomSequence: UInt16 = 0
		private let referenceDateGenerator: () -> Date
		
		private var lastTime: UInt32 = 0
		private var firstSequence: UInt16 = 0
		
		init(userName: String = NSUserName(), processId: pid_t = getpid(), random: inout RandomNumberGenerator, referenceDateGenerator: @escaping () -> Date = Generator.referenceDate) {
			self.referenceDateGenerator = referenceDateGenerator
			
			var hostId: UInt32 = UInt32(gethostid())
			if hostId == 0 {
				hostId = random.next()
			}
			self.gid = GlobalIdentifier(
				userHash: Generator.userHash(userName: userName),
				pidByte: UInt8(truncatingIfNeeded: processId),
				random: random.next(),
				time: 0,
				hostShift: UInt8(truncatingIfNeeded: (hostId >> 0x10) & 0xff),
				hostHigh: UInt8(truncatingIfNeeded: (hostId & 0xff00) >> 0x8),
				hostLow: UInt8(truncatingIfNeeded: hostId & 0xff)
			)
		}
		
		mutating func next() -> String {
			let randomValue = gid.random + 1
			
			let time = UInt32(referenceDateGenerator().timeIntervalSinceReferenceDate)
			if time > lastTime {
				firstSequence = randomValue
				lastTime = time
			} else if firstSequence == randomValue {
				lastTime += 1
			}
			
			gid.random = randomValue
			gid.time = lastTime
			
			return gid.description
		}
		
		static func referenceDate() -> Date {
			return Date()
		}
		
		static func userHash(userName: String) -> UInt8 {
			func hash(character: UnicodeScalar) -> UInt32 {
				let uppercaseA: UnicodeScalar = "A"
				let uppercaseZ: UnicodeScalar = "Z"
				let lowercaseA: UnicodeScalar = "a"
				let zero: UnicodeScalar = "0"
				switch character {
				case "A"..."Z":
					return character.value - uppercaseA.value
				case "a"..."z":
					return character.value - lowercaseA.value
				case "0"..."9":
					return uppercaseZ.value - uppercaseA.value + 1 + (UInt32(character.value - zero.value) % 5)
				default:
					return 31
				}
			}
			
			var userHash: UInt32 = 0
			var hashValue: UInt32 = 0
			userName.unicodeScalars.map { hash(character: $0) }.forEach {
				var h = $0
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

extension BinaryInteger {
	var hexRepresentation: String {
		let hex = String(self, radix: 16, uppercase: true)
		let byteCount = bitWidth / 4
		let padding = max(byteCount - hex.count, 0)
		return String(repeating: "0", count: padding) + hex
	}
}
