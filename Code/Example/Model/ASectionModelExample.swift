//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation
import AwesomeTableAnimationCalculator

public class ASectionModelExample: ASectionModel, Equatable {
    public let title: String

    public init(title: String) {
        self.title = title
        super.init()
    }
}

public func == (lhs: ASectionModelExample, rhs: ASectionModelExample) -> Bool {
    return lhs.title == rhs.title
}

extension ASectionModelExample: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\"\(title)\" (\(startIndex)–\(endIndex))"
    }
}

@objc
public class ASectionModelExampleObjC: ASectionModelObjC {
    public let title: String

    public init(title: String) {
        self.title = title
        super.init()
    }

    public override var debugDescription: String {
        return "\"\(title)\" (\(startIndex)–\(endIndex))"
    }
}

public func == (lhs: ASectionModelExampleObjC, rhs: ASectionModelExampleObjC) -> Bool {
    return lhs.title == rhs.title
}
