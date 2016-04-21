//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public struct ATableDiff {
    let updatedPaths:[NSIndexPath]

    let deletedPaths:[NSIndexPath]
    let deletedSections:NSIndexSet

    let addedPaths:[NSIndexPath]
    let addedSections:NSIndexSet

    let movedSections:[(Int, Int)]
    let movedPaths:[(NSIndexPath, NSIndexPath)]
}
