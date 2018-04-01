source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
inhibit_all_warnings!

target 'tflapp' do
end

target 'tflApp Tests' do
    use_frameworks!
    pod 'Quick', '1.2.0' 
    pod 'Nimble', '7.0.3'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'Nimble' || target.name == 'Quick'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end
