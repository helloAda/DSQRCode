//
//  DSScanQRCodeView.h
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/9.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>


@interface DSScanQRCodeView : UIView

- (instancetype)initWithScanViewRect:(CGRect)rect showView:(UIView *)view;

// 添加定时器
- (void)startTimer;

// 停止定时器(记得销毁)
- (void)stopTimer;

//扫描框线宽
@property (nonatomic, assign) CGFloat scanBorderLineWidth;

//边角的长度
@property (nonatomic, assign) CGFloat cornerWidth;

//边角的线宽
@property (nonatomic, assign) CGFloat cornerLineWidth;

//边角的颜色
@property (nonatomic, strong) UIColor *cornerColor;

//扫描线动画时间 默认2s
@property (nonatomic, assign) NSTimeInterval animateTime;

//扫描动画 线的颜色
@property (nonatomic, strong) UIColor *scanAnimationLineColor;

//扫描动画 线的高度
@property (nonatomic, assign) CGFloat scanAnimationLineHeight;

//提示文字
@property (nonatomic, copy) NSString *tipText;


// 亮度足够时隐藏闪光灯(提供给DSQRCodeManager内使用，一般你不应该调用这个方法)
- (void)setFlashButtonHidden:(BOOL)hidden;

@end
