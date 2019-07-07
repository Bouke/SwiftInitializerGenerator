Swift Initializer Generator
===========================

This Xcode Source Code Extension will generate a Swift initializer based on the lines you've selected. Handy if you made a struct public and now you have to provide the initializer implementation yourself.

Usage
-----

Select the lines with the attributes that should be included in the initializer. See below; ``>`` is the start of the selection and ``<`` is the end of the selection.
```swift
struct MyStruct {
>    public var a: String
    public var b: Int<
}
```
Run the extension's "Generate Swift Initializer". Voila! The code above is modified to:
```swift
struct MyStruct {
    public var a: String
    public var b: Int
    public init(a: String, b: Int) {
        self.a = a
        self.b = b
    }
}
```
![Demo](docs/demo.gif)

Installation
------------

1. On OS X 10.11 El Capitan, run the following command and restart your Mac:

        sudo /usr/libexec/xpccachectl

1. Open ``SwiftInitializerGenerator.xcodeproj``
1. Enable target signing for both the Application and the Source Code Extension using your own developer ID
1. Product > Archive
1. Right click archive > Show in Finder
1. Right click archive > Show Package Contents
1. Drag ``Swift Initializer Generator.app`` to your Applications folder
1. Run ``Swift Initializer Generator.app`` and exit again.
1. Go to System Preferences -> Extensions -> Xcode Source Editor and enable the extension
1. The menu-item should now be available from Xcode's Editor menu.

Known limitations
-----------------

It will only parse attributes defined like ``(open|public|fileprivate|private|internal) [weak] (var|let) NAME: TYPE``.
