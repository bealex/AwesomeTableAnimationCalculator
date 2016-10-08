//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import UIKit
import AwesomeTableAnimationCalculator

class ViewControllerTable: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView: UITableView = UITableView(frame: .zero, style: UITableViewStyle.plain)
    let calculator = ATableAnimationCalculator(cellSectionModel: ACellSectionModelExample())

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        calculator.cellModelComparator = { lhs, rhs in
            if lhs.header < rhs.header {
                return true
            } else {
                if lhs.header > rhs.header {
                    return false
                } else {
                    return lhs.text < rhs.text
                }
            }
        }

        self.view.backgroundColor = .white

        tableView.backgroundColor = .clear

        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.alwaysBounceVertical = true

        tableView.dataSource = self
        tableView.delegate = self

        self.view.addSubview(tableView)

        initData()
        startTest()

//        enableEditing()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Random", style: .plain,
//                target: self, action: #selector(addRandomTapped))
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return calculator.sectionsCount()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculator.itemsCount(inSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "generalCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "generalCell")
        }
        cell!.textLabel!.text = calculator.item(forIndexPath: indexPath).text
        return cell!
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionData = calculator.section(withIndex: section)
        return "Header: \(sectionData.title)"
    }

    // MARK: - Updater

    func update(items addedItems: [ACellModelExample], updateItemsWithIndexes: [Int], deleteItemsWithIndexes: [Int]) {
        var updatedItems: [ACellModelExample] = updateItemsWithIndexes.map { index in
            let updatedValue = ACellModelExample(copy: self.calculator.item(withIndex: index))
            updatedValue.text = updatedValue.text + " •"

            return updatedValue
        }

        let deletedItems = deleteItemsWithIndexes.map { index in
            return self.calculator.item(withIndex: index)
        }

        updatedItems.append(contentsOf: addedItems)

        print("\n\n\n--------------------------------------------- Updated: ")
        print("  " + updatedItems.map({ $0.debugDescription }).joined(separator: "\n  "))
        print("--------------------------------------------- Deleted: ")
        print("  " + deletedItems.map({ $0.debugDescription }).joined(separator: ",\n  "))
        print("--------------------------------------------- Changes: ")

        let itemsToAnimate = try! calculator.updateItems(addOrUpdate: updatedItems, delete: deletedItems)

        print("--------------------------------------------- NewItems: ")
        print("  " + calculator.items.map({ $0.debugDescription }).joined(separator: ",\n  "))
        print("---------------------------------------------\n\n")

        itemsToAnimate.applyTo(tableView: tableView)
    }

    func initData() {
        let _ = try! calculator.setItems([
                ACellModelExample(text: "1", header: "A"),
                ACellModelExample(text: "2", header: "A"),
                ACellModelExample(text: "3", header: "A"),
                ACellModelExample(text: "4", header: "A"),
                ACellModelExample(text: "5", header: "A")
        ])

        print("--------------------------------------------- NewItems: ")
        print("  " + calculator.items.map({ $0.debugDescription }).joined(separator: ",\n  "))
        print("---------------------------------------------\n\n")

        tableView.reloadData()
    }

    func startTest() {
        let dTime: TimeInterval = 1

        var time = TimeInterval(dTime)
        dispatch_after_main(time) {
            self.update(
                    items: [
                            ACellModelExample(text: "6", header: "A")
                    ],
                    updateItemsWithIndexes: [2],
                    deleteItemsWithIndexes: [])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items: [],
                    updateItemsWithIndexes: [],
                    deleteItemsWithIndexes: [1])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items: [
                            ACellModelExample(text: "10", header: "C"),
                            ACellModelExample(text: "7", header: "D")
                    ],
                    updateItemsWithIndexes: [1],
                    deleteItemsWithIndexes: [])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items: [],
                    updateItemsWithIndexes: [],
                    deleteItemsWithIndexes: [0, 4])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items: [
                            ACellModelExample(text: "8", header: "A"),
                            ACellModelExample(text: "9", header: "C")
                    ],
                    updateItemsWithIndexes: [0],
                    deleteItemsWithIndexes: [1])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items: [],
                    updateItemsWithIndexes: [0, 1, 2, 3, 4],
                    deleteItemsWithIndexes: [])
        }

        time += dTime
        dispatch_after_main(time) {
            self.calculator.cellModelComparator = { rhs, lhs in
                if lhs.header < rhs.header {
                    return true
                } else {
                    if lhs.header > rhs.header {
                        return false
                    } else {
                        return lhs.text < rhs.text
                    }
                }
            }

            print("••••••••••••••••••••••••••••••••••••• RESORTING all... :)")

            let itemsToAnimate = try! self.calculator.resortItems()

            print("--------------------------------------------- NewItems: ")
            print("  " + self.calculator.items.map({ $0.debugDescription }).joined(separator: ",\n  "))
            print("---------------------------------------------\n\n")

            itemsToAnimate.applyTo(tableView: self.tableView);
        }

        time += dTime
        dispatch_after_main(time) {
            let moved1 = ACellModelExample(copy: self.calculator.items[3])
            let moved2 = ACellModelExample(copy: self.calculator.items[0])

            moved1.header = "D"
            moved2.header = "A"

            print("••••••••••••••••••••••••••••••••••••• RESORTING between sections... :)")

            let itemsToAnimate = try! self.calculator.updateItems(addOrUpdate: [moved1, moved2], delete: [])

            print("--------------------------------------------- NewItems: ")
            print("  " + self.calculator.items.map({ $0.debugDescription }).joined(separator: ",\n  "))
            print("---------------------------------------------\n\n")

            itemsToAnimate.applyTo(tableView: self.tableView);
        }
    }

    // MARK: - TableView Delegate

    func enableEditing() {
        calculator.cellModelComparator = { lhs, rhs in
            return false
        }

        self.tableView.setEditing(true, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemsToAnimate = try! calculator.removeItem(withIndex: indexPath)
            itemsToAnimate.applyTo(tableView: self.tableView);

            print("\n\n\n--------------------------------------------- NewItems: ")
            print("  " + calculator.items.map({ $0.debugDescription }).joined(separator: ",\n  "))
            print("---------------------------------------------\n\n")
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemsToAnimate = try! calculator.swapItems(withIndex: sourceIndexPath, toIndex: destinationIndexPath)
        itemsToAnimate.applyTo(tableView: self.tableView);

        print("\n\n\n--------------------------------------------- NewItems: ")
        print("  " + calculator.items.map({ $0.debugDescription }).joined(separator: ",\n  "))
        print("---------------------------------------------\n\n")
    }

    func addRandomTapped(sender: AnyObject?) {
        let newIndex = Int(arc4random_uniform(UInt32(calculator.items.count)))
        let newIndexTitle = "\(newIndex) +"

        var newItems = calculator.items
        newItems.insert(ACellModelExample(text: newIndexTitle, header: "A"), at: newIndex)

        let itemsToAnimate = try! calculator.setItems(newItems)
        itemsToAnimate.applyTo(tableView: self.tableView);
    }
}
