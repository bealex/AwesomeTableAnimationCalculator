//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public protocol ASectionModel: Equatable {
    var startIndex:Int { get }
    var endIndex:Int { get }
}
