//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation
import AwesomeTableAnimationCalculator

@objc
public class ASectionModelExample: ASectionModel {
    public let title:String

    public init(title:String) {
        self.title = title
        super.init()
    }
}

public func ==(lhs: ASectionModelExample, rhs: ASectionModelExample) -> Bool {
    return lhs.title == rhs.title
}

extension ASectionModelExample {
    public override var debugDescription: String {
        return "\"\(title)\" (\(startIndex)–\(endIndex))"
    }
}
