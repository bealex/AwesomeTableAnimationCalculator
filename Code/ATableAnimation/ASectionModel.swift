//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation

/// Simple representation of the section. All child classes
/// must implement Equatable because of associatedtype in the ACellModel.
public class ASectionModel {
    internal private (set) var startIndex:Int = 0
    internal private (set) var endIndex:Int = 0

    internal func update(startIndex startIndex:Int, endIndex:Int) {
        self.startIndex = startIndex
        self.endIndex = endIndex
    }
}

