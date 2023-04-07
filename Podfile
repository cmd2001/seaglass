platform :osx, '10.15'
inhibit_all_warnings!

target 'Seaglass' do
  use_frameworks!
  pod 'MatrixSDK'
  pod 'Down'
  pod 'TSMarkdownParser'
  pod 'Sparkle'
  pod 'LetsMove'
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.15'
    end
  end
end

