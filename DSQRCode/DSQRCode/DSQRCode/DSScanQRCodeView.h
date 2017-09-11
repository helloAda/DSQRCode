//
//  DSScanQRCodeView.h
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/9.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSScanQRCodeView : UIView

@property (nonatomic, assign) CGRect  scanRect;

@property (nonatomic, assign) CGFloat scanBorderLineWidth;

@property (nonatomic, assign) CGFloat cornerWidth;

@property (nonatomic, assign) CGFloat cornerLineWidth;

@property (nonatomic, strong) UIColor *cornerColor;

@end
