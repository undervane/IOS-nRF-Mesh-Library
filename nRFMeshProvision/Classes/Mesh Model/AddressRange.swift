//
//  AddressRange.swift
//  nRFMeshProvision
//
//  Created by Aleksander Nowakowski on 21/03/2019.
//

import Foundation

public class AddressRange: RangeObject, Codable {
    
    public var lowAddress: Address {
        return range.lowerBound
    }
    
    public var highAddress: Address {
        return range.upperBound
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case lowAddress
        case highAddress
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lowAddressAsString  = try container.decode(String.self, forKey: .lowAddress)
        let highAddressAsString = try container.decode(String.self, forKey: .highAddress)
        
        guard let lowAddress = Address(hex: lowAddressAsString) else {
            throw DecodingError.dataCorruptedError(forKey: .lowAddress, in: container,
                                                   debugDescription: "Address must be 4-character hexadecimal string")
        }
        guard let highAddress = Address(hex: highAddressAsString) else {
            throw DecodingError.dataCorruptedError(forKey: .highAddress, in: container,
                                                   debugDescription: "Address must be 4-character hexadecimal string")
        }
        guard lowAddress.isUnicast || lowAddress.isGroup else {
            throw DecodingError.dataCorruptedError(forKey: .lowAddress, in: container,
                                                   debugDescription: "Low address must be a Unicast or Group address")
        }
        guard highAddress.isUnicast || highAddress.isGroup else {
            throw DecodingError.dataCorruptedError(forKey: .highAddress, in: container,
                                                   debugDescription: "High address must be a Unicast or Group address")
        }
        guard (lowAddress.isUnicast && highAddress.isUnicast) || (lowAddress.isGroup && highAddress.isGroup) else {
            throw DecodingError.dataCorruptedError(forKey: .highAddress, in: container,
                                                   debugDescription: "High address of different type than low address")
        }
        self.init(from: lowAddress, to: highAddress)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(range.lowerBound.hex, forKey: .lowAddress)
        try container.encode(range.upperBound.hex, forKey: .highAddress)
    }
}

// MARK: - Operators

public extension AddressRange {
    
    static func +(left: AddressRange, right: AddressRange) -> [AddressRange] {
        if left.distance(to: right) == 0 {
            return [AddressRange(min(left.lowerBound, right.lowerBound)...max(left.upperBound, right.upperBound))]
        }
        return [left, right]
    }
    
    static func -(left: AddressRange, right: AddressRange) -> [AddressRange] {
        var result: [AddressRange] = []
        
        // Left:   |------------|                    |-----------|                 |---------|
        //                  -                              -                            -
        // Right:      |-----------------|   or                     |---|   or        |----|
        //                  =                              =                            =
        // Result: |---|                             |-----------|                 |--|
        if right.lowerBound > left.lowerBound {
            let leftSlice = AddressRange(left.lowerBound...(min(left.upperBound, right.lowerBound - 1)))
            result.append(leftSlice)
        }
        
        // Left:                |----------|             |-----------|                     |--------|
        //                         -                          -                             -
        // Right:      |----------------|           or       |----|          or     |---|
        //                         =                          =                             =
        // Result:                      |--|                      |--|                     |--------|
        if right.upperBound < left.upperBound {
            let rightSlice = AddressRange(max(right.upperBound + 1, left.lowerBound)...left.upperBound)
            result.append(rightSlice)
        }

        return result
    }
    
}

public extension Array where Element == AddressRange {
    
    static func +=(array: inout [AddressRange], other: AddressRange) {
        array.append(other)
        array.merge()
    }
    
    static func +=(array: inout [AddressRange], otherArray: [AddressRange]) {
        array.append(contentsOf: otherArray)
        array.merge()
    }
    
    static func -=(array: inout [AddressRange], other: AddressRange)  {
        var result: [AddressRange] = []
        
        for this in array {
            result += this - other
        }
        array.removeAll()
        array.append(contentsOf: result)
    }
    
}
