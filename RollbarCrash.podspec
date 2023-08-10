Pod::Spec.new do |s|
    s.name         = "RollbarCrash"
    s.version      = "3.1.1"
    s.summary      = "Application or client side SDK for interacting with the Rollbar API Server."
    s.description  = <<-DESC
                      Find, fix, and resolve errors with Rollbar.
                      Easily send error data using Rollbar API.
                      Analyze, de-dupe, send alerts, and prepare the data for further analysis.
                      Search, sort, and prioritize via the Rollbar dashboard.
                   DESC
    s.homepage     = "https://rollbar.com"
    s.resource     = "rollbar-logo.png"
    s.license      = { :type => "MIT", :file => "LICENSE" }
    s.authors      = { "Rollbar" => "support@rollbar.com" }
    s.source       = { :git => "https://github.com/rollbar/rollbar-apple.git",
                       :tag => s.version.to_s }
    s.documentation_url = "https://docs.rollbar.com/docs/apple"
    s.social_media_url  = "https://twitter.com/rollbar"

    s.osx.deployment_target = "10.13"
    s.ios.deployment_target = "11.0"
    s.tvos.deployment_target = "11.0"
    s.watchos.deployment_target = "4.0"

    s.module_name = "RollbarCrash"
    s.source_files  = "RollbarNotifier/Sources/#{s.name}/**/*.{h,c,cpp,m}"
    s.public_header_files = "RollbarNotifier/Sources/#{s.name}/include/*.h"
    s.module_map = "RollbarNotifier/Sources/#{s.name}/include/module.modulemap"

    s.framework = "Foundation"
    s.libraries = 'z', 'c++'

    s.pod_target_xcconfig = {
        'GCC_ENABLE_CPP_EXCEPTIONS' => 'YES',
        'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
        'CLANG_CXX_LIBRARY' => 'libc++'
    }

    s.swift_versions = "5.5"
    s.requires_arc = true
end
