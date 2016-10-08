//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation

// MARK: - Some helper extensions

private extension ASectionModelProtocol {
    var range: CountableRange<Int> {
        get {
            return CountableRange<Int>(startIndex ..< endIndex)
        }
    }
}

internal extension ASectionModelProtocol {
    func update(startIndex: Int, endIndex: Int) {
    }
}

public extension ASectionModel {
    public func update(startIndex: Int, endIndex: Int) {
        self.startIndex = startIndex
        self.endIndex = endIndex
    }
}

public extension ASectionModelObjC {
    public func update(startIndex: Int, endIndex: Int) {
        self.startIndex = startIndex
        self.endIndex = endIndex
    }
}

// MARK: - Calculator class

/**
    This class can tell you, which sections and/or items must
    be updated (inserted, deleted) during DataSource update.

    It must solve common problem with complex CollectionViews, when new cells
    can appear/disappear/change in different places. Examples include chat messages,
    moderated comments list etc.

    Public interface is built for easy usage with standard `UICollectionView` or `UITableView`.
 */
open class ATableAnimationCalculator<ACellSectionModelType: ACellSectionModel>: NSObject {
    fileprivate let cellSectionFactory: ACellSectionModelType
    fileprivate typealias ACellModelType = ACellSectionModelType.ACellModelType
    fileprivate typealias ASectionModelType = ACellSectionModelType.ASectionModelType

    open private(set) var items: [ACellModelType] = []
    open private(set) var sections: [ASectionModelType] = []

    open var printDebugLogs: Bool = false

    open var cellModelComparator: ((ACellModelType, ACellModelType) -> Bool)? = nil

    public init(cellSectionModel: ACellSectionModelType) {
        self.cellSectionFactory = cellSectionModel
    }

    // MARK: - Public methods for easy use with UICollectionView DataSource

    /**
     - returns: number of sections
     */
    public func sectionsCount() -> Int {
        return sections.count
    }

    /**
     - returns: number of items in section with sectionIndex
     */
    public func itemsCount(inSection sectionIndex: Int) -> Int {
        let section = sections[sectionIndex]
        return section.endIndex - section.startIndex
    }

    /**
        - returns: section data by its index
     */
    public func section(withIndex sectionIndex: Int) -> ASectionModelType {
        return sections[sectionIndex]
    }

    /**
        - returns: item data by IndexPath (section/row indexes)
     */
    public func item(forIndexPath indexPath: IndexPath) -> ACellModelType {
        let section = sections[indexPath.section]
        return items[section.startIndex + indexPath.row]
    }

    /**
        - returns: item data by item index (as if there were no sections)
     */
    public func item(withIndex index: Int) -> ACellModelType {
        return items[index]
    }

    /**
        - returns: IndexPath of a specified item, or nil if item is not in the model
     */
    public func indexPath(forItem item: ACellModelType) -> IndexPath? {
        if let index = items.index(of: item) {
            return indexPath(forItemIndex: index, usingSections: sections)
        } else {
            return nil
        }
    }

    /**
        - returns: IndexPath of a specified item index, or nil if item is not in the model
     */
    public func indexPath(forItemIndex itemIndex: Int) -> IndexPath? {
        return indexPath(forItemIndex: itemIndex, usingSections: sections)
    }

    // MARK: - Public methods for adding/removing items

    /**
        Can be called after changing the comparator to update positions of elements.
     */
    public func resortItems() throws -> ATableDiff {
        return try setItems(items, alreadySorted: false)
    }

    /**
         Changes all items in the DataSource.
            - returns: `AnimatableData` with the items to animate
     */
    public func setItems(_ newItems: [ACellModelType], alreadySorted: Bool = false) throws -> ATableDiff {
        // ToDo: we can call this method if we need to insert only one item as well. Let's try to remove sort dependency here
        return try calculateDiff(items: newItems, alreadySorted: alreadySorted)
    }

    /**
         Inserts/updates/deletes items in the DataSource. Is useful if we've got a new list of items,
         but we don't know what exactly actions were applied to the list.
            - returns: `AnimatableData` with the items to animate
     */
    public func updateItems(addOrUpdate addedOrUpdatedItems: [ACellModelType], delete: [ACellModelType]) throws -> ATableDiff {
        var itemsToProcess = Array<ACellModelType>(items)

        var needToResort = false

        addedOrUpdatedItems.forEach { item in
            if let index = itemsToProcess.index(of: item) {
                itemsToProcess[index] = ACellModelType(copy: item)
            } else {
                itemsToProcess.append(ACellModelType(copy: item))
            }

            needToResort = true //ToDo: insert item onto correct place and remove this
        }

        delete.forEach { item in
            if let index = itemsToProcess.index(of: item) {
                itemsToProcess.remove(at: index)
            }
        }

        return try setItems(itemsToProcess, alreadySorted: !needToResort)
    }

    public func removeItem(withIndex indexPath: IndexPath) throws -> ATableDiff {
        var itemsToProcess = Array<ACellModelType>(items)
        itemsToProcess.remove(at: section(withIndex: indexPath.section).startIndex + indexPath.row)
        return try setItems(itemsToProcess, alreadySorted: true)
    }

    public func swapItems(withIndex sourceIndexPath: IndexPath, toIndex destinationIndexPath: IndexPath) throws -> ATableDiff {
        var itemsToProcess = Array<ACellModelType>(items)

        let sourceIndex = section(withIndex: sourceIndexPath.section).startIndex + sourceIndexPath.row
        let destinationIndex = section(withIndex: destinationIndexPath.section).startIndex + destinationIndexPath.row

        let tmpValue = itemsToProcess.remove(at: sourceIndex)
        itemsToProcess.insert(tmpValue, at: destinationIndex)

        return try setItems(itemsToProcess, alreadySorted: true)
    }

    // MARK: - Private methods for finding lists difference

    private func calculateDiff(items newShinyItems: [ACellModelType], alreadySorted: Bool) throws -> ATableDiff {
        var newItems = newShinyItems.map({ ACellModelType(copy: $0) })
        if !alreadySorted {
            if let comparator = cellModelComparator {
                newItems = newItems.sorted(by: comparator)
            }
        }

        let newSections: [ASectionModelType] = sections(fromItems: newItems)

        let numberOfUniqueSections = newSections
                .map({ section in
                    return newSections.filter({ $0 == section }).count == 1 ? 1 : 0
                })
                .reduce(0, { result, value in result + value })

        if numberOfUniqueSections != newSections.count {
            throw NSError(domain: "ATableAnimationCalculator", code: 1, userInfo:
                [NSLocalizedDescriptionKey:
                         "Your data does have two same sections in the list. " +
                         "Possibly you forgot to setup comparator for the cells."])
        }

        let oldItems = items
        let oldSections = sections

        if printDebugLogs {
            print("Old: \(debugPrint(oldItems)) | \(debugPrint(oldSections))")
            print("New: \(debugPrint(newItems)) | \(debugPrint(newSections))\n")
        }

        var (deletedItemIndexesOld, updatedItemIndexesOld, movedItemIndexesOldNew) =
                findDeletedUpdatedMovedItems(oldItems: oldItems, oldSections: oldSections, newItems: newItems, newSections: newSections)

        var insertedItemIndexesNew = findInsertedItems(oldItems: oldItems, newItems: newItems, newSections: newSections)

        // if item is being moved, it must not be updated at the same time
        updatedItemIndexesOld = updatedItemIndexesOld.filter { updateIndex in
            return movedItemIndexesOldNew.filter({ $0.0 == updateIndex || $0.1 == updateIndex }).isEmpty
        }

        if printDebugLogs {
            print("- Index Paths (before section calculations): ")
            print("Deleted: \(debugPrint(deletedItemIndexesOld))")
            print("Updated: \(debugPrint(updatedItemIndexesOld))")
            print("Inserted: \(debugPrint(insertedItemIndexesNew))")
            print("Moved: \(debugPrint(movedItemIndexesOldNew))")
        }

        // removed sections
        let deletedSectionIndexesOld = findTotallyDestroyedSectionsFrom(
                oldSections, byDeletedIndexes: deletedItemIndexesOld,
                insertedIndexes: insertedItemIndexesNew, movedIndexes: movedItemIndexesOldNew)
        deletedItemIndexesOld = deletedItemIndexesOld.filter { !deletedSectionIndexesOld.contains($0.section) }

        // if section is deleted, we must not delete items from it
        let movedItemIndexesOldNewFromDestroyedSections = movedItemIndexesOldNew.filter { deletedSectionIndexesOld.contains($0.0.section) }
        insertedItemIndexesNew.append(contentsOf: movedItemIndexesOldNewFromDestroyedSections.map { $0.1 })
        movedItemIndexesOldNew = movedItemIndexesOldNew.filter { !deletedSectionIndexesOld.contains($0.0.section) }

        // let's find added sections
        let insertedSectionIndexesNew = findInsertedSectionsTo(oldSections, byInsertedIndexes: insertedItemIndexesNew,
                movedIndexes: movedItemIndexesOldNew)

        // if section is added, we must not insert into it
        let movedItemIndexesOldNewToInsertedSections = movedItemIndexesOldNew.filter { insertedSectionIndexesNew.contains($0.1.section) }
        deletedItemIndexesOld.append(contentsOf: movedItemIndexesOldNewToInsertedSections.map { $0.0 })
        movedItemIndexesOldNew = movedItemIndexesOldNew.filter { !insertedSectionIndexesNew.contains($0.1.section) }

        // moved sections are not used in this version of the algorythm
        let movedSectionIndexes = [(Int, Int)]()

        let updatedSectionIndexesNew = findUpdatedSections(old: oldSections, new: newSections)

        if printDebugLogs {
            print("\n")
            print("- Index Paths (after section calculations): ")
            print("Deleted: \(debugPrint(deletedItemIndexesOld))")
            print("Updated: \(debugPrint(updatedItemIndexesOld))")
            print("Inserted: \(debugPrint(insertedItemIndexesNew))")
            print("Moved: \(debugPrint(movedItemIndexesOldNew))")
            print("- Section Indexes: ")
            print("Deleted: \(debugPrint(deletedSectionIndexesOld))")
            print("Updated: \(debugPrint(updatedSectionIndexesNew))")
            print("Inserted: \(debugPrint(insertedSectionIndexesNew))")
            print("Moved: \(debugPrint(movedSectionIndexes))")
        }

        movedItemIndexesOldNew = removeRedundantMovesAfterDeletesAndInsertions(
                from: movedItemIndexesOldNew,
                deletedIndexes: deletedItemIndexesOld,
                deletedSections: deletedSectionIndexesOld,
                insertedIndexes: insertedItemIndexesNew,
                insertedSections: insertedSectionIndexesNew)

        movedItemIndexesOldNew = removeRedundantMovesAfterOtherMoves(movedItemIndexesOldNew)

        if printDebugLogs {
            print("\n")
            print("- Index Paths (after optimizations): ")
            print("Deleted: \(debugPrint(deletedItemIndexesOld))")
            print("Updated: \(debugPrint(updatedItemIndexesOld))")
            print("Inserted: \(debugPrint(insertedItemIndexesNew))")
            print("Moved: \(debugPrint(movedItemIndexesOldNew))")
            print("- Section Indexes: ")
            print("Deleted: \(debugPrint(deletedSectionIndexesOld))")
            print("Updated: \(debugPrint(updatedSectionIndexesNew))")
            print("Inserted: \(debugPrint(insertedSectionIndexesNew))")
            print("Moved: \(debugPrint(movedSectionIndexes))")
        }

        items = newItems
        sections = newSections

        return ATableDiff(
            updatedPaths: updatedItemIndexesOld,
            updatedSectionHeaders: updatedSectionIndexesNew,

            deletedPaths: deletedItemIndexesOld,
            deletedSections: deletedSectionIndexesOld,

            addedPaths: insertedItemIndexesNew,
            addedSections: insertedSectionIndexesNew,

            movedSections: movedSectionIndexes,
            movedPaths: movedItemIndexesOldNew
        )
    }

    // [indexPathPairs: 0-0 -> 0-1, 0-1 -> 0-2, 0-2 -> 0-3, 0-3 -> 0-4, 0-4 -> 0-0]
    // must be resolved to
    // [indexPathPairs: 0-4 -> 0-0]
    // and
    // [indexPathPairs: 0-0 -> 0-4, 0-1 -> 0-0, 0-2 -> 0-1, 0-3 -> 0-2, 0-4 -> 0-3]
    // to
    // [indexPathPairs: 0-0 -> 0-4]
    private func removeRedundantMovesAfterOtherMoves(_ movedIndexes: [(IndexPath, IndexPath)]) -> [(IndexPath, IndexPath)] {
        var newMovedIndexes = [(IndexPath, IndexPath)]()
        var indexesToProcess = movedIndexes

        while !indexesToProcess.isEmpty {
            let moveIndex = indexesToProcess.removeFirst()

            if moveIndex.0.section != moveIndex.1.section {
                // skip moves between sections
                newMovedIndexes.append(moveIndex)
            } else {
                let chain = findChain(startingFrom: moveIndex, indexes: movedIndexes)
                if chain.count == 1 {
                    newMovedIndexes.append(moveIndex)
                } else {
                    if let longestMove = findLongestMoveFor(chain) {
                        newMovedIndexes.append(longestMove)
                        chain.forEach { itemToRemove in
                            if let indexToRemove = indexesToProcess.index(where: {$0 == itemToRemove}) {
                                indexesToProcess.remove(at: indexToRemove)
                            }
                        }
                    }
                }
            }
        }

        return newMovedIndexes
    }

    private func findLongestMoveFor(_ chain: [(IndexPath, IndexPath)]) -> (IndexPath, IndexPath)? {
        if let longJump = chain.filter({ abs($0.0.row - $0.1.row) > 1 }).first {
            return longJump
        } else if chain.count == 2 && chain.filter({ abs($0.0.row - $0.1.row) == 1 }).count == chain.count {
            // close swap
            return chain.first
        }

        return nil
    }

    private func findChain(startingFrom startIndexes: (IndexPath, IndexPath), indexes: [(IndexPath, IndexPath)])
                    -> [(IndexPath, IndexPath)] {
        assert(startIndexes.0.section == startIndexes.1.section)

        var chain = [(IndexPath, IndexPath)]()
        chain.append(startIndexes)

        var lastIndexes = startIndexes
        var weHaveLongJump = abs(startIndexes.0.row - startIndexes.1.row) > 1

        var chainIsCyclic = false

        while let nextInChain = indexes.filter({ $0.0 == lastIndexes.1 && $0.1.section == lastIndexes.0.section }).first {
            if nextInChain == startIndexes {
                chainIsCyclic = true
                break
            }

            // we are searching for the continuous cyclic move chain.
            let longJump = abs(nextInChain.0.row - nextInChain.1.row) > 1
            if weHaveLongJump && longJump {
                chain.removeAll()
                chain.append(startIndexes)
                break
            }
            weHaveLongJump = longJump

            chain.append(nextInChain)
            lastIndexes = nextInChain
        }

        if !chainIsCyclic {
            chain.removeAll()
            chain.append(startIndexes)
        }

        return chain
    }

    private func removeRedundantMovesAfterDeletesAndInsertions(from: [(IndexPath, IndexPath)],
            deletedIndexes: [IndexPath], deletedSections: IndexSet,
            insertedIndexes: [IndexPath], insertedSections: IndexSet) -> [(IndexPath, IndexPath)] {
        var originalMoveIndexes = from

        // process deleted sections
        var movedIndexes: [(IndexPath, IndexPath)] = from.map { (oldIndex, newIndex) in
            let movedDownBy = deletedSections.filter({ index in
                index < oldIndex.section
            }).count

            return (IndexPath(item: oldIndex.row, section: oldIndex.section - movedDownBy), newIndex)
        }

        // process deleted items
        movedIndexes = movedIndexes.map { (oldIndex, newIndex) in
            if oldIndex.section != newIndex.section {
                return (oldIndex, newIndex)
            } else {
                let movedDownBy = deletedIndexes.filter({ deletedIndex in
                    return deletedIndex.section == oldIndex.section && deletedIndex.row < oldIndex.row
                }).count

                return (IndexPath(item: oldIndex.row - movedDownBy, section: oldIndex.section), newIndex)
            }
        }

        // remove items that became the same
        var newMovedIndexes = [(IndexPath, IndexPath)]()
        for i in 0 ..< movedIndexes.count {
            let movedIndex = movedIndexes[i]
            if movedIndex.0 != movedIndex.1 {
                newMovedIndexes.append(originalMoveIndexes[i])
            }
        }

        movedIndexes = newMovedIndexes
        originalMoveIndexes = movedIndexes

        // process inserted sections
        movedIndexes = movedIndexes.map { (oldIndex, newIndex) in
            let movedDownBy = insertedSections.filter({ index in
                return index < newIndex.section
            }).count

            return (oldIndex, IndexPath(item: newIndex.row, section: newIndex.section - movedDownBy))
        }

        // process inserted items
        movedIndexes = movedIndexes.map { (oldIndex, newIndex) in
            if oldIndex.section != newIndex.section {
                return (oldIndex, newIndex)
            } else {
                let movedDownBy = insertedIndexes.filter({ insertedIndex in
                    return insertedIndex.section == oldIndex.section && insertedIndex.row < newIndex.row
                }).count

                return (oldIndex, IndexPath(item: newIndex.row - movedDownBy, section: newIndex.section))
            }
        }

        // remove items that became the same
        newMovedIndexes.removeAll()
        for i in 0 ..< movedIndexes.count {
            let movedIndex = movedIndexes[i]
            if movedIndex.0 != movedIndex.1 {
                newMovedIndexes.append(originalMoveIndexes[i])
            }
        }

        movedIndexes = newMovedIndexes

        return movedIndexes
    }

    private func findInsertedItems(
            oldItems: [ACellModelType], newItems: [ACellModelType], newSections: [ASectionModelType]) -> [IndexPath] {
        var insertedItemIndexesNew = [IndexPath]()

        // let's find new elements
        for newIndex in 0 ..< newItems.count {
            let newItem = newItems[newIndex]
            let newIndexPath = indexPath(forItemIndex: newIndex, usingSections: newSections)!

            if oldItems.index(of: newItem) == nil {
                insertedItemIndexesNew.append(newIndexPath)
            }
        }

        return insertedItemIndexesNew
    }

    private func findDeletedUpdatedMovedItems(oldItems: [ACellModelType], oldSections: [ASectionModelType],
            newItems: [ACellModelType], newSections: [ASectionModelType]) -> ([IndexPath], [IndexPath], [(IndexPath, IndexPath)]) {
        var deletedItemIndexesOld = [IndexPath]()
        var updatedItemIndexesOld = [IndexPath]()
        var movedItemIndexesOldNew = [(IndexPath, IndexPath)]()

        // let's find item updates and deletions
        // ToDo: убрать все «!»
        for oldIndex in 0 ..< oldItems.count {
            let oldItem = oldItems[oldIndex]
            let oldIndexPath = indexPath(forItemIndex: oldIndex, usingSections: oldSections)!

            if let newIndex = newItems.index(of: oldItem) {
                let newIndexPath = indexPath(forItemIndex: newIndex, usingSections: newSections)!
                let newItem = newItems[newIndex]

                if !newItem.contentIsSameAsIn(oldItem) {
                    updatedItemIndexesOld.append(oldIndexPath)
                }

                if newIndexPath != oldIndexPath {
                    movedItemIndexesOldNew.append((oldIndexPath, newIndexPath))
                }
            } else {
                deletedItemIndexesOld.append(oldIndexPath)
            }
        }

        return (deletedItemIndexesOld, updatedItemIndexesOld, movedItemIndexesOldNew)
    }

    private func findUpdatedSections(old oldSections: [ASectionModelType], new newSections: [ASectionModelType]) -> IndexSet {
        let result = NSMutableIndexSet()

        for newIndex in 0 ..< newSections.count {
            if newIndex < oldSections.count {
                if newSections[newIndex] != oldSections[newIndex] {
                    result.add(newIndex)
                }
            }
        }

        return result as IndexSet
    }

    private func findInsertedSectionsTo(_ sectionsData: [ASectionModelType],
                                byInsertedIndexes insertedIndexes: [IndexPath],
                                movedIndexes: [(IndexPath, IndexPath)]) -> IndexSet {
        let result = NSMutableIndexSet()

        for insertedIndex in insertedIndexes {
            if insertedIndex.section >= sectionsData.count {
                result.add(insertedIndex.section)
            }
        }

        for (_, toIndexNew) in movedIndexes {
            if toIndexNew.section >= sectionsData.count {
                result.add(toIndexNew.section)
            }
        }

        return result as IndexSet
    }

    private func findTotallyDestroyedSectionsFrom(_ sectionsData: [ASectionModelType],
                                          byDeletedIndexes deletedIndexes: [IndexPath],
                                          insertedIndexes: [IndexPath],
                                          movedIndexes: [(IndexPath, IndexPath)]) -> IndexSet {
        let result = NSMutableIndexSet()

        for sectionIndex in 0 ..< sectionsData.count {
            let section = sectionsData[sectionIndex]
            let insertedItemsCount = insertedIndexes.filter({ $0.section == sectionIndex }).count
            let deletedItemsCount = deletedIndexes.filter({ $0.section == sectionIndex }).count
            let movedOutItemsCount = movedIndexes.filter({ $0.0.section == sectionIndex && $0.1.section != sectionIndex }).count
            let movedInItemsCount = movedIndexes.filter({ $0.1.section == sectionIndex && $0.0.section != sectionIndex }).count

            if section.endIndex - section.startIndex == deletedItemsCount + movedOutItemsCount &&
                       movedInItemsCount + insertedItemsCount == 0 {
                result.add(sectionIndex)
            }
        }

        return result as IndexSet
    }

    // MARK: Private helper methods

    private func indexPath(forItemIndex itemIndex: Int, usingSections: [ASectionModelType]) -> IndexPath? {
        var result: IndexPath? = nil

        var sectionIndex = 0
        for section in usingSections {
            if section.startIndex <= itemIndex && section.endIndex > itemIndex {
                result = IndexPath(row: itemIndex - section.startIndex, section: sectionIndex)
                break
            }

            sectionIndex += 1
        }

        return result
    }

    private func sections(fromItems items: [ACellModelType]) -> [ASectionModelType] {
        var result: [ASectionModelType] = []

        if let firstItem = items.first {
            var currentSectionItem: ACellModelType = firstItem
            var currentSectionStartIndex = 0
            var currentSectionEndIndex = 1

            for item in items.suffix(items.count - 1) {
                currentSectionEndIndex += 1

                if !cellSectionFactory.cellsHaveSameSection(one: currentSectionItem, another: item) {
                    let section = cellSectionFactory.createSection(forCell: currentSectionItem)
                    section.update(startIndex: currentSectionStartIndex, endIndex: currentSectionEndIndex - 1)

                    result.append(section)

                    currentSectionItem = item
                    currentSectionStartIndex = currentSectionEndIndex - 1
                }
            }

            if currentSectionStartIndex != currentSectionEndIndex {
                let section = cellSectionFactory.createSection(forCell: currentSectionItem)
                section.update(startIndex: currentSectionStartIndex, endIndex: currentSectionEndIndex)

                result.append(section)
            }
        }

        return result
    }

    // MARK: - Some debug output methods

    private func debugPrint(name: String, strings: [String]) -> String {
        if strings.isEmpty {
            return "—"
        } else {
            let separator = strings.count < 50 ? ", " : ",\n  "
            var prefix = strings.count < 50 ? " " : "\n  "
            var suffix = strings.count < 50 ? "" : "\n"
            var nameColon = "\(name): "

            if name.isEmpty {
                prefix = ""
                suffix = ""
                nameColon = ""
            }

            return "[\(nameColon)\(prefix)\(strings.joined(separator: separator))\(suffix)]"
        }
    }

    private func debugPrint(_ indexSet: IndexSet) -> String {
        return debugPrint(name: "indexes", strings: indexSet.map { "\($0)" })
    }

    private func debugPrint(_ indexPaths: [IndexPath]) -> String {
        return debugPrint(name: "indexPaths", strings: indexPaths.map { "\($0.section)-\($0.row)" })
    }

    private func debugPrint(_ indexPathPairs: [(IndexPath, IndexPath)]) -> String {
        return debugPrint(name: "indexPathPairs", strings: indexPathPairs.map {
            "\($0.0.section)-\($0.0.row) -> \($0.1.section)-\($0.1.row)"
        })
    }

    private func debugPrint(_ indexPathPairs: [(Int, Int)]) -> String {
        return debugPrint(name: "indexPairs", strings: indexPathPairs.map { "\($0.0) -> \($0.1)" })
    }

    private func debugPrint(_ cells: [ACellModelType]) -> String {
        return debugPrint(name: "", strings: cells.map { "\($0)" })
    }

    private func debugPrint(_ sections: [ASectionModelType]) -> String {
        return debugPrint(name: "", strings: sections.map { "\($0)" })
    }
}
