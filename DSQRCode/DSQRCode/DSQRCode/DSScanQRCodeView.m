//
//  DSScanQRCodeView.m
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/9.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import "DSScanQRCodeView.h"
#import "DSQRCodeHelper.h"

@interface DSScanQRCodeView ()

@property (nonatomic, assign) CGRect scanRect;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIView *scanAnimationLine;
@property (nonatomic, strong) UIButton *flashBtn;

@end

@implementation DSScanQRCodeView

- (instancetype)initWithScanViewRect:(CGRect)rect showView:(UIView *)view {
    self = [super initWithFrame:view.frame];
    if (self) {
        _scanRect = rect;
        [self setting];
    }
    
    return self;
    
}

- (void)setting {
    
    self.backgroundColor = [UIColor clearColor];
    _scanBorderLineWidth = 1;
    _cornerWidth = 20;
    _cornerLineWidth = 4;
    _animateTime = 2;
    _scanAnimationLineHeight = 1;
    _cornerColor = [UIColor colorWithRed:85/255.0f green:183/255.0 blue:55/255.0 alpha:1.0];
    _scanAnimationLineColor = [UIColor colorWithRed:85/255.0f green:183/255.0 blue:55/255.0 alpha:1.0];
    _tipText = @"将二维码/条码放入框内，即可自动扫描";
    
}

- (void)drawRect:(CGRect)rect {
    
    _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashBtn setTitle:@"轻触照亮" forState:UIControlStateNormal];
    [_flashBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    _flashBtn.hidden = YES;
    [_flashBtn addTarget:self action:@selector(flashBtnAction) forControlEvents:UIControlEventTouchUpInside];
    _flashBtn.frame = CGRectMake((_scanRect.size.width - 50) / 2 + _scanRect.origin.x, _scanRect.origin.y + _scanRect.size.height - 30, 50, 30);
    [self addSubview:_flashBtn];
    
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.text = _tipText;
    _tipLabel.font = [UIFont systemFontOfSize:12];
    _tipLabel.frame = CGRectMake(_scanRect.origin.x, _scanRect.origin.y + _scanRect.size.height , _scanRect.size.width, 30);
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_tipLabel];
    
    //画扫描框
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.6);
    CGContextFillRect(context, rect);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokeRectWithWidth(context, _scanRect,_scanBorderLineWidth);
    CGContextClearRect(context, _scanRect);
    
    CGFloat interval = (_cornerLineWidth - _scanBorderLineWidth) / 2;
    
    //左上角
    UIBezierPath *pathLeft = [UIBezierPath bezierPath];
    [pathLeft moveToPoint:CGPointMake(_scanRect.origin.x + interval, _scanRect.origin.y + interval + _cornerWidth)];
    [pathLeft addLineToPoint:CGPointMake(_scanRect.origin.x + interval, _scanRect.origin.y + interval)];
    [pathLeft addLineToPoint:CGPointMake(_scanRect.origin.x + interval + _cornerWidth, _scanRect.origin.y + interval)];
    CAShapeLayer *layerLeft = [CAShapeLayer layer];
    layerLeft.path = pathLeft.CGPath;
    layerLeft.fillColor = [UIColor clearColor].CGColor;
    layerLeft.strokeColor = _cornerColor.CGColor;
    layerLeft.lineWidth = _cornerLineWidth;
    [self.layer addSublayer:layerLeft];
    
    //右上角
    [self initCorner:CGRectMake(_scanRect.origin.x + _scanRect.size.width - _cornerWidth - interval, _scanRect.origin.y + interval, _cornerWidth, _cornerWidth) start:0 end:0.5];
    //右下角
    [self initCorner:CGRectMake(_scanRect.origin.x + _scanRect.size.width - _cornerWidth - interval, _scanRect.origin.y + _scanRect.size.height - _cornerWidth - interval, _cornerWidth, _cornerWidth) start:0.25 end:0.75];
    //左下角
    [self initCorner:CGRectMake(_scanRect.origin.x + interval, _scanRect.origin.y + _scanRect.size.height - _cornerWidth - interval, _cornerWidth, _cornerWidth) start:0.5 end:1];
    
    //扫描线
    _scanAnimationLine = [[UIView alloc] init];
    _scanAnimationLine.backgroundColor = _scanAnimationLineColor;
    [self addSubview:self.scanAnimationLine];
}

//画边角
- (void)initCorner:(CGRect)rect start:(CGFloat)start end:(CGFloat)end{
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = _cornerColor.CGColor;
    layer.lineWidth = _cornerLineWidth;
    layer.strokeStart = start;
    layer.strokeEnd = end;
    [self.layer addSublayer:layer];
}



#pragma mark ----  timer - animation

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_animateTime target:self selector:@selector(scanLineAnimation) userInfo:nil repeats:YES];
}

- (void)scanLineAnimation {
    
    CGRect originFrame = CGRectMake(_scanRect.origin.x + 5, _scanRect.origin.y, _scanRect.size.width - 10, _scanAnimationLineHeight);
    CGRect finishframe = CGRectMake(_scanRect.origin.x + 5, _scanRect.origin.y + _scanRect.size.height, _scanRect.size.width - 10, _scanAnimationLineHeight);
    
    _scanAnimationLine.frame = originFrame;
    _scanAnimationLine.hidden = NO;
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:_animateTime - 0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
        weakSelf.scanAnimationLine.frame = finishframe;

    } completion:^(BOOL finished) {
        weakSelf.scanAnimationLine.hidden = YES;
    }];

}


- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    [self.scanAnimationLine removeFromSuperview];
    self.scanAnimationLine = nil;
}


#pragma mark ---- button
- (void)flashBtnAction {
    
    if ([DSQRCodeHelper isFlashOpen]) {
        [DSQRCodeHelper closeFlashLight];
        [_flashBtn setTitle:@"轻触照亮" forState:UIControlStateNormal];
    }else {
        [DSQRCodeHelper openFlashLight];
        [_flashBtn setTitle:@"轻触关闭" forState:UIControlStateNormal];
    }
}


- (void)setFlashButtonHidden:(BOOL)hidden{
    _flashBtn.hidden = hidden;
}


#pragma mark --- set
- (void)setScanBorderLineWidth:(CGFloat)scanBorderLineWidth {
    _scanBorderLineWidth = scanBorderLineWidth;
}

- (void)setCornerWidth:(CGFloat)cornerWidth  {
    _cornerWidth = cornerWidth;
}

- (void)setCornerColor:(UIColor *)cornerColor {
    _cornerColor = cornerColor;
}

- (void)setCornerLineWidth:(CGFloat)cornerLineWidth {
    _cornerLineWidth = cornerLineWidth;
}

- (void)setAnimateTime:(NSTimeInterval)animateTime {
    _animateTime = animateTime;
}


- (void)setScanAnimationLineColor:(UIColor *)scanAnimationLineColor {
    _scanAnimationLineColor = scanAnimationLineColor;
}

- (void)setScanAnimationLineHeight:(CGFloat)scanAnimationLineHeight {
    _scanAnimationLineHeight = scanAnimationLineHeight;
}

- (void)setTipText:(NSString *)tipText {
    _tipText = tipText;
}
@end
