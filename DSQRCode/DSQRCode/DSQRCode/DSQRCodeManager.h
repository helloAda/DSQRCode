//
//  DSQRCodeManager.h
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/20.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DSScanQRCodeView.h"

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


@interface DSQRCodeManager : NSObject

/**
 初始化方法

 @param rect 扫描框的rect (传CGRectZero 则为默认值)
 @param view 扫描View要添加在这个View上,通常都是vc的view
 @return 实例
 */
- (instancetype)initWithScanViewRect:(CGRect)rect showView:(UIView *)view;

// 开启会话扫描
- (void)startRunning;

// 停止会话扫描
- (void)stopRunning;

// 移除 videoPreviewLayer 对象
- (void)videoPreviewLayerRemoveFromSuperlayer;

//代理
@property (nonatomic, weak) id<DSQRCodeDelegate> delegate;

//扫描view
@property (nonatomic, strong) DSScanQRCodeView *scanView;

//扫描数据类型 @[AVMetadataObjectTypeQRCode]
@property (nonatomic, strong) NSArray *metadataObjectTypes;

//采集质量 默认 AVCaptureSessionPresetHigh
@property (nonatomic, strong) NSString *sessionPreset;

//音频文件名称
@property (nonatomic, copy) NSString *soundName;

//是否播放声音
@property (nonatomic, assign) BOOL isPlaySound;

@end
