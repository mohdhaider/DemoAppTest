Framework creation code:
- Open terminal and go to path of "ImageDownloader" folder
- Run these commands:

xcodebuild archive \
-scheme ImageDownloader \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/ImageDownloader.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES


xcodebuild archive \
-scheme ImageDownloader \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/ImageDownloader.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES


xcodebuild -create-xcframework \
-framework './build/ImageDownloader.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/ImageDownloader.framework' \
-framework './build/ImageDownloader.framework-iphoneos.xcarchive/Products/Library/Frameworks/ImageDownloader.framework' \
-output './build/ImageDownloader.xcframework'

This will create "ImageDownloader.xcframework" in "build" folder. That we need to add into project.


