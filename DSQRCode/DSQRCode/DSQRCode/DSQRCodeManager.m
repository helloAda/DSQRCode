//
//  DSQRCodeManager.m
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/20.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import "DSQRCodeManager.h"
#import <AVFoundation/AVFoundation.h>
#import "DSQRCodeHelper.h"

@interface DSQRCodeManager ()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

//扫描框范围
@property (nonatomic, assign) CGRect scanRect;

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation DSQRCodeManager


- (instancetype)initWithScanViewRect:(CGRect)rect showView:(UIView *)view {
    self = [super init];
    if (self) {
        if (![self isAvailable]) return nil;
        //设置扫描范围
        if (CGRectEqualToRect(rect,CGRectZero) || CGRectEqualToRect(rect, CGRectNull)) {
            if (view.frame.size.height > view.frame.size.width) {
               _scanRect = CGRectMake(view.frame.size.width * 0.15,(view.frame.size.height - view.frame.size.width * 0.7) / 2 , view.frame.size.width * 0.7, view.frame.size.width * 0.7);
            }
            else {
            _scanRect = CGRectMake((view.frame.size.width - view.frame.size.height * 0.7) / 2, (view.frame.size.height - view.frame.size.height * 0.7) / 2, view.frame.size.height * 0.7, view.frame.size.height * 0.7);
            }
        }else {
            _scanRect = rect;
        }
        
        [self setupAVCaptureWithView:view];
        _scanView = [[DSScanQRCodeView alloc] initWithScanViewRect:_scanRect showView:view];

    }
    return self;
}


- (void)setupAVCaptureWithView:(UIView *)view {
    _soundName = @"ScanSound.mp3";
    _isPlaySound = YES;
    _scanContinue = NO;
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    
    _metadataOutput = [[AVCaptureMetadataOutput alloc]init];
    [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:_input])
    {
        [_session addInput:_input];
    }
    if ([_session canAddOutput:_metadataOutput])
    {
        [_session addOutput:_metadataOutput];
        [_session addOutput:_videoDataOutput];
    }
    
    _metadataOutput.rectOfInterest = CGRectMake(_scanRect.origin.y / view.frame.size.height, _scanRect.origin.x / view.frame.size.width, _scanRect.size.height / view.frame.size.height, _scanRect.size.width / view.frame.size.width);
    
    _metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                            AVMetadataObjectTypeCode39Code,
                                            AVMetadataObjectTypeCode128Code,
                                            AVMetadataObjectTypeQRCode];
    
    _previewLayer =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = view.bounds;
    [view.layer insertSublayer:_previewLayer atIndex:0];

}

- (BOOL)isAvailable {
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return NO;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"没有权限访问相机，请在设置-隐私-相机中打开" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }else {
        return YES;
    }
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //设置界面显示扫描结果
    if (metadataObjects.count > 0 && metadataObjects) {
        //播放声音
        if (_isPlaySound) {
            [self playSound];
        }
        if (!_scanContinue) {
            if ([self.delegate respondsToSelector:@selector(scanQRCodeResultMetadataObject:)]) {
                [self stopRunning];
                [self.delegate scanQRCodeResultMetadataObject:metadataObjects];
            }
        }else {
            //连续扫码 stop由自己控制
            if ([self.delegate respondsToSelector:@selector(scanQRCodeResultMetadataObject:)]) {
                [self.delegate scanQRCodeResultMetadataObject:metadataObjects];
            }
        }

    }
}

#pragma mark - - - AVCaptureVideoDataOutputSampleBufferDelegate的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float lightValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    if ([DSQRCodeHelper isFlashOpen]) {
        [_scanView setFlashButtonHidden:NO];
    }else {
        if (lightValue > -3.5) {
            [_scanView setFlashButtonHidden:YES];
        }else {
            [_scanView setFlashButtonHidden:NO];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}

#pragma mark  ---- common
- (void)startRunning {
    [_session startRunning];
}

- (void)stopRunning {
    [_session stopRunning];
}

- (void)setFullScan {
   _metadataOutput.rectOfInterest = CGRectMake(0, 0, 1, 1);
}

- (void)playSound {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:_soundName ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    
    SystemSoundID sysSoundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &sysSoundID);
    AudioServicesAddSystemSoundCompletion(sysSoundID, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, soundPlayCallback, NULL);
    AudioServicesPlaySystemSound(sysSoundID);
}

void soundPlayCallback(SystemSoundID ssID, void* __nullable clientData){
    
}

#pragma mark --  set

- (void)setMetadataObjectTypes:(NSArray *)metadataObjectTypes {
    _metadataOutput.metadataObjectTypes = metadataObjectTypes;
}

- (void)setSessionPreset:(NSString *)sessionPreset {
    [_session setSessionPreset:sessionPreset];
}

- (void)setSoundName:(NSString *)soundName {
    _soundName = soundName;
}

- (void)setIsPlaySound:(BOOL)isPlaySound {
    _isPlaySound = isPlaySound;
}

@end
