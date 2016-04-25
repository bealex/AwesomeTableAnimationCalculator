//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation

/**
 This protocol is needed because I want to provide two versions of the base class: Swift and Objective-C supproted.
 */
public protocol ASectionModelProtocol {
    var startIndex:Int { get }
    var endIndex:Int { get }

    func update(startIndex startIndex:Int, endIndex:Int)
}

/**
 Here is the pure Swift version
 */
public class ASectionModel: ASectionModelProtocol {
    public internal (set) var startIndex:Int = 0
    public internal (set) var endIndex:Int = 0

    public init() {}
}

/**
 This version must be used for Objective-C supported classes
 */
public class ASectionModelObjC: NSObject, ASectionModelProtocol {
    public internal (set) var startIndex:Int = 0
    public internal (set) var endIndex:Int = 0
}
