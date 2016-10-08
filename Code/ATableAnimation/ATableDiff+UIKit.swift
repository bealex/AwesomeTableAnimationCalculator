//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation
import UIKit

// MARK: - Applying calculation result to the UICollectionView
public extension ATableDiff {
    func applyTo(collectionView: UICollectionView) {
        applyTo(collectionView: collectionView, completionHandler: nil)
    }

    func applyTo(collectionView: UICollectionView, completionHandler: (() -> Void)?) {
        if self.isEmpty() {
            if let completionHandler = completionHandler {
                completionHandler()
            }
            return
        }

        let updates = {
            if self.updatedPaths.count != 0 {
                collectionView.reloadItems(at: self.updatedPaths as [IndexPath])
            }

            if self.deletedSections.count != 0 {
                collectionView.deleteSections(self.deletedSections as IndexSet)
            }
            if self.deletedPaths.count != 0 {
                collectionView.deleteItems(at: self.deletedPaths as [IndexPath])
            }

            if self.movedSections.count != 0 {
                for (sectionFrom, sectionTo) in self.movedSections {
                    collectionView.moveSection(sectionFrom, toSection: sectionTo)
                }
            }
            if self.movedPaths.count != 0 {
                for (indexPathFrom, indexPathTo) in self.movedPaths {
                    collectionView.moveItem(at: indexPathFrom as IndexPath, to: indexPathTo as IndexPath)
                }
            }

            if self.addedSections.count != 0 {
                collectionView.insertSections(self.addedSections as IndexSet)
            }
            if self.addedPaths.count != 0 {
                collectionView.insertItems(at: self.addedPaths as [IndexPath])
            }
        }

        let completion = { (_: Bool) in
            let hackyUpdates = {
                if self.movedPaths.count != 0 {
                    // Hack, because move does not update target items
                    var updatedIndexPaths: [IndexPath] = []

                    for (_, indexPathTo) in self.movedPaths {
                        updatedIndexPaths.append(indexPathTo as IndexPath)
                    }

                    collectionView.reloadItems(at: updatedIndexPaths)
                }

                if (self.updatedSectionHeaders.count != 0) {
                    collectionView.reloadSections(self.updatedSectionHeaders as IndexSet)
                }
            }

            collectionView.performBatchUpdates(hackyUpdates) { (_: Bool) in
                if let completionHandler = completionHandler {
                    completionHandler()
                }
            }
        }

        collectionView.performBatchUpdates(updates, completion: completion)
    }
}

// MARK: - Applying calculation result to the UITableView
public extension ATableDiff {
    func applyTo(tableView: UITableView) {
        applyTo(tableView: tableView, completionHandler: nil)
    }

    func applyTo(tableView: UITableView, completionHandler: (() -> Void)?) {
        if self.isEmpty() {
            if let completionHandler = completionHandler {
                completionHandler()
            }
            return
        }

        let updates = {
            if self.updatedPaths.count != 0 {
                tableView.reloadRows(at: self.updatedPaths as [IndexPath], with: .automatic)
            }

            if self.deletedSections.count != 0 {
                tableView.deleteSections(self.deletedSections as IndexSet, with: .automatic)
            }
            if self.deletedPaths.count != 0 {
                tableView.deleteRows(at: self.deletedPaths as [IndexPath], with: .automatic)
            }

            if self.movedSections.count != 0 {
                for (sectionFrom, sectionTo) in self.movedSections {
                    tableView.moveSection(sectionFrom, toSection: sectionTo)
                }
            }
            if self.movedPaths.count != 0 {
                for (indexPathFrom, indexPathTo) in self.movedPaths {
                    tableView.moveRow(at: indexPathFrom as IndexPath, to: indexPathTo as IndexPath)
                }
            }

            if self.addedSections.count != 0 {
                tableView.insertSections(self.addedSections as IndexSet, with: .automatic)
            }
            if self.addedPaths.count != 0 {
                tableView.insertRows(at: self.addedPaths as [IndexPath], with: .automatic)
            }
        }

        let completion = { (_: Bool) in
            let hackyUpdates = {
                if self.movedPaths.count > 0 {
                    // Hack, because move does not update target items
                    var updatedIndexPaths: [IndexPath] = []

                    for (_, indexPathTo) in self.movedPaths {
                        updatedIndexPaths.append(indexPathTo as IndexPath)
                    }

                    tableView.reloadRows(at: updatedIndexPaths, with: .none)
                }

                if self.updatedSectionHeaders.count != 0 {
                    tableView.reloadSections(self.updatedSectionHeaders as IndexSet, with: .none)
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

        DispatchQueue.main.async {
            completion(true)
        }
    }
}
