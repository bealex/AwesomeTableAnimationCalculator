//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import UIKit
import AwesomeTableAnimationCalculator

class ViewControllerTable: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView:UITableView = UITableView(frame:CGRectZero, style:UITableViewStyle.Plain)
    let calculator = ATableAnimationCalculator(cellSectionModel: ACellSectionModelExample())

    override func prefersStatusBarHidden() -> Bool {
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
                    return Int(lhs.text) < Int(rhs.text)
                }
            }
        }

        self.view.backgroundColor = UIColor.whiteColor()

        tableView.backgroundColor = UIColor.clearColor()

        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.alwaysBounceVertical = true

        tableView.dataSource = self
        tableView.delegate = self

        self.view.addSubview(tableView)

        initData()
//        startTest()

        enableEditing()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return calculator.sectionsCount()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculator.itemsCount(inSection:section)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("generalCell")
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier:"generalCell")
        }
        cell!.textLabel!.text = calculator.item(forIndexPath:indexPath).text
        return cell!
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionData = calculator.section(withIndex:section)
        return "Header: \(sectionData.title)"
    }
}

extension ViewControllerTable {
    func update(items addedItems:[ACellModelExample], updateItemsWithIndexes:[Int], deleteItemsWithIndexes:[Int]) {
        var updatedItems:[ACellModelExample] = updateItemsWithIndexes.map { index in
            let updatedValue = ACellModelExample(copy:self.calculator.item(withIndex:index))
            updatedValue.text = updatedValue.text + " •"

            return updatedValue
        }

        let deletedItems = deleteItemsWithIndexes.map { index in
            return self.calculator.item(withIndex:index)
        }

        updatedItems.appendContentsOf(addedItems)

        print("\n\n\n--------------------------------------------- Updated:")
        print("  " + updatedItems.map({ $0.debugDescription }).joinWithSeparator("\n  "))
        print("--------------------------------------------- Deleted:")
        print("  " + deletedItems.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("--------------------------------------------- Changes:")

        let itemsToAnimate = try! calculator.updateItems(addOrUpdate:updatedItems, delete:deletedItems)

        print("--------------------------------------------- NewItems:")
        print("  " + calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("---------------------------------------------\n\n")

        itemsToAnimate.applyTo(tableView:tableView)
    }

    func initData() {
        try! calculator.setItems([
                ACellModelExample(text: "1", header: "A"),
                ACellModelExample(text: "2", header: "A"),
                ACellModelExample(text: "3", header: "A"),
                ACellModelExample(text: "4", header: "A"),
                ACellModelExample(text: "5", header: "A")
        ])

        print("--------------------------------------------- NewItems:")
        print("  " + calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("---------------------------------------------\n\n")

        tableView.reloadData()
    }

    func startTest() {
        let dTime:NSTimeInterval = 1

        var time = NSTimeInterval(dTime)
        dispatch_after_main(time) {
            self.update(
                    items:[
                            ACellModelExample(text:"6", header:"A")
                    ],
                    updateItemsWithIndexes:[2],
                    deleteItemsWithIndexes:[])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items:[],
                    updateItemsWithIndexes:[],
                    deleteItemsWithIndexes:[1])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items:[
                            ACellModelExample(text:"10", header:"C"),
                            ACellModelExample(text:"7", header:"D")
                    ],
                    updateItemsWithIndexes:[1],
                    deleteItemsWithIndexes:[])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items:[],
                    updateItemsWithIndexes:[],
                    deleteItemsWithIndexes:[0, 4])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items:[
                            ACellModelExample(text:"8", header:"A"),
                            ACellModelExample(text:"9", header:"C")
                    ],
                    updateItemsWithIndexes:[0],
                    deleteItemsWithIndexes:[1])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items:[],
                    updateItemsWithIndexes:[0, 1, 2, 3, 4],
                    deleteItemsWithIndexes:[])
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
                        return Int(lhs.text) < Int(rhs.text)
                    }
                }
            }

            print("••••••••••••••••••••••••••••••••••••• RESORTING all... :)")

            let itemsToAnimate = try! self.calculator.resortItems()

            print("--------------------------------------------- NewItems:")
            print("  " + self.calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
            print("---------------------------------------------\n\n")

            itemsToAnimate.applyTo(tableView:self.tableView);
        }

        time += dTime
        dispatch_after_main(time) {
            let moved1 = ACellModelExample(copy:self.calculator.items[3])
            let moved2 = ACellModelExample(copy:self.calculator.items[0])

            moved1.header = "D"
            moved2.header = "A"

            print("••••••••••••••••••••••••••••••••••••• RESORTING between sections... :)")

            let itemsToAnimate = try! self.calculator.updateItems(addOrUpdate:[moved1, moved2], delete:[])

            print("--------------------------------------------- NewItems:")
            print("  " + self.calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
            print("---------------------------------------------\n\n")

            itemsToAnimate.applyTo(tableView:self.tableView);
        }
    }
}

extension ViewControllerTable {
    func enableEditing() {
        calculator.cellModelComparator = { lhs, rhs in
            return false
        }

        self.tableView.setEditing(true, animated:true)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let itemsToAnimate = try! calculator.removeItem(withIndex:indexPath)
            itemsToAnimate.applyTo(tableView:self.tableView);

            print("\n\n\n--------------------------------------------- NewItems:")
            print("  " + calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
            print("---------------------------------------------\n\n")
        }
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let itemsToAnimate = try! calculator.swapItems(withIndex:sourceIndexPath, toIndex:destinationIndexPath)
        itemsToAnimate.applyTo(tableView:self.tableView);

        print("\n\n\n--------------------------------------------- NewItems:")
        print("  " + calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("---------------------------------------------\n\n")
    }
}
