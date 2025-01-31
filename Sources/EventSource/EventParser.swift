//
//  EventParser.swift
//  EventSource
//
//  Copyright © 2023 Firdavs Khaydarov (Recouse). All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public protocol EventParser: Sendable {
    func parse(_ data: Data) -> [EVEvent]
}

/// ``ServerEventParser`` is used to parse text data into ``ServerEvent``.
public struct ServerEventParser: EventParser {
    let mode: EventSource.Mode

    init(mode: EventSource.Mode = .default) {
        self.mode = mode
    }

    static let lf: UInt8 = 0x0A
    static let colon: UInt8 = 0x3A

    public func parse(_ data: Data) -> [EVEvent] {
        // Split message with double newline
        let rawMessages: [Data]
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, *) {
            rawMessages = data.split(separator: [Self.lf, Self.lf])
        } else {
            rawMessages = data.split(by: [Self.lf, Self.lf])
        }

        // Parse data to ServerMessage model
        let messages: [ServerEvent] = rawMessages.compactMap { ServerEvent.parse(from: $0, mode: mode) }

        return messages
    }
}

fileprivate extension Data {
    @available(macOS, deprecated: 13.0, obsoleted: 13.0, message: "This method is not recommended on macOS 13.0+")
    @available(iOS, deprecated: 16.0, obsoleted: 16.0, message: "This method is not recommended on iOS 16.0+")
    @available(watchOS, deprecated: 9.0, obsoleted: 9.0, message: "This method is not recommended on watchOS 9.0+")
    @available(tvOS, deprecated: 16.0, obsoleted: 16.0, message: "This method is not recommended on tvOS 16.0+")
    @available(visionOS, deprecated: 1.0, obsoleted: 1.1, message: "This method is not recommended on visionOS 1.0+")
    func split(by separator: [UInt8]) -> [Data] {
        let doubleNewline = Data(separator)
        var splits: [Data] = []
        var currentIndex = 0
        var range: Range<Data.Index>?

        while true {
            range = self.range(of: doubleNewline, options: [], in: currentIndex..<self.count)
            if let foundRange = range {
                splits.append(self.subdata(in: currentIndex..<foundRange.lowerBound))
                currentIndex = foundRange.upperBound
            } else {
                splits.append(self.subdata(in: currentIndex..<self.count))
                break
            }
        }

        return splits
    }
}
