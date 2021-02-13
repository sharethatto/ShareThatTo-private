
Pod::Spec.new do |s|
  s.name             = 'ShareThatTo'
  s.version          = '0.0.1'
  s.summary          = 'Sharing made easy'
  s.description      = 'Sharing made easy'
  s.license          = { :type => 'MIT' }
  #s.license          = 'abc' # { :type => 'Commercial', :text => 'Created and licensed by Share That To, LLC. Copyright 2021 Share That To, LLC. All rights reserved.' }

  s.homepage         = 'https://github.com/ShareThatTo/ShareThatTo'
  s.author           = { 'ShareThatTo' => 'brian@sharethat.to' }
  s.source           = { git: 'https://github.com/ShareThatTo/ShareThatTo.git' }

  s.ios.deployment_target = '10.0'
  s.source_files = 'Sources/**/*.{swift}'

  spec.ios.framework  = 'UIKit'
  spec.swift_version = '5.2'
end
