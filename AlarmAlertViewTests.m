//
//  AlarmAlertViewTests.m
//  AlarmAlertController
//
//  Created by Hao Zheng on 1/29/15.
//  Copyright (c) 2015 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AlarmAlertView.h"

@interface AlarmAlertViewTests : XCTestCase


@end

@implementation AlarmAlertViewTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    
}

#pragma mark - helpers

- (AlarmAlertView *)getNormalInstance
{
    return [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"Message"];
}

- (void)CheckTitleMessageSame:(AlarmAlertView *)alert
{
    XCTAssertEqual(alert.title, @"Title", @"title not same");
    XCTAssertEqual(alert.message, @"Message", @"Message not same");
}

#pragma mark - tests

- (void)testCallingMultipleShowOrDismiss
{
    //given
    AlarmAlertView *alert = [self getNormalInstance];
    //when
    [alert show];
    NSString *title1 = alert.title;
    [alert show];
    NSString *title2 = alert.title;
    //then
    XCTAssertEqualObjects(title1, title2, @"call multiple show should reuse its instantiated properties");
    [alert dismiss];
    XCTAssertNoThrow([alert dismiss],@"should call multiple dismiss even dismissed");
}

- (void)testEmptyParameter
{
    AlarmAlertView *alert = [[AlarmAlertView alloc] initWithTitle:nil message:nil];
    XCTAssertNoThrow([alert show], "parameters can all be nil.");
    XCTAssertNoThrow([alert dismiss], "parameters can all be nil.");
}

- (void)testOneButton_Cancel
{
    //given
    AlarmAlertView *alert = [self getNormalInstance];
    //when
    [alert addActionWithTitle:@"Cancel" style:AlertButtonCancel handler:^(AlarmAlertButtonItem *item) {
        
    }];
    [alert show];
    //then
    [self CheckTitleMessageSame:alert];
    AlarmAlertButtonItem *item = (AlarmAlertButtonItem *)alert.buttonItems[0];
    XCTAssertEqual(item.buttonTitle.string, @"Cancel", @"button title not Cancel");
    XCTAssertEqual(alert.buttonItems.count, 1, @"button should be only one");
    XCTAssertNoThrow([alert dismiss], "should dismiss.");
}

- (void)testTwoButtons_leftRight
{
    //given
    AlarmAlertView *alert = [self getNormalInstance];
    //when
    [alert addActionWithTitle:@"Cancel" style:AlertButtonCancel handler:nil];
    [alert addActionWithTitle:@"OK" style:AlertButtonCancel handler:nil];
    [alert show];
    //then
    [self CheckTitleMessageSame:alert];
    XCTAssertEqual(alert.buttonItems.count, 2, @"button should be only one");
    XCTAssertNoThrow([alert dismiss], "should dismiss.");
}

- (void)testTwoButtons_upDown
{
    //given
    AlarmAlertView *alert = [self getNormalInstance];
    //alert.theme.ifTwoBtnsShouldInOneLine = NO;
    //when
    [alert addActionWithTitle:@"Cancel" style:AlertButtonCancel handler:nil];
    [alert addActionWithTitle:@"Today is a good day." style:AlertButtonStyleDefault handler:nil];
    [alert show];
    //then
    [self CheckTitleMessageSame:alert];
    XCTAssertEqual(alert.buttonItems.count, 2, @"button should be only one");
    AlarmAlertButtonItem *item = (AlarmAlertButtonItem *)alert.buttonItems[1];
    XCTAssertEqual(item.buttonTitle.string, @"Cancel", @"if any text is long than 14,\
                   should have up-down style and cancel at the bottom");
    XCTAssertNoThrow([alert dismiss], "should dismiss.");
}

- (void)testMultiplebuttons_centerStyle
{
    //given
    AlarmAlertView *alert = [self getNormalInstance];
    //when
    [alert addActionWithTitle:@"Hello" style:AlertButtonStyleDefault handler:nil];
    [alert addActionWithTitle:@"Good" style:AlertButtonStyleDefault handler:nil];
    [alert addActionWithTitle:@"Today is a good day." style:AlertButtonStyleDefault handler:nil];
    [alert addActionWithTitle:@"Cancel" style:AlertButtonCancel handler:nil];
    [alert show];
    //then
    [self CheckTitleMessageSame:alert];
    AlarmAlertButtonItem *item = (AlarmAlertButtonItem *)alert.buttonItems[1];
    XCTAssertEqual(item.buttonTitle.string, @"Good", @"button title not Good");
    XCTAssertEqual(alert.buttonItems.count, 4, @"button should be only one");
    XCTAssertNoThrow([alert dismiss], "should dismiss.");
}

- (void)testMultiplebuttons_actionSheetStyle
{
    //given
    AlarmAlertView *alert = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"Message" preferredStyle:AAActionSheet];
    //when
    [alert addActionWithTitle:@"Good" style:AlertButtonStyleDefault handler:nil];
    [alert addActionWithTitle:@"Today is a good day." style:AlertButtonStyleDefault handler:nil];
    [alert addActionWithTitle:@"Cancel" style:AlertButtonCancel handler:^(AlarmAlertButtonItem *item) {
        
    }];
    [alert show];
    //then
    [self CheckTitleMessageSame:alert];
    AlarmAlertButtonItem *item = (AlarmAlertButtonItem *)alert.buttonItems[0];
    XCTAssertEqual(item.buttonTitle.string, @"Good", @"button title not Good");
    XCTAssertEqual(alert.buttonItems.count, 3, @"button should be only one");
    XCTAssertNoThrow([alert dismiss], "should dismiss.");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
