# EnumCaseLabeling

**EnumCaseLabeling** is an open source package providing macros and types to extend enumerations having cases with associated values.

## Getting Started

Swift 5.10 is required as a minimum version.

To use the `EnumCaseLabeling` library in a SwiftPM project, add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/wiedem/enum-case-labeling", .upToNextMajor(from: "1.0.0")),
```

Include `"EnumCaseLabeling"` as a dependency for your executable target:

```swift
dependencies: [
    .product(name: "EnumCaseLabeling", package: "enum-case-labeling"),
]
```

## Usage

Start by importing the module into your Swift code with `import EnumCaseLabeling`.

### Extend Enumerations with the `CaseLabeled` Macro
Apply the macro `CaseLabeled` to your enumeration:

```swift
@CaseLabeled
enum MyEnum: Equatable {
    case intValue(Int)
    case stringValue(string: String)
}
```

The macro automatically declares a `CaseLabel` enumeration conforming to the `Equatable` protocol without associated values.
A `caseLabel` property returns a value of `CaseLabel` for each case of the enumeration.

### Using Case Labels
Case labels of enumeration values can be used to identify values with an identical label, even if their associated values are not identical:
```swift
let value1: MyEnum = .intValue(1)
let value2: MyEnum = .intValue(2)

// value1 and value2 are not equal because their associated values are not equal ...
print("value1 and value2 are equal: \(value1 == value2)")
// ... but they share a common case label
print("value1 and value2 have a common case label: \(value1.caseLabel == value2.caseLabel)")
```

The `CaseLabeled` protocol also provides a convenience operator `~=` for the label comparison:
```swift
print("value1 and value2 have a common case label: \(value1 ~= value2)")
```

Enumeration values can also be directly compared with case label values:
```swift
print("value1 is an 'intValue': \(value1 ~= .intValue)")
```

This makes it possible, for example, to easily extend collections with methods that make use of the labels:

```swift
@CaseLabeled
enum MyEnum: Hashable {
    case intValue(Int)
    case stringValue(string: String)
}

extension Set where Element: CaseLabeled {
    func remove(_ labeled: Element.CaseLabel) -> Self {
        filter {
            $0.caseLabel != labeled
        }
    }
}

let values: Set<MyEnum> = [
    .stringValue(string: "Text1"),
    .intValue(1),
    .intValue(2),
    .stringValue(string: "Text2"),
]

// This removes all enumeration values with the `intValue` label.
let filtered = values.remove(.intValue)
```

### Notes and Limitations

#### Access Control
The added code for `CaseLabel` and `caseLabel` use a `public` access level even when the extended enum itself has a `private` access level.

The automatically added protocol conformance to `CaseIterable` does not work if the enumeration is private and is itself declared in a private namespace.
The following code will therefore not compile:
```swift
private extension Namespace {
    @CaseLabeled
    private enum MyEnum: Hashable {
        case intValue(Int)
        case stringValue(string: String)
    }
}
```
