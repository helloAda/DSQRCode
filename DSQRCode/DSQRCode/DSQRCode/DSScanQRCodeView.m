//
//  DSScanQRCodeView.m
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/9.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import "DSScanQRCodeView.h"


@interface DSScanQRCodeView ()

@property (nonatomic, assign) CGFloat defaultScanX;
@property (nonatomic, assign) CGFloat defaultScanY;
@property (nonatomic, assign) CGFloat defaultScanW;
@property (nonatomic, assign) CGFloat defaultScanH;

@end
@implementation DSScanQRCodeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
    }
    
    return self;
    
}

- (void)initView {
    
    self.backgroundColor = [UIColor clearColor];
    _scanBorderLineWidth = 1;
    _cornerWidth = 20;
    _cornerLineWidth = 4;
    _cornerColor = [UIColor colorWithRed:85/255.0f green:183/255.0 blue:55/255.0 alpha:1.0];
    if (self.frame.size.height > self.frame.size.width) {
        _defaultScanW = self.frame.size.width * 0.7;
        _defaultScanH = _defaultScanW;
        _defaultScanX = self.frame.size.width * 0.15;
        _defaultScanY = (self.frame.size.height - _defaultScanW) / 2;
    }
    else {
        _defaultScanW = self.frame.size.height * 0.7;
        _defaultScanH = _defaultScanW;
        _defaultScanX = self.frame.size.height * 0.15;
        _defaultScanY = (self.frame.size.width - _defaultScanW) / 2;
    }
}

- (void)drawRect:(CGRect)rect {
    
    if (CGRectEqualToRect(_scanRect,CGRectNull)) {
        
    }
    
    //扫描框
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(_defaultScanX , _defaultScanY, _defaultScanW, _defaultScanH)];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.lineWidth = _scanBorderLineWidth;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:layer];
    
    //右上角
    [self initCorner:CGRectMake(_defaultScanX + _defaultScanW - _cornerWidth - (_cornerLineWidth - _scanBorderLineWidth) / 2, _defaultScanY + (_cornerLineWidth - _scanBorderLineWidth) / 2, _cornerWidth, _cornerWidth) start:0 end:0.5];
    //右下角
    [self initCorner:CGRectMake(_defaultScanX + _defaultScanW - _cornerWidth - (_cornerLineWidth - _scanBorderLineWidth) / 2, _defaultScanY + _defaultScanH - _cornerWidth - (_cornerLineWidth - _scanBorderLineWidth) / 2, _cornerWidth, _cornerWidth) start:0.25 end:0.75];
    //左下角
    [self initCorner:CGRectMake(_defaultScanX + (_cornerLineWidth - _scanBorderLineWidth) / 2, _defaultScanY + _defaultScanH - _cornerWidth - (_cornerLineWidth - _scanBorderLineWidth) / 2, _cornerWidth, _cornerWidth) start:0.5 end:1];
}

- (void)initCorner:(CGRect)rect start:(CGFloat)start end:(CGFloat)end{
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    path.lineCapStyle = kCGLineCapRound;
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = _cornerColor.CGColor;
    layer.lineWidth = _cornerLineWidth;
    layer.strokeStart = start;
    layer.strokeEnd = end;
    [self.layer addSublayer:layer];
}

@end
