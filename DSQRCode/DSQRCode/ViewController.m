//
//  ViewController.m
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/9.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *scan = [[UIButton alloc] initWithFrame:CGRectMake(125, 300, 100, 30)];
    [scan setTitle:@"扫描" forState:UIControlStateNormal];
    [scan setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [scan addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scan];
    
    UIButton *photo = [[UIButton alloc] initWithFrame:CGRectMake(125, 400, 100, 30)];
    [photo setTitle:@"相册" forState:UIControlStateNormal];
    [photo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [photo addTarget:self action:@selector(photo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photo];
}


- (void)scan {
    
    ScanViewController *vc = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)photo {
    NSLog(@"由于最近较忙，相册暂时没有开始。");
}
@end
