Pod::Spec.new do |s|
  s.ios.deployment_target = '5.0'
  s.name     = 'UICollectionViewWaterfallLayout'
  s.version  = '0.0.1'
  s.platform = :ios
  s.license  = 'MIT'
  s.summary  = 'A UICollectionViewLayout fork inspired by pintrest.'
  s.homepage = 'https://github.com/orta/UICollectionViewWaterfallLayout'
  s.author   = { 'Nelson Tai' => 'chiahsien@gmail.com' }
  s.source   = { :git => 'https://github.com/orta/UICollectionViewWaterfallLayout.git' }
  s.source_files = '*.{h,m}'
  s.requires_arc = true
end