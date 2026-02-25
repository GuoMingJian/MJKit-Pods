Pod::Spec.new do |s|
  s.name            = 'MJKit'
  s.version         = '1.0.0'
  s.summary         = 'iOS开发基础组件'
  s.description     = '封装了<扩展、工具函数、UI组件>等'
  s.license         = { :type => 'MIT', :file => 'LICENSE' }
  s.author          = { '郭明健' => '1339601489@qq.com' }
  s.homepage        = 'https://github.com/GuoMingJian/MJKit-Pods'
  s.source          = { 
    :git => 'https://github.com/GuoMingJian/MJKit-Pods.git' , 
    :tag => s.version.to_s 
  }
  s.ios.deployment_target = '12.0'
  #s.platform        = :ios, '14.0'
  s.swift_version   = '5.0'
  s.source_files    = 'Core/**/*.{h,m,swift}'
  s.resources       = [
  'Core/**/*.bundle',
  'Core/**/*.xcassets'
  ]
  s.public_header_files = 'Core/**/*.h'
  
  # 依赖第三方
  s.dependency 'MJRefresh', '~> 3.7.9'
  s.dependency 'EmptyDataSet-Swift', '~> 5.0.0'
  s.dependency 'SnapKit', '~> 5.7.1'
  s.dependency 'Then', '~> 3.0.0'
  s.dependency 'HXPhotoPicker', '~> 5.0.4'
  s.dependency 'ZLPhotoBrowser', '~> 4.5.8'
  s.dependency 'SDWebImage', '~> 5.21.1'
  s.dependency 'AliyunOSSiOS', '~> 2.11.1'
  s.dependency 'NVActivityIndicatorView', '~> 5.2.0'
  s.dependency 'KeychainAccess', '~> 4.2.2'
  s.dependency 'MobileVLCKit', '~> 3.6.0'
end
