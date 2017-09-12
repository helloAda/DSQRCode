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

@protocol DSQRCodeDelegate <NSObject>

@required
/**
 扫描二维码数据回调
 
 @param metadatas 扫描结果
 */
- (void)scanQRCodeResultMetadataObject:(NSArray *)metadatas;

@optional

- (void)scanQRCodeLightValue:(CGFloat)lightValue;

@end




@interface DSScanQRCodeView : UIView

- (instancetype)initWithView:(UIView *)view;

//播放声音
- (void)playSound;

//停止画面
- (void)stopRunning;

//开启画面
- (void)startRunning;

@property (nonatomic, weak) id<DSQRCodeDelegate> delegate;

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

//音频文件名称
@property (nonatomic, copy) NSString *soundName;

//扫描动画 线的颜色
@property (nonatomic, strong) UIColor *scanAnimationLineColor;

//扫描动画 线的高度
@property (nonatomic, assign) CGFloat scanAnimationLineHeight;
@end
