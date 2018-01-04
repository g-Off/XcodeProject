SWIFTC_FLAGS = -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12"

build:
	swift build $(SWIFTC_FLAGS)
	
test:
	swift test $(SWIFTC_FLAGS)
	
xcode:
	swift package generate-xcodeproj --xcconfig-overrides=overrides.xcconfig

clean:
	swift build --clean