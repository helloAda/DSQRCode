//
//  DSQRCodeManager.m
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/9.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import "DSQRCodeManager.h"

#define AuthorizationMessage @"App没有访问相机的权限，请在设置-隐私-相机中开启"

@interface DSQRCodeManager ()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureDevice *backDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *backInput;

@property (strong, nonatomic) AVCaptureDevice  *frontDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *frontInput;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end


@implementation DSQRCodeManager


- (BOOL)isAuthorization {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:AuthorizationMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    return YES;

}

+ (instancetype)creatAVCapture {
    DSQRCodeManager *manager = [[DSQRCodeManager alloc] initWithDefaultAVCapture];
    return manager;
}

- (instancetype)initWithDefaultAVCapture {
    
    if (self = [super init]) {
        
        if(![self isAuthorization]) return nil;
        
        [self initDevice];

    }
    return self;
}


- (void)initDevice {
    
    _backDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    _session = [[AVCaptureSession alloc] init];
    _soundFileName = @"";
    if (_backDevice) {
        _backInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backDevice error:nil];
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        _session = [[AVCaptureSession alloc] init];
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if (device.position == AVCaptureDevicePositionFront) {
                _frontDevice = device;
            }
        }
    }
    
    if (_frontDevice) {
        _frontInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontDevice error:nil];
    }
    
    if (_backDevice) {
        [_session addInput:self.backInput];
    }
    
    [_session addOutput:self.metadataOutput];
    [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_metadataOutput setMetadataObjectTypes:@[
                                              AVMetadataObjectTypeQRCode,
                                              AVMetadataObjectTypeDataMatrixCode,
                                              AVMetadataObjectTypeITF14Code,
                                              AVMetadataObjectTypeInterleaved2of5Code,
                                              AVMetadataObjectTypeAztecCode,
                                              AVMetadataObjectTypePDF417Code,
                                              AVMetadataObjectTypeCode128Code,
                                              AVMetadataObjectTypeCode93Code,
                                              AVMetadataObjectTypeEAN8Code,
                                              AVMetadataObjectTypeEAN13Code,
                                              AVMetadataObjectTypeCode39Mod43Code,
                                              AVMetadataObjectTypeCode39Code,
                                              AVMetadataObjectTypeUPCECode
                                              ]];
    [_session startRunning];
}



#pragma mark --- AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
}

#pragma mark --- AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}



#pragma mark --- General

- (void)startRunning {
    [_session startRunning];
}

- (void)stopRunning {
    [_session stopRunning];
}


- (void)setSoundFileName:(NSString *)soundFileName {
    _soundFileName = soundFileName;
}

- (void)playSound {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:_soundFileName ofType:nil];
    if (!filePath) return;
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    SystemSoundID sysSoundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileUrl, &sysSoundID);
    AudioServicesAddSystemSoundCompletion(sysSoundID, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, addSystemSound, NULL);
    AudioServicesPlaySystemSound(sysSoundID);
}

void addSystemSound(SystemSoundID ssID, void* __nullable clientData) {
    
}
@end
