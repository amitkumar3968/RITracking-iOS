# RITracking-iOS


A Tracking SDK for iOS

The SDK can be integrated into iOS application projects and provide convenient tracking via customizing convenience wrappers in subclasses (i.e. app delegate and view controllers). The integrated trackers (Google Analytics, Ad-X Tracking, etc.) are pervasively initialized using a central property list file bundled with the application to contain all required keys, token and further configuration. The Tracking interface is initialized using a file path reference to the property list file.

## Cocoa Pods
The project uses dependency management by [CocoaPods](http://cocoapods.org/). Please see this [tutorial](http://goo.gl/xJiSy) by raywenderlich.com for further information about CocoaPods integration.

When starting development on the project, fork it, clone it and run `pod install` (Make sure you have installed CocoaPods to your host machine via `sudo gem install cocoapods`).

## License

The MIT License (MIT)

Copyright (c) 2013 Martin Biermann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
