//
//  DSQRCodeHelper.m
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/20.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import "DSQRCodeHelper.h"
#import <AVFoundation/AVFoundation.h>

@implementation DSQRCodeHelper

+ (void)openFlashLight {
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        BOOL locked = [device lockForConfiguration:&error];
        if (locked) {
            device.torchMode = AVCaptureFlashModeOn;
            [device unlockForConfiguration];
        }
    }
}


+ (void)closeFlashLight {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        device.torchMode = AVCaptureTorchModeOff;
        [device unlockForConfiguration];
    }
}

+ (BOOL)isFlashOpen {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return device.torchMode;
}
@end
