Pod::Spec.new do |s|
  s.name         = "Rollbar"
  s.version      = "3.0.0"
  s.summary      = "Application or client side SDK for interacting with the Rollbar API Server."
  s.description  = <<-DESC
                    Find, fix, and resolve errors with Rollbar.
                    Easily send error data using Rollbar API.
                    Analyze, de-dupe, send alerts, and prepare the data for further analysis.
                    Search, sort, and prioritize via the Rollbar dashboard.
                  DESC

  s.homepage     = "https://rollbar.com"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Rollbar" => "support@rollbar.com" }
  s.source       = { :git => "https://github.com/rollbar/rollbar-apple.git",
                     :tag => s.version.to_s }

  s.documentation_url = "https://docs.rollbar.com/docs/apple"
  s.social_media_url  = "https://twitter.com/rollbar"
  s.resource = "rollbar-logo.png"

  s.osx.deployment_target = "12.0"
  s.ios.deployment_target = "14.0"
  s.tvos.deployment_target = "14.0"
  s.watchos.deployment_target = "8.0"

  s.module_name  = "RollbarNotifier"
  s.requires_arc = true
  s.frameworks = 'Foundation'
  s.swift_versions = "5.5"

  s.pod_target_xcconfig = {
      'GCC_ENABLE_CPP_EXCEPTIONS' => 'YES',
      'CLANG_CXX_LANGUAGE_STANDARD' => 'c++14',
      'CLANG_CXX_LIBRARY' => 'libc++'
  }
  s.watchos.pod_target_xcconfig = {
      'OTHER_LDFLAGS' => '$(inherited) -framework WatchKit'
  }

  s.source_files  = "RollbarNotifier/Sources/RollbarNotifier/**/*.{h,m}", "RollbarNotifier/Sources/RollbarCrashReport/**/*.swift"
  s.public_header_files = "RollbarNotifier/Sources/RollbarNotifier/include/*.h"
  s.module_map = "RollbarNotifier/Sources/RollbarNotifier/include/module.modulemap"

  s.default_subspecs = ['Common']

  s.dependency "KSCrash", "~> 1.15.27"

  s.subspec 'Common' do |sp|
      sp.source_files  = "RollbarCommon/Sources/RollbarCommon/**/*.{h,m}"
      sp.public_header_files = "RollbarCommon/Sources/RollbarCommon/include/*.h"
      #sp.module_map = "RollbarCommon/Sources/RollbarCommon/include/module.modulemap"
  end

  s.subspec 'AUL' do |sp|
      sp.source_files = "RollbarAUL/Sources/RollbarAUL/**/*.{h,m}"
      sp.public_header_files = "RollbarAUL/Sources/RollbarAUL/include/*.h"
      #sp.module_map = "RollbarAUL/Sources/RollbarAUL/include/module.modulemap"
  end

  s.subspec 'CocoaLumberjack' do |sp|
      sp.source_files  = "RollbarCocoaLumberjack/Sources/RollbarCocoaLumberjack/**/*.{h,m}"
      sp.public_header_files = "RollbarCocoaLumberjack/Sources/RollbarCocoaLumberjack/include/*.h"
      #sp.module_map = "RollbarCocoaLumberjack/Sources/RollbarCocoaLumberjack/include/module.modulemap"

      #sp.static_framework = true
      sp.dependency "CocoaLumberjack", "~> 3.7.4"
  end

  s.subspec 'Deploys' do |sp|
      sp.source_files  = "RollbarDeploys/Sources/RollbarDeploys/**/*.{h,m}"
      sp.public_header_files = "RollbarDeploys/Sources/RollbarDeploys/include/*.h"
      #sp.module_map = "RollbarDeploys/Sources/RollbarDeploys/include/module.modulemap"
  end
end
