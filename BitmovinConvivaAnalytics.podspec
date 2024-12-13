Pod::Spec.new do |s|
  s.name             = 'BitmovinConvivaAnalytics'
  s.version          = '3.5.0'
  s.summary          = 'Conviva Analytics Integration for the Bitmovin Player iOS SDK'

  s.description      = <<-DESC
Conviva Analytics Integration for the Bitmovin Player iOS SDK
                       DESC

  s.homepage         = 'https://github.com/bitmovin/bitmovin-player-ios-analytics-conviva'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'Bitmovin' => 'david.steinacher@bitmovin.com' }
  s.source           = { git: 'https://github.com/bitmovin/bitmovin-player-ios-analytics-conviva.git', tag: s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.tvos.deployment_target = '14.0'

  s.source_files = 'BitmovinConvivaAnalytics/Classes/**/*.swift'
  s.resources = 'BitmovinConvivaAnalytics/Assets/*'
  s.swift_version = '5.0'
  s.cocoapods_version = '>= 1.9.0'

  s.ios.dependency 'BitmovinPlayer', '~> 3.64'
  s.tvos.dependency 'BitmovinPlayer', '~> 3.64'
  s.ios.dependency 'ConvivaSDK', '~> 4.0'
  s.tvos.dependency 'ConvivaSDK', '~> 4.0'

  s.static_framework = true
end
