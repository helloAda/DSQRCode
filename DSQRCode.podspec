

Pod::Spec.new do |s|
  s.name          = 'DSQRCode'
  s.version       = '1.0.1'
  s.summary       = '二维码扫描'
  s.homepage      = 'https://github.com/helloAda/DSQRCode'
  s.license       = 'MIT'
  s.author        = { 'Hello Ada' => 'hmd93@icloud.com' }
  s.platform        = :ios,'7.0'
  s.source        = { :git => 'https://github.com/helloAda/DSQRCode.git', :tag => s.version }
  s.source_files  = 'DSQRCode/DSQRCode/DSQRCode/**/*'
  s.resources     = 'DSQRCode/DSQRCode/Resources/*.mp3'
  s.requires_arc  = true
end
