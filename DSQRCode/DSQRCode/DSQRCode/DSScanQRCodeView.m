//
//  DSScanQRCodeView.m
//  DSQRCode
//
//  Created by 黄铭达 on 2017/9/9.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import "DSScanQRCodeView.h"


@interface DSScanQRCodeView ()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, assign) CGFloat scanX;
@property (nonatomic, assign) CGFloat scanY;
@property (nonatomic, assign) CGFloat scanW;
@property (nonatomic, assign) CGFloat scanH;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIView *scanAnimationLine;
@property (nonatomic, strong) UIButton *flashBtn;

@end
@implementation DSScanQRCodeView

- (instancetype)initWithView:(UIView *)view
{
    self = [super initWithFrame:view.frame];
    if (self) {
        [self initView];
        [self initAVCaptureWithView:view];
    }
    
    return self;
    
}

- (void)initView {
    
    self.backgroundColor = [UIColor clearColor];
    _scanBorderLineWidth = 1;
    _cornerWidth = 20;
    _cornerLineWidth = 4;
    _animateTime = 2;
    _soundName = @"ScanSound.mp3";
    _scanAnimationLineHeight = 1;
    _cornerColor = [UIColor colorWithRed:85/255.0f green:183/255.0 blue:55/255.0 alpha:1.0];
    _scanAnimationLineColor = [UIColor colorWithRed:85/255.0f green:183/255.0 blue:55/255.0 alpha:1.0];
    _isPlaySound = YES;
    _tipText = @"将二维码/条码放入框内，即可自动扫描";
    if (self.frame.size.height > self.frame.size.width) {
        _scanW = self.frame.size.width * 0.7;
        _scanH = _scanW;
        _scanX = self.frame.size.width * 0.15;
        _scanY = (self.frame.size.height - _scanW) / 2;
    }
    else {
        _scanW = self.frame.size.height * 0.7;
        _scanH = _scanW;
        _scanX = (self.frame.size.width - _scanW) / 2;
        _scanY = (self.frame.size.height - _scanH) / 2;
    }
    
}

- (void)drawRect:(CGRect)rect {
    
    //画扫描框
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.6);
    CGContextFillRect(context, rect);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokeRectWithWidth(context, CGRectMake(_scanX, _scanY, _scanW, _scanH),_scanBorderLineWidth);
    CGContextClearRect(context, CGRectMake(_scanX, _scanY, _scanW, _scanH));
    
    CGFloat interval = (_cornerLineWidth - _scanBorderLineWidth) / 2;
    
    _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashBtn setTitle:@"轻触照亮" forState:UIControlStateNormal];
    [_flashBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    _flashBtn.hidden = YES;
    [_flashBtn addTarget:self action:@selector(flashBtnAction) forControlEvents:UIControlEventTouchUpInside];
    _flashBtn.frame = CGRectMake((_scanW - 50) / 2 + _scanX, _scanY + _scanH - 30, 50, 30);
    [self addSubview:_flashBtn];
    
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.text = _tipText;
    _tipLabel.font = [UIFont systemFontOfSize:12];
    _tipLabel.frame = CGRectMake(_scanX, _scanY + _scanH , _scanW, 30);
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_tipLabel];
    
    //左上角
    UIBezierPath *pathLeft = [UIBezierPath bezierPath];
    [pathLeft moveToPoint:CGPointMake(_scanX + interval, _scanY + interval + _cornerWidth)];
    [pathLeft addLineToPoint:CGPointMake(_scanX + interval, _scanY + interval)];
    [pathLeft addLineToPoint:CGPointMake(_scanX + interval + _cornerWidth, _scanY + interval)];
    CAShapeLayer *layerLeft = [CAShapeLayer layer];
    layerLeft.path = pathLeft.CGPath;
    layerLeft.fillColor = [UIColor clearColor].CGColor;
    layerLeft.strokeColor = _cornerColor.CGColor;
    layerLeft.lineWidth = _cornerLineWidth;
    [self.layer addSublayer:layerLeft];
    
    //右上角
    [self initCorner:CGRectMake(_scanX + _scanW - _cornerWidth - interval, _scanY + interval, _cornerWidth, _cornerWidth) start:0 end:0.5];
    //右下角
    [self initCorner:CGRectMake(_scanX + _scanW - _cornerWidth - interval, _scanY + _scanH - _cornerWidth - interval, _cornerWidth, _cornerWidth) start:0.25 end:0.75];
    //左下角
    [self initCorner:CGRectMake(_scanX + interval, _scanY + _scanH - _cornerWidth - interval, _cornerWidth, _cornerWidth) start:0.5 end:1];
    //扫描线
    _scanAnimationLine = [[UIView alloc] init];
    _scanAnimationLine.backgroundColor = _scanAnimationLineColor;
    [self addSubview:self.scanAnimationLine];
    [self startTimer];
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



- (void)initAVCaptureWithView:(UIView *)view {
    
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
    
    _metadataOutput.rectOfInterest = CGRectMake(_scanY / self.frame.size.height, _scanX / self.frame.size.width, _scanH / self.frame.size.height, _scanW / self.frame.size.width);
    _metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                    AVMetadataObjectTypeEAN8Code,
                                    AVMetadataObjectTypeCode128Code,
                                    AVMetadataObjectTypeQRCode];
    
    _previewLayer =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = view.bounds;
    [view.layer insertSublayer:_previewLayer atIndex:0];
    
    [_session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //设置界面显示扫描结果
    if (metadataObjects.count > 0) {
        if ([self.delegate respondsToSelector:@selector(scanQRCodeResultMetadataObject:)]) {
            [self.delegate scanQRCodeResultMetadataObject:metadataObjects];
        }
    }
    if (_isPlaySound) {
        [self playSound];
    }
}


#pragma mark - - - AVCaptureVideoDataOutputSampleBufferDelegate的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float lightValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    if ([self isFlashOpen]) {
        _flashBtn.hidden = NO;
    }else {
        if (lightValue > -3.5) {
            _flashBtn.hidden = YES;
        }else {
            _flashBtn.hidden = NO;
        }
    }

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}


#pragma mark ----  timer - animation

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_animateTime target:self selector:@selector(scanLineAnimation) userInfo:nil repeats:YES];
}

- (void)scanLineAnimation {
    
    CGRect originFrame = CGRectMake(_scanX + 5, _scanY, _scanW - 10, _scanAnimationLineHeight);
    CGRect finishframe = CGRectMake(_scanX + 5, _scanY + _scanH, _scanW - 10, _scanAnimationLineHeight);
    
    _scanAnimationLine.frame = originFrame;
    _scanAnimationLine.hidden = NO;
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateKeyframesWithDuration:_animateTime - 0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
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


#pragma mark ----- common

- (void)startRunning {
    [_session startRunning];
}

- (void)stopRunning {
    [_session stopRunning];
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


- (void)openFlashLight {
    NSError *error = nil;
    if ([_device hasTorch]) {
        BOOL locked = [_device lockForConfiguration:&error];
        if (locked) {
            _device.torchMode = AVCaptureFlashModeOn;
            [_device unlockForConfiguration];
        }
    }
}


- (void)closeFlashLight {
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        _device.torchMode = AVCaptureTorchModeOff;
        [_device unlockForConfiguration];
    }
}

- (BOOL)isFlashOpen {
    return _device.torchMode;
}

- (void)flashBtnAction {
    if ([self isFlashOpen]) {
        [self closeFlashLight];
        [_flashBtn setTitle:@"轻触照亮" forState:UIControlStateNormal];
    }else {
        [self openFlashLight];
        [_flashBtn setTitle:@"轻触关闭" forState:UIControlStateNormal];
    }
}

#pragma mark --  set

- (void)setMetadataObjectTypes:(NSArray *)metadataObjectTypes {
    _metadataOutput.metadataObjectTypes = metadataObjectTypes;
}

- (void)setScanRect:(CGRect)scanRect {
    _scanX = scanRect.origin.x;
    _scanY = scanRect.origin.y;
    _scanW = scanRect.size.width;
    _scanH = scanRect.size.height;
//    _metadataOutput.rectOfInterest = CGRectMake(_scanY / self.frame.size.height, _scanX / self.frame.size.width, _scanH / self.frame.size.height, _scanW / self.frame.size.width);
}

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

- (void)setSoundName:(NSString *)soundName {
    _soundName = soundName;
}

- (void)setScanAnimationLineColor:(UIColor *)scanAnimationLineColor {
    _scanAnimationLineColor = scanAnimationLineColor;
}

- (void)setScanAnimationLineHeight:(CGFloat)scanAnimationLineHeight {
    _scanAnimationLineHeight = scanAnimationLineHeight;
}

- (void)setIsPlaySound:(BOOL)isPlaySound {
    _isPlaySound = isPlaySound;
}

- (void)setTipText:(NSString *)tipText {
    _tipText = tipText;
}
@end
