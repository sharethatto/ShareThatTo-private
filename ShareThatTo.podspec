
Pod::Spec.new do |s|
  s.name             = 'ShareThatTo'
  s.version          = '0.0.1'
  s.summary          = 'Sharing made easy'
  s.description      = ''

  s.homepage         = 'https://github.com/ShareThatTo/ShareThatTo'
  s.author           = { 'ShareThatTo' => 'brian@sharethat.to' }
  s.source           = { git: 'https://github.com/ShareThatTo/ShareThatTo.git',
                         tag: "v#{s.version}" }

  s.ios.deployment_target = '10.0'
  s.source_files = 'Sources/Sources/*.{swift}'
end
