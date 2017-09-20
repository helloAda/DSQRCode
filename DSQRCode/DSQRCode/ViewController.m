//
//  ViewController.m
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/9.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import "ViewController.h"
#import "DSQRCodeManager.h"
@interface ViewController ()<DSQRCodeDelegate>

@property (nonatomic, strong) DSQRCodeManager *manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

- (DSQRCodeManager *)manager {
    if (!_manager) {
        _manager = [[DSQRCodeManager alloc] initWithScanViewRect:CGRectZero showView:self.view];
        _manager.delegate = self;
        [_manager startRunning];
    }
    return _manager;
}

- (void)scanQRCodeResultMetadataObject:(NSArray *)metadatas {
    NSLog(@"%@",metadatas);
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.manager.scanView stopTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.manager.scanView startTimer];
}


@end
