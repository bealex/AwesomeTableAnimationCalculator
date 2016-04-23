//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation

/// Simple representation of the section. All child classes
/// must implement Equatable because of associatedtype in the ACellModel.
public class ASectionModel: NSObject {
    public private (set) var startIndex:Int = 0
    public private (set) var endIndex:Int = 0

    public override init() {
        startIndex = 0
        endIndex = 0
        super.init()
    }

    internal func update(startIndex startIndex:Int, endIndex:Int) {
        self.startIndex = startIndex
        self.endIndex = endIndex
    }
}
