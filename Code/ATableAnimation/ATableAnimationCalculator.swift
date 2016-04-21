//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT
//

import Foundation

private extension ASectionModel {
    var range:Range<Int> {
        get {
            return Range<Int>(startIndex ..< endIndex)
        }
    }
}

/**
 This class can tell you, which sections and/or items must
 be updated (inserted, deleted) during DataSource update.

 It must solve common problem with complex CollectionViews, when new cells
 can appear/disappear/change in different places. Examples include chat messages,
 moderated comments list etc.

 Public interface is built for easy usage with standard `UICollectionView` or `UITableView`.
 */
public class ATableAnimationCalculator<ACellModelType:ACellModel> {
    var items:[ACellModelType] = []
    var sections:[ACellModelType.ASectionModelType] = []

    public var comparator:(ACellModelType, ACellModelType) -> Bool = { left, right in
        return false
    }

    public init() {
        comparator = { left, right in
            let indexLeft = self.items.indexOf(left)
            let indexRight = self.items.indexOf(right)

            return indexLeft < indexRight
        }
    }
}

//MARK: Public methods for easy use with UICollectionView DataSource
public extension ATableAnimationCalculator {
    /**
     - returns: number of sections
     */
    func sectionsCount() -> Int {
        return sections.count
    }

    /**
     - returns: number of items in section with sectionIndex
     */
    func itemsCount(inSection sectionIndex:Int) -> Int {
        let section = sections[sectionIndex]
        return section.endIndex - section.startIndex
    }

    /**
     - returns: section data by its index
     */
    func section(withIndex sectionIndex:Int) -> ACellModelType.ASectionModelType {
        return sections[sectionIndex]
    }

    /**
     - returns: item data by NSIndexPath (section/row indexes)
     */
    func item(forIndexPath indexPath:NSIndexPath) -> ACellModelType {
        let section = sections[indexPath.section]
        return items[section.startIndex + indexPath.row]
    }

    /**
     - returns: item data by item index (as if there were no sections)
     */
    func item(withIndex index:Int) -> ACellModelType {
        return items[index]
    }
}

//MARK: Public methods for adding/removing items
public extension ATableAnimationCalculator {
    /**
     Can be called after changing the comparator to update positions of elements.
     */
    func resortItems() throws -> ATableDiff {
        return try calculateDiff(items:items)
    }

    /**
     Changes all items in the DataSource.

     - returns: `AnimatableData` with the items to animate
     */
    func setItems(newItems:[ACellModelType]) throws -> ATableDiff {
        return try calculateDiff(items:newItems)
    }

    /**
     Inserts/updates/deletes items in the DataSource. Is useful if we've got a new list of items,
     but we don't know what exactly actions were applied to the list.

     - returns: `AnimatableData` with the items to animate
     */
    func updateItems(addOrUpdate addedOrUpdatedItems:[ACellModelType], delete:[ACellModelType]) throws -> ATableDiff {
        var itemsToProcess = Array<ACellModelType>(items)

        addedOrUpdatedItems.forEach { item in
            if let index = itemsToProcess.indexOf(item) {
                itemsToProcess[index] = ACellModelType(copy:item)
            } else {
                itemsToProcess.append(ACellModelType(copy:item))
            }
        }

        delete.forEach { item in
            if let index = itemsToProcess.indexOf(item) {
                itemsToProcess.removeAtIndex(index)
            }
        }

        return try setItems(itemsToProcess)
    }
}

//MARK: Private methods for finding lists difference
private extension ATableAnimationCalculator {
    private var DEBUG_ENABLED: Bool {
        return true
    }

    func calculateDiff(items newItems:[ACellModelType]) throws -> ATableDiff {
        let sortedNewItems = newItems.map({ ACellModelType(copy:$0) }).sort(comparator)

        let newSections:[ACellModelType.ASectionModelType] = sections(fromItems:sortedNewItems)

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

        // first of all find updated items in the source data
        let updatedItemIndexPaths = findUpdatedItems(from:items, to:sortedNewItems)

        // all deleted indexes must be relative to initial data
        let deletedSectionIndexes = findDeletedSections(from:workingSections, to:newSections)
        let deletedItemIndexPaths = findDeletedItems(from:workingItems, to:sortedNewItems, usingSections:workingSections, excludingDeletedSections:deletedSectionIndexes)
        workingItems = deleteItems(withIndexes:deletedItemIndexPaths, from:workingItems, usingSections:workingSections)
        workingItems = deleteSections(withIndexes:deletedSectionIndexes, from:workingItems, usingSections:workingSections)
        workingSections = sections(fromItems:workingItems)

        // let's find moved sections and items
        let newSortedItemsWithoutInserted = removeItems(from:sortedNewItems, notExistingIn:workingItems)
        let newSortedSectionsWithoutInserted = sections(fromItems:newSortedItemsWithoutInserted)
        let movedSectionIndexes = findMovedSections(from:workingSections, to:newSortedSectionsWithoutInserted)
        workingItems = moveSections(indexes:movedSectionIndexes, inside:workingItems, sourceSectionData:workingSections)
        let movedItemIndexPaths = findMovedItems(
                from:workingItems, to:newSortedItemsWithoutInserted,
                fromSections:workingSections,
                toSections:newSortedSectionsWithoutInserted,
                mapWithMovedSections:movedSectionIndexes)
        workingItems = newSortedItemsWithoutInserted
        workingSections = newSortedSectionsWithoutInserted

        // all inserted indexes must be relative to target data
        let insertedSectionIndexes = findInsertedSections(from:workingSections, to:newSections)
        workingSections = newSections
        let insertedItemIndexPaths = findInsertedItems(from:workingItems, to:sortedNewItems, usingSections:workingSections, excludingInsertedSections:insertedSectionIndexes)
        workingItems = sortedNewItems

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

    func findDeletedSections(from from:[ACellModelType.ASectionModelType], to:[ACellModelType.ASectionModelType]) -> NSIndexSet {
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

    func deleteSections(withIndexes withIndexes:NSIndexSet, from:[ACellModelType], usingSections sections:[ACellModelType.ASectionModelType]) -> [ACellModelType] {
        guard withIndexes.count != 0 else {
            return from
        }

        var result = Array<ACellModelType>(from)

        withIndexes.reverse().forEach { index in
            result.removeRange(sections[index].range)
        }

        return result
    }

    func findDeletedItems(from from:[ACellModelType], to:[ACellModelType], usingSections sections:[ACellModelType.ASectionModelType], excludingDeletedSections deletedSections:NSIndexSet) -> [NSIndexPath] {
        var result = [NSIndexPath]()

        var index = 0
        from.forEach { fromItem in
            if !to.contains(fromItem) {
                if let indexPath = indexPath(forItemIndex:index, usingSections:sections) where !deletedSections.contains(indexPath.section) {
                    result.append(indexPath)
                }
            }

            index += 1
        }

        return result
    }

    func deleteItems(withIndexes withIndexes:[NSIndexPath], from:[ACellModelType], usingSections sections:[ACellModelType.ASectionModelType]) -> [ACellModelType] {
        guard withIndexes.count != 0 else {
            return from
        }

        var result = Array<ACellModelType>(from)

        withIndexes.reverse().forEach { indexPath in
            result.removeAtIndex(sections[indexPath.section].startIndex + indexPath.row)
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

    func findMovedSections(from from:[ACellModelType.ASectionModelType], to:[ACellModelType.ASectionModelType]) -> [(Int, Int)] {
        var result = [(Int, Int)]()

        for fromIndex in 0 ..< from.count {
            if let toIndex = to.indexOf(from[fromIndex]) where fromIndex != toIndex {
                result.append((fromIndex, toIndex))
            }
        }

        return result
    }

    func findMovedItems(from from:[ACellModelType], to:[ACellModelType],
                        fromSections:[ACellModelType.ASectionModelType],
                        toSections:[ACellModelType.ASectionModelType],
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

    func moveSections(indexes indexes:[(Int, Int)], inside sourceItems:[ACellModelType], sourceSectionData:[ACellModelType.ASectionModelType]) -> [ACellModelType] {
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

    func findInsertedSections(from from:[ACellModelType.ASectionModelType], to:[ACellModelType.ASectionModelType]) -> NSIndexSet {
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

    func findInsertedItems(from from:[ACellModelType], to:[ACellModelType], usingSections sections:[ACellModelType.ASectionModelType], excludingInsertedSections insertedSections:NSIndexSet) -> [NSIndexPath] {
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

//MARK: Private helper methods
private extension ATableAnimationCalculator {
    func indexPath(forItemIndex itemIndex:Int, usingSections:[ACellModelType.ASectionModelType]) -> NSIndexPath? {
        var result:NSIndexPath? = nil

        var sectionIndex = 0
        for section in usingSections {
            if section.startIndex <= itemIndex && section.endIndex > itemIndex {
                result = NSIndexPath(forRow:itemIndex - section.startIndex, inSection:sectionIndex)
                break
            }

            sectionIndex += 1
        }

        return result;
    }

    func sections(fromItems items:[ACellModelType]) -> [ACellModelType.ASectionModelType] {
        var result:[ACellModelType.ASectionModelType] = []

        if let firstItem = items.first {
            var currentSectionItem: ACellModelType = firstItem
            var currentSectionStartIndex = 0
            var currentSectionEndIndex = 1

            for item in items.suffix(items.count - 1) {
                currentSectionEndIndex += 1

                if !currentSectionItem.isInSameSectionWith(item) {
                    result.append(currentSectionItem.createSection(startIndex:currentSectionStartIndex, endIndex:currentSectionEndIndex - 1))

                    currentSectionItem = item
                    currentSectionStartIndex = currentSectionEndIndex - 1
                }
            }

            if currentSectionStartIndex != currentSectionEndIndex {
                result.append(currentSectionItem.createSection(startIndex:currentSectionStartIndex, endIndex:currentSectionEndIndex))
            }
        }

        return result
    }
}

//MARK: Some debug output methods
private extension ATableAnimationCalculator {
    func debugPrint(name name:String, strings:[String]) -> String {
        let separator = strings.count < 20 ? ", " : ",\n  "
        let prefix = strings.count < 20 ? " " : "\n  "
        let suffix = strings.count < 20 ? "" : "\n"

        return "[\(name):\(prefix)\(strings.joinWithSeparator(separator))\(suffix)]"
    }

    func debugPrint(indexSet:NSIndexSet) -> String {
        return debugPrint(name:"indexes", strings:indexSet.map { "\($0)" })
    }

    func debugPrint(indexPaths:[NSIndexPath]) -> String {
        return debugPrint(name:"indexPaths", strings:indexPaths.map { "\($0.section)-\($0.row)" })
    }

    func debugPrint(indexPathPairs:[(NSIndexPath, NSIndexPath)]) -> String {
        return debugPrint(name:"indexPathPairs", strings:indexPathPairs.map { "\($0.0.section)-\($0.0.row) -> \($0.1.section)-\($0.1.row)" })
    }

    func debugPrint(indexPathPairs:[(Int, Int)]) -> String {
        return debugPrint(name:"indexPairs", strings:indexPathPairs.map { "\($0.0) -> \($0.1)" })
    }
}