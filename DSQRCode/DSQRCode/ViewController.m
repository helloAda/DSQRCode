//
//  ViewController.m
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/9.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import "ViewController.h"
#import "DSScanQRCodeView.h"
@interface ViewController ()<DSQRCodeDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    DSScanQRCodeView *view = [[DSScanQRCodeView alloc] initWithView:self.view];
    view.delegate = self;
    [self.view addSubview:view];

}


- (void)scanQRCodeResultMetadataObject:(NSArray *)metadatas {
    NSLog(@"%@",metadatas);
}


@end
