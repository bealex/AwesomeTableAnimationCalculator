//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT
//

import Foundation

/// Simple representation of the section
public class ASectionModel {
    public let startIndex:Int
    public let endIndex:Int

    public init(startIndex:Int, endIndex:Int) {
        self.startIndex = startIndex
        self.endIndex = endIndex
    }
}

