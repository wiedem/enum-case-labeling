# EnumCaseLabeling

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2016%20%7C%20macOS%2013%20%7C%20tvOS%2016%20%7C%20watchOS%209%20%7C%20visionOS%201-blue.svg)](https://developer.apple.com)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.txt)

A Swift macro package that generates case labels for enumerations with associated values. Case labels allow comparing enum cases by their label, ignoring associated values.

## Usage

### The `@CaseLabeled` Macro

Apply the `@CaseLabeled` macro to an enumeration to generate a nested `CaseLabel` enum and a `caseLabel` property:

```swift
@CaseLabeled
enum MyEnum: Equatable {
    case intValue(Int)
    case stringValue(string: String)
}
```

The generated `CaseLabel` enum mirrors the cases of the original enum without associated values and conforms to `Hashable`, `CaseIterable`, and `Sendable`. The `caseLabel` property returns the matching `CaseLabel` for each case.

### Comparing Case Labels

Case labels can identify values with the same case, even if their associated values differ.

The `~~` operator and the `hasSameLabel(as:)` method compare two values by their case label:

```swift
let value1: MyEnum = .intValue(1)
let value2: MyEnum = .intValue(2)

value1 == value2                      // false - different associated values
value1 ~~ value2                      // true - same case label
value1.hasSameLabel(as: value2)       // true - same case label
```

Enum values can also be compared directly with `CaseLabel` values using `~=`:

```swift
value1 ~= .intValue     // true
value1 ~= .stringValue  // false
```

### Extending Collections

Case labels work well with generic constraints on `CaseLabeled`:

```swift
@CaseLabeled
enum MyEnum: Hashable {
    case intValue(Int)
    case stringValue(string: String)
}

extension Set where Element: CaseLabeled {
    func removing(_ labeled: Element.CaseLabel) -> Self {
        filter { $0.caseLabel != labeled }
    }
}

let values: Set<MyEnum> = [
    .stringValue(string: "Text1"),
    .intValue(1),
    .intValue(2),
    .stringValue(string: "Text2"),
]

let filtered = values.removing(.intValue)
// Only stringValue cases remain
```

## Limitations

The `@CaseLabeled` macro cannot be used on `private` enums nested inside another type. The macro generates a protocol conformance extension at file scope, where a truly `private` nested type is not visible. The following code will not compile:

```swift
struct Container {
    @CaseLabeled
    private enum MyEnum {
        case intValue(Int)
        case stringValue(string: String)
    }
}
```

The same applies to enums in `private` extensions:

```swift
private extension Namespace {
    @CaseLabeled
    enum MyEnum {
        case intValue(Int)
        case stringValue(string: String)
    }
}
```

As a workaround, you can declare the `CaseLabeled` conformance directly on the enum. The macro detects the existing conformance and skips generating the extension:

```swift
struct Container {
    @CaseLabeled
    private enum MyEnum: CaseLabeled {
        case intValue(Int)
        case stringValue(string: String)
    }
}
```

## Requirements

- Swift 6.0+
- macOS 13+, iOS 16+, tvOS 16+, watchOS 9+, visionOS 1+

## Installation

Add the package dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/wiedem/enum-case-labeling", .upToNextMajor(from: "2.0.0")),
]
```

Then add `"EnumCaseLabeling"` to your target's dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "EnumCaseLabeling", package: "enum-case-labeling"),
    ]
)
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE.txt) file for details.
