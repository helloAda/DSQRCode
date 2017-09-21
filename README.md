# DSQRCode

#### 一款简单使用的二维码/条码扫描


### 接入
```
    _manager = [[DSQRCodeManager alloc] initWithScanViewRect:CGRectZero showView:self.view];
    _manager.delegate = self;
    [_manager startRunning];

具体可参考Demo
```

## 目前实现的功能
* 亮度检测打开闪光灯
* 可连续扫描
* 扫描框颜色，宽度，布局，大多数可自定义



# 其它
* 支持 `ios7.0` ,当前版本`1.0.0`
* 支持 `pod`,`pod ``'DSQRCode'`

> 近期较忙，后续还将实现 图片识别，生成二维码 焦距放大等。

