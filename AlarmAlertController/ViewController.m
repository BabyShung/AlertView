//
//  ViewController.m
//  AlarmAlertController
//
//  Created by Hao Zheng on 1/14/15.
//  Copyright (c) 2015 Hao Zheng. All rights reserved.
//

#import "ViewController.h"
#import "AlarmAlertView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)onebutton:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"hello babe"];
    [al addActionWithTitle:@"Cancel" style:AlertButtonDestructive handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"aaaa");
    }];
    [al show];
}

- (IBAction)click:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"hello babe"];
    [al addActionWithTitle:@"Cancel" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"aaaa");
    }];
    [al addActionWithTitle:@"OK"];
    [al show];
}

- (IBAction)multiButtons:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"hello babe"];
    [al addActionWithTitle:@"What" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"bbb");
    }];
    [al addActionWithTitle:@"OK"];
    [al addActionWithTitle:@"OK2"];
    [al addActionWithTitle:@"Cancel" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"aaaa");
    }];

    [al show];
}

- (IBAction)actionSheet:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"hello babe" preferredStyle:AAActionSheet];
    [al addActionWithTitle:@"What" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"bbb");
    }];
    [al addActionWithTitle:@"OK"];
    [al addActionWithTitle:@"OK2"];
    [al show];
}

- (IBAction)appleDefault:(id)sender {
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Title" message:@"Message" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [al show];
}
@end
