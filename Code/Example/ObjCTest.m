//
// Created by Alexander Babaev on 23.04.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

#import "ObjCTest.h"
#import "ATableAnimationCalculator-Swift.h"

@implementation ObjCTest {
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        ATableAnimationCalculatorObjC *calculator = [[ATableAnimationCalculatorObjC alloc] init];
//        try! dataStorage.setItems([
//                ACellModelExample(text: "1", header: "A"),
//        ACellModelExample(text: "2", header: "B"),
//        ACellModelExample(text: "3", header: "B"),
//        ACellModelExample(text: "4", header: "C"),
//        ACellModelExample(text: "5", header: "C")
//        ])
        [calculator setItems:@[
                 [[ACellModelExample alloc] initWithText:@"1" header:@"A"],
                 [[ACellModelExample alloc] initWithText:@"2" header:@"B"],
                 [[ACellModelExample alloc] initWithText:@"3" header:@"B"],
                 [[ACellModelExample alloc] initWithText:@"4" header:@"C"],
                 [[ACellModelExample alloc] initWithText:@"5" header:@"C"],
        ] andApplyToTableView:[[UITableView alloc] init]];
    }

    return self;
}

@end