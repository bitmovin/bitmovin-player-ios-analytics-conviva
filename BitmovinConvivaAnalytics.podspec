Pod::Spec.new do |s|
  s.name             = 'BitmovinConvivaAnalytics'
  s.version          = '0.1.0'
  s.summary          = 'A short description of BitmovinConvivaAnalytics.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/bitmovin/bitmovin-player-ios-analytics-conviva'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'Bitmovin' => 'david.steinacher@bitmovin.com' }
  s.source           = { git: 'https://github.com/bitmovin/bitmovin-player-ios-analytics-conviva.git', tag: s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'BitmovinConvivaAnalytics/Classes/**/*.swift'
  s.swift_version = '4.2'

  s.ios.dependency 'BitmovinPlayer', '~> 2.0'
  s.tvos.dependency 'BitmovinPlayer', '~> 2.0'
  s.ios.dependency 'ConvivaSDK', '~> 2.141.0'
  s.tvos.dependency 'ConvivaSDK', '~> 2.141.0'

  s.static_framework = true
end
