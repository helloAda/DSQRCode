//
//  ScanViewController.m
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/21.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import "ScanViewController.h"
#import "DSQRCodeManager.h"

@interface ScanViewController ()<DSQRCodeDelegate>

@property (nonatomic, strong) DSQRCodeManager *manager;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.manager.scanView startTimer];
}

- (DSQRCodeManager *)manager {
    if (!_manager) {
        _manager = [[DSQRCodeManager alloc] initWithScanViewRect:CGRectZero showView:self.view];
        _manager.delegate = self;
        //有需要设置在这里修改 类似
//        _manager.scanContinue = YES;//连续扫描
//        _manager.scanView.tipText = @"modify";
//        _manager.scanView.cornerColor = [UIColor yellowColor];
        [_manager startRunning];
    }
    return _manager;
}

- (void)scanQRCodeResultMetadataObject:(NSArray *)metadatas {
    NSLog(@"%@",metadatas);
    //若要连续扫描 则 在这里[_manager stopRunning] 然后在    [self performSelector:@selector(restart) withObject:nil afterDelay:间隔时间];
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)restart {
//    [_manager startRunning];
//}

- (void)viewDidDisappear:(BOOL)animated {
    [self.manager.scanView stopTimer];
}

@end
