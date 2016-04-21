//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public class ASectionModelExample: ASectionModel {
    public let title:String

    public let startIndex:Int
    public let endIndex:Int

    public init(title:String, start:Int, end:Int) {
        self.title = title
        self.startIndex = start
        self.endIndex = end
    }
}

public func ==(lhs: ASectionModelExample, rhs: ASectionModelExample) -> Bool {
    return lhs.title == rhs.title
}

extension ASectionModelExample: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\"\(title)\" (\(startIndex)–\(endIndex))"
    }
}
