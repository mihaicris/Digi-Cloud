platform :ios, '9.0'
use_frameworks!

target 'Digi Cloud' do
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SwiftLint'

  target 'Digi Cloud UITests' do
    inherit! :search_paths
  end
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              if config.name == 'Debug'
                  config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
                  config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
              end
          end
      end
  end
  
  end


