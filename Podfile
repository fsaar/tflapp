source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'
inhibit_all_warnings!

target 'tflapp' do
 pod 'SwiftLint','0.38.1'
end

target 'tflApp Tests' do
    pod 'Quick', '2.1.0'
    pod 'Nimble', '8.0.2'
end

post_install do |lib|
    lib.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        end
    end
end

