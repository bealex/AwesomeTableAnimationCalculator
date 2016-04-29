//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation
import UIKit

//MARK: Applying calculation result to the UICollectionView
public extension ATableDiff {
    func applyTo(collectionView collectionView:UICollectionView) {
        applyTo(collectionView:collectionView, completionHandler:nil)
    }

    func applyTo(collectionView collectionView:UICollectionView, completionHandler:(() -> Void)?) {
        let updates = {
            if self.updatedPaths.count != 0 {
                collectionView.reloadItemsAtIndexPaths(self.updatedPaths)
            }

            if self.deletedSections.count != 0 {
                collectionView.deleteSections(self.deletedSections)
            }
            if self.deletedPaths.count != 0 {
                collectionView.deleteItemsAtIndexPaths(self.deletedPaths)
            }

            if self.movedSections.count != 0 {
                for (sectionFrom, sectionTo) in self.movedSections {
                    collectionView.moveSection(sectionFrom, toSection:sectionTo)
                }
            }
            if self.movedPaths.count != 0 {
                for (indexPathFrom, indexPathTo) in self.movedPaths {
                    collectionView.moveItemAtIndexPath(indexPathFrom, toIndexPath:indexPathTo)
                }
            }

            if self.addedSections.count != 0 {
                collectionView.insertSections(self.addedSections)
            }
            if self.addedPaths.count != 0 {
                collectionView.insertItemsAtIndexPaths(self.addedPaths)
            }
        }

        let completion = { (_:Bool) in
            let hackyUpdates = {
                if self.movedPaths.count != 0 {
                    // Hack, because move does not update target items
                    var updatedIndexPaths:[NSIndexPath] = []

                    for (_, indexPathTo) in self.movedPaths {
                        updatedIndexPaths.append(indexPathTo)
                    }

                    collectionView.reloadItemsAtIndexPaths(updatedIndexPaths)
                }

                if (self.updatedSectionHeaders.count != 0) {
                    collectionView.reloadSections(self.updatedSectionHeaders)
                }
            }

            collectionView.performBatchUpdates(hackyUpdates) { (_:Bool) in
                if let completionHandler = completionHandler {
                    completionHandler()
                }
            }
        }

        collectionView.performBatchUpdates(updates, completion:completion)
    }
}

//MARK: Applying calculation result to the UITableView
public extension ATableDiff {
    func applyTo(tableView tableView:UITableView) {
        applyTo(tableView:tableView, completionHandler:nil)
    }

    func applyTo(tableView tableView:UITableView, completionHandler:(() -> Void)?) {
        let updates = {
            if self.updatedPaths.count != 0 {
                tableView.reloadRowsAtIndexPaths(self.updatedPaths, withRowAnimation:.Automatic)
            }

            if self.deletedSections.count != 0 {
                tableView.deleteSections(self.deletedSections, withRowAnimation:.Automatic)
            }
            if self.deletedPaths.count != 0 {
                tableView.deleteRowsAtIndexPaths(self.deletedPaths, withRowAnimation:.Automatic)
            }

            if self.movedSections.count != 0 {
                for (sectionFrom, sectionTo) in self.movedSections {
                    tableView.moveSection(sectionFrom, toSection:sectionTo)
                }
            }
            if self.movedPaths.count != 0 {
                for (indexPathFrom, indexPathTo) in self.movedPaths {
                    tableView.moveRowAtIndexPath(indexPathFrom, toIndexPath:indexPathTo)
                }
            }

            if self.addedSections.count != 0 {
                tableView.insertSections(self.addedSections, withRowAnimation:.Automatic)
            }
            if self.addedPaths.count != 0 {
                tableView.insertRowsAtIndexPaths(self.addedPaths, withRowAnimation:.Automatic)
            }
        }

        let completion = { (_:Bool) in
            let hackyUpdates = {
                if self.movedPaths.count > 0 {
                    // Hack, because move does not update target items
                    var updatedIndexPaths:[NSIndexPath] = []

                    for (_, indexPathTo) in self.movedPaths {
                        updatedIndexPaths.append(indexPathTo)
                    }

                    tableView.reloadRowsAtIndexPaths(updatedIndexPaths, withRowAnimation:.None)
                }

                if (self.updatedSectionHeaders.count != 0) {
                    tableView.reloadSections(self.updatedSectionHeaders, withRowAnimation:.None)
                }
            }

            tableView.beginUpdates()
            hackyUpdates()
            tableView.endUpdates()
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }

        tableView.beginUpdates()
        updates()
        tableView.endUpdates()

        dispatch_async(dispatch_get_main_queue()) {
            completion(true)
        }
    }
}
