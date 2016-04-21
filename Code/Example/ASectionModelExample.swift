//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT
//

import Foundation

public class ASectionModelExample: ASectionModel, Equatable {
    public let title:String

    public init(title:String, start:Int, end:Int) {
        self.title = title
        super.init(startIndex: start, endIndex:end)
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
