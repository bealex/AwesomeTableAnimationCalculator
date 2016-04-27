//
// Created by Alexander Babaev on 26.04.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

//MARK: Private methods for finding lists difference
private extension ATableAnimationCalculator {
    private var DEBUG_ENABLED: Bool {
        return true
    }

    func calculateDiff(items newItems:[ACellModelType]) throws -> ATableDiff {
        let sortedNewItems = newItems.map({ ACellModelType(copy:$0) }).sort(cellModelComparator)

        let newSections:[ASectionModelType] = sections(fromItems:sortedNewItems)

        let numberOfUniqueSections = newSections
        .map({ section in
            return newSections.filter({ $0 == section }).count == 1 ? 1 : 0
        })
        .reduce(0, combine: { result, value in result + value });

        if numberOfUniqueSections != newSections.count {
            throw NSError(domain:"ATableAnimationCalculator", code:1, userInfo:[NSLocalizedDescriptionKey: "Your data does have two same sections in the list. Possibly you forgot to setup comparator for the cells."])
        }

        var workingItems = items
        var workingSections = sections

        if DEBUG_ENABLED {
            print("Source items: \(debugPrint(items))");
            print("Target items: \(debugPrint(sortedNewItems))\n");
        }

        // first of all find updated items in the source data
        var updatedItemIndexPaths = findUpdatedItems(from:items, to:sortedNewItems)

        // all deleted indexes must be relative to initial data
        var deletedItemIndexPaths = findDeletedItems(from:workingItems, to:sortedNewItems, usingSections:workingSections)
        workingItems = deleteItems(withIndexes:deletedItemIndexPaths, from:workingItems, usingSections:workingSections)

        // после удалений обновим оставшиеся ячейки на новые, если нужно
        let workingSectionsBeforeResort = sections(fromItems:workingItems)
        let workingItemsBeforeResort = workingItems

        workingItems = updateUpdatedItems(workingItems, with:sortedNewItems).sort(cellModelComparator)
        let workingSectionsAfterResort = sections(fromItems:workingItems)

        if DEBUG_ENABLED {
            print("Updating: \(debugPrint(updatedItemIndexPaths))");
            print("Items: \(debugPrint(workingItemsBeforeResort)) --> \(debugPrint(workingItems))");
        }

        let sectionsAfterDeletions = sections(fromItems:workingItems)
        let deletedSectionIndexes = findDeletedSections(from:workingSections, to:sectionsAfterDeletions)

        deletedItemIndexPaths = deletedItemIndexPaths.filter { !deletedSectionIndexes.contains($0.section) }

        if DEBUG_ENABLED {
            print("Deleting: \(debugPrint(deletedSectionIndexes)) & \(debugPrint(deletedItemIndexPaths))");
            print("Work items: \(debugPrint(workingItems))\n");
        }

        updatedItemIndexPaths = deleteDeletedFromUpdated(updatedItemIndexPaths, deletedItems:deletedItemIndexPaths, deletedSections:deletedSectionIndexes, sectionData:sections)

        if DEBUG_ENABLED {
            print("Updating after deletion: \(debugPrint(updatedItemIndexPaths))");
            print("Work items: \(debugPrint(workingItems))\n");
        }

        let movedSectionIndexes = findMovedSections(from:workingSections, to:workingSectionsAfterResort)
        let movedItemIndexPaths = findMovedItems(
        from:workingItemsBeforeResort,
                to:workingItems,
                fromSections:workingSectionsBeforeResort,
                toSections:workingSectionsAfterResort,
                mapWithMovedSections:movedSectionIndexes)
        workingSections = workingSectionsAfterResort

        if DEBUG_ENABLED {
            print("Moving: \(debugPrint(movedSectionIndexes)) & \(debugPrint(movedItemIndexPaths))");
            print("Work items: \(debugPrint(workingItems))\n");
        }

        updatedItemIndexPaths = removeMovedIndexPaths(movedItemIndexPaths, fromUpdated:updatedItemIndexPaths)

        // all inserted indexes must be relative to target data
        let insertedSectionIndexes = findInsertedSections(from:workingSections, to:newSections)
        workingSections = newSections
        let insertedItemIndexPaths = findInsertedItems(from:workingItems, to:sortedNewItems, usingSections:workingSections, excludingInsertedSections:insertedSectionIndexes)
        workingItems = sortedNewItems

        if DEBUG_ENABLED {
            print("Inserting: \(debugPrint(insertedSectionIndexes)) & \(debugPrint(insertedItemIndexPaths))");
            print("Work items: \(debugPrint(workingItems))\n");
        }

        if DEBUG_ENABLED {
            print("Items count: \(items.count) --> \(sortedNewItems.count)");

            if (deletedSectionIndexes.count + insertedSectionIndexes.count != 0) {
                print("Old sections:\n\(sections)");
            } else {
                print("Sections:\n\(sections)");
            }

            if (updatedItemIndexPaths.count != 0) {
                print("Updated items:\n\(debugPrint(updatedItemIndexPaths))");
            }

            if (deletedSectionIndexes.count != 0) {
                print("Deleted sections:\n\(debugPrint(deletedSectionIndexes))");
            }
            if (deletedItemIndexPaths.count != 0) {
                print("Deleted items:\n\(debugPrint(deletedItemIndexPaths))");
            }

            if (insertedSectionIndexes.count != 0) {
                print("Inserted sections:\n\(debugPrint(insertedSectionIndexes))");
            }
            if (insertedItemIndexPaths.count != 0) {
                print("Inserted items:\n\(debugPrint(insertedItemIndexPaths))");
            }

            if (movedSectionIndexes.count != 0) {
                print("Moved sections:\n\(debugPrint(movedSectionIndexes))");
            }
            if (movedItemIndexPaths.count != 0) {
                print("Moved items:\n\(debugPrint(movedItemIndexPaths))");
            }

            if (deletedSectionIndexes.count + insertedSectionIndexes.count != 0) {
                print("New sections:\n\(newSections)");
            }
        }

        items = sortedNewItems
        sections = newSections

        return ATableDiff(
        updatedPaths:updatedItemIndexPaths,

                deletedPaths:deletedItemIndexPaths,
                deletedSections:deletedSectionIndexes,

                addedPaths:insertedItemIndexPaths,
                addedSections:insertedSectionIndexes,

                movedSections:movedSectionIndexes,
                movedPaths:movedItemIndexPaths)
    }

    func findUpdatedItems(from from:[ACellModelType], to:[ACellModelType]) -> [NSIndexPath] {
        let result:[NSIndexPath] =
        from.flatMap({ fromItem in
            if let fromIndex = from.indexOf(fromItem) {
                if let toIndex = to.indexOf(fromItem) {
                    let toItem = to[toIndex]

                    if !toItem.contentIsSameAsIn(fromItem) {
                        return self.indexPath(forItemIndex:fromIndex, usingSections:self.sections)
                    }
                }
            }

            return NSIndexPath?()
        })

        return result
    }

    func updateUpdatedItems(workItems:[ACellModelType], with newItems:[ACellModelType]) -> [ACellModelType] {
        var result = Array<ACellModelType>(workItems)

        for workIndex in 0 ..< workItems.count {
            if let newIndex = newItems.indexOf(workItems[workIndex]) {
                let newItem = newItems[newIndex]
                result[workIndex] = ACellModelType(copy:newItem)
            }
        }

        return result
    }

    func findDeletedSections(from from:[ASectionModelType], to:[ASectionModelType]) -> NSIndexSet {
        let result = NSMutableIndexSet()

        var index = 0
        from.forEach { item in
            if !to.contains(item) {
                result.addIndex(index)
            }

            index += 1
        }

        return result.copy() as! NSIndexSet
    }

    func deleteSections(withIndexes withIndexes:NSIndexSet, from:[ACellModelType], usingSections sections:[ASectionModelType]) -> [ACellModelType] {
        guard withIndexes.count != 0 else {
            return from
        }

        var result = Array<ACellModelType>(from)

        withIndexes.reverse().forEach { index in
            result.removeRange(sections[index].range)
        }

        return result
    }

    func findDeletedItems(from from:[ACellModelType], to:[ACellModelType], usingSections sections:[ASectionModelType]) -> [NSIndexPath] {
        var result = [NSIndexPath]()

        var index = 0
        from.forEach { fromItem in
            if !to.contains(fromItem) {
                if let indexPath = indexPath(forItemIndex:index, usingSections:sections) {
                    result.append(indexPath)
                }
            }

            index += 1
        }

        return result
    }

    func deleteItems(withIndexes withIndexes:[NSIndexPath], from:[ACellModelType], usingSections sections:[ASectionModelType]) -> [ACellModelType] {
        guard withIndexes.count != 0 else {
            return from
        }

        var result = Array<ACellModelType>(from)

        withIndexes.reverse().forEach { indexPath in
            result.removeAtIndex(sections[indexPath.section].startIndex + indexPath.row)
        }

        return result
    }

    func deleteDeletedFromUpdated(updatedIndexPaths:[NSIndexPath], deletedItems:[NSIndexPath], deletedSections:NSIndexSet, sectionData:[ASectionModelType]) -> [NSIndexPath] {
        var result = updatedIndexPaths

        for i in (0 ..< updatedIndexPaths.count).reverse() {
            if let indexPath = indexPath(forItemIndex:i, usingSections:sectionData) {
                if deletedSections.contains(indexPath.section) || deletedItems.contains(indexPath) {
                    result.removeAtIndex(i)
                }
            }
        }

        return result
    }

    func removeItems(from from:[ACellModelType], notExistingIn:[ACellModelType]) -> [ACellModelType] {
        var result = Array<ACellModelType>(from)

        for fromIndex in (0 ..< from.count).reverse() {
            if !notExistingIn.contains(from[fromIndex]) {
                result.removeAtIndex(fromIndex)
            }
        }

        return result
    }

    func findMovedSections(from from:[ASectionModelType], to:[ASectionModelType]) -> [(Int, Int)] {
        var result = [(Int, Int)]()

        for fromIndex in 0 ..< from.count {
            if let toIndex = to.indexOf(from[fromIndex]) where fromIndex != toIndex {
                result.append((fromIndex, toIndex))
            }
        }

        return result
    }

    func findMovedItems(from from:[ACellModelType], to:[ACellModelType],
                        fromSections:[ASectionModelType],
                        toSections:[ASectionModelType],
                        mapWithMovedSections movedSectionsIndexes:[(Int, Int)]) -> [(NSIndexPath, NSIndexPath)] {
        var result = [(NSIndexPath, NSIndexPath)]()

        func mapSectionIndexToOld(index:Int) -> Int {
            if let mappedIndexes = movedSectionsIndexes.filter({ $0.1 == index }).first {
                return mappedIndexes.0
            } else {
                return index
            }
        }

        for fromIndex in 0 ..< from.count {
            if let toIndex = to.indexOf(from[fromIndex]) {
                if let fromIndexPath = indexPath(forItemIndex:fromIndex, usingSections:fromSections),
                toIndexPath = indexPath(forItemIndex:toIndex, usingSections:toSections)
                where fromIndexPath != toIndexPath {
                    result.append((fromIndexPath, toIndexPath))
                }
            }
        }

        return result
    }

    func removeMovedIndexPaths(movedItemIndexPaths:[(NSIndexPath, NSIndexPath)], fromUpdated:[NSIndexPath]) -> [NSIndexPath] {
        let allFromIndexPaths = movedItemIndexPaths.map { $0.0 }
        return fromUpdated.filter { !allFromIndexPaths.contains($0) }
    }

    func moveSections(indexes indexes:[(Int, Int)], inside sourceItems:[ACellModelType], sourceSectionData:[ASectionModelType]) -> [ACellModelType] {
        var itemsBySections:[[ACellModelType]] = []

        for section in sourceSectionData {
            let sectionItems:[ACellModelType] = Array(sourceItems[section.startIndex ..< section.endIndex])
            itemsBySections.append(sectionItems)
        }

        var result:[ACellModelType] = []

        for sectionIndex in 0 ..< sourceSectionData.count {
            if let moveIndexes = indexes.filter({ $0.1 == sectionIndex }).first {
                result.appendContentsOf(itemsBySections[moveIndexes.0])
            } else {
                result.appendContentsOf(itemsBySections[sectionIndex])
            }
        }

        return result
    }

    func findInsertedSections(from from:[ASectionModelType], to:[ASectionModelType]) -> NSIndexSet {
        let result = NSMutableIndexSet()

        var index = 0
        to.forEach { toSection in
            if !from.contains(toSection) {
                result.addIndex(index)
            }

            index += 1
        }

        return result.copy() as! NSIndexSet
    }

    func findInsertedItems(from from:[ACellModelType], to:[ACellModelType], usingSections sections:[ASectionModelType], excludingInsertedSections insertedSections:NSIndexSet) -> [NSIndexPath] {
        var result = [NSIndexPath]()

        var index = 0
        to.forEach { toItem in
            if !from.contains(toItem) {
                if let indexPath = indexPath(forItemIndex:index, usingSections:sections) where !insertedSections.contains(indexPath.section) {
                    result.append(indexPath)
                }
            }

            index += 1
        }

        return result
    }
}

