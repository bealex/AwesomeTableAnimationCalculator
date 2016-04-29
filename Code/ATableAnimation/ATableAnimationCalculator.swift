//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation

//MARK: Some helper extensions

private extension ASectionModelProtocol {
    var range:Range<Int> {
        get {
            return Range<Int>(startIndex ..< endIndex)
        }
    }
}

internal extension ASectionModelProtocol {
    func update(startIndex startIndex:Int, endIndex:Int) {
    }
}

public extension ASectionModel {
    public func update(startIndex startIndex:Int, endIndex:Int) {
        self.startIndex = startIndex
        self.endIndex = endIndex
    }
}

public extension ASectionModelObjC {
    public func update(startIndex startIndex:Int, endIndex:Int) {
        self.startIndex = startIndex
        self.endIndex = endIndex
    }
}

//MARK: Calculator class

/**
 This class can tell you, which sections and/or items must
 be updated (inserted, deleted) during DataSource update.

 It must solve common problem with complex CollectionViews, when new cells
 can appear/disappear/change in different places. Examples include chat messages,
 moderated comments list etc.

 Public interface is built for easy usage with standard `UICollectionView` or `UITableView`.
 */
public class ATableAnimationCalculator<ACellSectionModelType:ACellSectionModel>: NSObject {
    private let cellSectionFactory:ACellSectionModelType
    private typealias ACellModelType = ACellSectionModelType.ACellModelType
    private typealias ASectionModelType = ACellSectionModelType.ASectionModelType

    public private(set) var items:[ACellModelType] = []
    public private(set) var sections:[ASectionModelType] = []

    public lazy var cellModelComparator:(ACellModelType, ACellModelType) -> Bool = { left, right in
        let indexLeft = self.items.indexOf(left)
        let indexRight = self.items.indexOf(right)

        return indexLeft < indexRight
    }

    public init(cellSectionModel:ACellSectionModelType) {
        self.cellSectionFactory = cellSectionModel
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
    func section(withIndex sectionIndex:Int) -> ASectionModelType {
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
        return try setItems(items)
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

    func removeItem(withIndex indexPath:NSIndexPath) throws -> ATableDiff {
        var itemsToProcess = Array<ACellModelType>(items)
        itemsToProcess.removeAtIndex(section(withIndex:indexPath.section).startIndex + indexPath.row)
        return try setItems(itemsToProcess)
    }

    func swapItems(withIndex sourceIndexPath:NSIndexPath, toIndex destinationIndexPath:NSIndexPath) throws -> ATableDiff {
        var itemsToProcess = Array<ACellModelType>(items)

        let sourceIndex = section(withIndex:sourceIndexPath.section).startIndex + sourceIndexPath.row
        let destinationIndex = section(withIndex:destinationIndexPath.section).startIndex + destinationIndexPath.row

        let tmpValue = itemsToProcess.removeAtIndex(sourceIndex)
        itemsToProcess.insert(tmpValue, atIndex:destinationIndex)

        items = itemsToProcess

        return ATableDiff(
                updatedPaths:[],
                updatedSectionHeaders:NSIndexSet(),

                deletedPaths:[],
                deletedSections:NSIndexSet(),

                addedPaths:[],
                addedSections:NSIndexSet(),

                movedSections:[],
                movedPaths:[(sourceIndexPath, destinationIndexPath)]
        )
    }
}

//MARK: Private methods for finding lists difference
private extension ATableAnimationCalculator {
    private var DEBUG_ENABLED: Bool {
        return true
    }

    func calculateDiff(items newShinyItems:[ACellModelType]) throws -> ATableDiff {
        let newItems = newShinyItems.map({ ACellModelType(copy:$0) }).sort(cellModelComparator)
        let newSections:[ASectionModelType] = sections(fromItems:newItems)

        let numberOfUniqueSections = newSections
                .map({ section in
                    return newSections.filter({ $0 == section }).count == 1 ? 1 : 0
                })
                .reduce(0, combine: { result, value in result + value });

        if numberOfUniqueSections != newSections.count {
            throw NSError(domain:"ATableAnimationCalculator", code:1, userInfo:[NSLocalizedDescriptionKey: "Your data does have two same sections in the list. Possibly you forgot to setup comparator for the cells."])
        }

        let oldItems = items
        let oldSections = sections

        if DEBUG_ENABLED {
            print("Old: \(debugPrint(oldItems)) | \(debugPrint(oldSections))");
            print("New: \(debugPrint(newItems)) | \(debugPrint(newSections))\n");
        }

        var deletedItemIndexesOld = [NSIndexPath]()
        var updatedItemIndexesOld = [NSIndexPath]()
        var insertedItemIndexesNew = [NSIndexPath]()
        var movedItemIndexesOldNew = [(NSIndexPath, NSIndexPath)]()

        // найдем удаления перемещения и обновления
        //ToDo: убрать все «!»
        for oldIndex in 0 ..< oldItems.count {
            let oldItem = oldItems[oldIndex]
            let oldIndexPath = indexPath(forItemIndex:oldIndex, usingSections:oldSections)!

            if let newIndex = newItems.indexOf(oldItem) {
                let newIndexPath = indexPath(forItemIndex:newIndex, usingSections:newSections)!
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

        // найдем новые элементы
        for newIndex in 0 ..< newItems.count {
            let newItem = newItems[newIndex]
            let newIndexPath = indexPath(forItemIndex:newIndex, usingSections:newSections)!

            if oldItems.indexOf(newItem) == nil {
                insertedItemIndexesNew.append(newIndexPath)
            }
        }

        // почистим апдейты от тех, которые перемещаются
        updatedItemIndexesOld = updatedItemIndexesOld.filter { updateIndex in
            return movedItemIndexesOldNew.filter({ $0.0 == updateIndex || $0.1 == updateIndex }).isEmpty
        }

        if DEBUG_ENABLED {
            print("- Index Paths (before section calculations):");
            print("Deleted: \(debugPrint(deletedItemIndexesOld))");
            print("Updated: \(debugPrint(updatedItemIndexesOld))");
            print("Inserted: \(debugPrint(insertedItemIndexesNew))");
            print("Moved: \(debugPrint(movedItemIndexesOldNew))");
        }

        // найдем уничтоженные секции
        let deletedSectionIndexesOld = findTotallyDestroyedSectionsFrom(oldSections, byDeletedIndexes:deletedItemIndexesOld, insertedIndexes:insertedItemIndexesNew, movedIndexes:movedItemIndexesOldNew)
        deletedItemIndexesOld = deletedItemIndexesOld.filter { !deletedSectionIndexesOld.contains($0.section) }

        // если секция уничтожена, то переместить из нее не можем
        let movedItemIndexesOldNewFromDestroyedSections = movedItemIndexesOldNew.filter { deletedSectionIndexesOld.contains($0.0.section) }
        insertedItemIndexesNew.appendContentsOf(movedItemIndexesOldNewFromDestroyedSections.map { $0.1 })
        movedItemIndexesOldNew = movedItemIndexesOldNew.filter { !deletedSectionIndexesOld.contains($0.0.section) }

        // найдем добавленные секции
        let insertedSectionIndexesNew = findInsertedSectionsTo(oldSections, byInsertedIndexes:insertedItemIndexesNew, movedIndexes:movedItemIndexesOldNew)

        // если секция добавлена, то переместить в нее не можем
        let movedItemIndexesOldNewToInsertedSections = movedItemIndexesOldNew.filter { insertedSectionIndexesNew.contains($0.1.section) }
        deletedItemIndexesOld.appendContentsOf(movedItemIndexesOldNewToInsertedSections.map { $0.0 })
        movedItemIndexesOldNew = movedItemIndexesOldNew.filter { !insertedSectionIndexesNew.contains($0.1.section) }

        let updatedSectionIndexesNew = findUpdatedSections(old:oldSections, new:newSections)

        if DEBUG_ENABLED {
            print("\n");
            print("- Index Paths (after section calculations):");
            print("Deleted: \(debugPrint(deletedItemIndexesOld))");
            print("Updated: \(debugPrint(updatedItemIndexesOld))");
            print("Inserted: \(debugPrint(insertedItemIndexesNew))");
            print("Moved: \(debugPrint(movedItemIndexesOldNew))");

            print("- Section Indexes:");
            print("Deleted: \(debugPrint(deletedSectionIndexesOld))");
            print("Updated: \(debugPrint(updatedSectionIndexesNew))");
            print("Inserted: \(debugPrint(insertedSectionIndexesNew))");
//            print("Moved: \(debugPrint(movedItemIndexesOldNew))");
        }

        let movedSectionIndexes = [(Int, Int)]()

        items = newItems
        sections = newSections

        return ATableDiff(
            updatedPaths:updatedItemIndexesOld,
            updatedSectionHeaders: updatedSectionIndexesNew,

            deletedPaths:deletedItemIndexesOld,
            deletedSections: deletedSectionIndexesOld,

            addedPaths:insertedItemIndexesNew,
            addedSections:insertedSectionIndexesNew,

            movedSections:movedSectionIndexes,
            movedPaths:movedItemIndexesOldNew
        )
    }

    func findUpdatedSections(old oldSections:[ASectionModelType], new newSections:[ASectionModelType]) -> NSIndexSet {
        let result = NSMutableIndexSet()

        for newIndex in 0 ..< newSections.count {
            if newIndex < oldSections.count {
                if newSections[newIndex] != oldSections[newIndex] {
                    result.addIndex(newIndex)
                }
            }
        }

        return result
    }

    func findInsertedSectionsTo(sectionsData:[ASectionModelType], byInsertedIndexes insertedIndexes:[NSIndexPath], movedIndexes:[(NSIndexPath, NSIndexPath)]) -> NSIndexSet {
        let result = NSMutableIndexSet()

        for insertedIndex in insertedIndexes {
            if insertedIndex.section >= sectionsData.count {
                result.addIndex(insertedIndex.section)
            }
        }

        for (_, toIndexNew) in movedIndexes {
            if toIndexNew.section >= sectionsData.count {
                result.addIndex(toIndexNew.section)
            }
        }

        return result
    }

    func findTotallyDestroyedSectionsFrom(sectionsData:[ASectionModelType], byDeletedIndexes deletedIndexes:[NSIndexPath], insertedIndexes:[NSIndexPath], movedIndexes:[(NSIndexPath, NSIndexPath)]) -> NSIndexSet {
        let result = NSMutableIndexSet()

        for sectionIndex in 0 ..< sectionsData.count {
            let section = sectionsData[sectionIndex]
            let insertedItemsCount = insertedIndexes.filter({ $0.section == sectionIndex }).count
            let deletedItemsCount = deletedIndexes.filter({ $0.section == sectionIndex }).count
            let movedOutItemsCount = movedIndexes.filter({ $0.0.section == sectionIndex && $0.1.section != sectionIndex }).count
            let movedInItemsCount = movedIndexes.filter({ $0.1.section == sectionIndex && $0.0.section != sectionIndex }).count

            if section.endIndex - section.startIndex == deletedItemsCount + movedOutItemsCount && movedInItemsCount + insertedItemsCount == 0 {
                result.addIndex(sectionIndex)
            }
        }

        return result
    }
}

//MARK: Private helper methods
private extension ATableAnimationCalculator {
    func indexPath(forItemIndex itemIndex:Int, usingSections:[ASectionModelType]) -> NSIndexPath? {
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

    func sections(fromItems items:[ACellModelType]) -> [ASectionModelType] {
        var result:[ASectionModelType] = []

        if let firstItem = items.first {
            var currentSectionItem: ACellModelType = firstItem
            var currentSectionStartIndex = 0
            var currentSectionEndIndex = 1

            for item in items.suffix(items.count - 1) {
                currentSectionEndIndex += 1

                if !cellSectionFactory.cellsHaveSameSection(one:currentSectionItem, another:item) {
                    let section = cellSectionFactory.createSection(forCell:currentSectionItem)
                    section.update(startIndex:currentSectionStartIndex, endIndex:currentSectionEndIndex - 1)

                    result.append(section)

                    currentSectionItem = item
                    currentSectionStartIndex = currentSectionEndIndex - 1
                }
            }

            if currentSectionStartIndex != currentSectionEndIndex {
                let section = cellSectionFactory.createSection(forCell:currentSectionItem)
                section.update(startIndex:currentSectionStartIndex, endIndex:currentSectionEndIndex)

                result.append(section)
            }
        }

        return result
    }
}

//MARK: Some debug output methods
private extension ATableAnimationCalculator {
    func debugPrint(name name:String, strings:[String]) -> String {
        if strings.isEmpty {
            return "—"
        } else {
            let separator = strings.count < 50 ? ", " : ",\n  "
            var prefix = strings.count < 50 ? " " : "\n  "
            var suffix = strings.count < 50 ? "" : "\n"
            var nameColon = "\(name):"

            if name.isEmpty {
                prefix = ""
                suffix = ""
                nameColon = ""
            }

            return "[\(nameColon)\(prefix)\(strings.joinWithSeparator(separator))\(suffix)]"
        }
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

    func debugPrint(cells:[ACellModelType]) -> String {
        return debugPrint(name:"", strings:cells.map { "\($0)" })
//        return debugPrint(name:"", strings:cells.map { "\($0.shortDescription())" })
    }

    func debugPrint(sections:[ASectionModelType]) -> String {
        return debugPrint(name:"", strings:sections.map { "\($0)" })
    }
}