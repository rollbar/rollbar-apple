build:
	xcodebuild archive \
		-workspace SPMFramework.xcworkspace \
		-scheme SPMFramework \
		-derivedDataPath "build" \
	 	BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
		OTHER_SWIFT_FLAGS="$(inherited) -no-verify-emitted-module-interface"
