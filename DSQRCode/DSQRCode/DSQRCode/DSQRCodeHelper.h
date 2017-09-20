//
//  DSQRCodeHelper.h
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/20.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSQRCodeHelper : NSObject

//打开闪光灯
+ (void)openFlashLight;

//关闭闪光灯
+ (void)closeFlashLight;

//闪光灯开启状态
+ (BOOL)isFlashOpen;

@end
