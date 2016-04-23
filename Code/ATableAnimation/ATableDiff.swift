//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation

/**
 Calculation result
 */
public struct ATableDiff {
    let updatedPaths:[NSIndexPath]

    let deletedPaths:[NSIndexPath]
    let deletedSections:NSIndexSet

    let addedPaths:[NSIndexPath]
    let addedSections:NSIndexSet

    let movedSections:[(Int, Int)]
    let movedPaths:[(NSIndexPath, NSIndexPath)]
}
