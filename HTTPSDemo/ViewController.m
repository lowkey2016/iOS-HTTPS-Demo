//
//  ViewController.m
//  HTTPSDemo
//
//  Created by Jymn_Chen on 2017/1/23.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "ViewController.h"
#import "DMURLConnection.h"
#import "DMURLSession.h"
#import "DMAFSession.h"

@interface ViewController ()

@property (nonatomic, strong) id<DMAPI> api;

@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Button Actions

- (IBAction)connAction:(id)sender {
    self.api = [DMURLConnection new];
    [_api login];
}

- (IBAction)sessAction:(id)sender {
    self.api = [DMURLSession new];
    [_api login];
}

- (IBAction)afSessAction:(id)sender {
    self.api = [DMAFSession new];
    [_api login];
}

- (IBAction)redirectAction:(id)sender {
    self.api = [DMURLConnection new];
    [_api tryRedirect];
}

@end
