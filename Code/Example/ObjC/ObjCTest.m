//
// Created by Alexander Babaev on 23.04.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

@import UIKit;
#import "ObjCTest.h"
#import "ATableAnimationCalculator-Swift.h"

@implementation ObjCTest {
}

- (void)test
{
    ATableAnimationCalculatorObjC *calculator = [[ATableAnimationCalculatorObjC alloc] init];
    [calculator setItems:@[
             [[ACellModelExampleObjC alloc] initWithText:@"1" header:@"A"],
             [[ACellModelExampleObjC alloc] initWithText:@"2" header:@"B"],
             [[ACellModelExampleObjC alloc] initWithText:@"3" header:@"B"],
             [[ACellModelExampleObjC alloc] initWithText:@"4" header:@"C"],
             [[ACellModelExampleObjC alloc] initWithText:@"5" header:@"C"],
    ] andApplyToTableView:[[UITableView alloc] init]];
}

@end
