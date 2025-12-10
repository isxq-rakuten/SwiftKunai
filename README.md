# SwiftKunai

[![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B-blue.svg)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

Elegant SwiftUI Component Library - A collection of beautifully crafted, reusable SwiftUI components.

## Features

### StaticTabView

A custom tab view with a classic tab bar style that provides a better user experience:

- 🎨 **Classic Tab Bar Style** - No floating glass effect (iOS 26+), maintains traditional aesthetic
- ⚡ **Instant Switching** - No zoom animation, tabs switch immediately
- ⌨️ **Keyboard Aware** - Tab bar stays fixed at the bottom when keyboard appears
- 🎯 **Customizable Tab Items** - Support both default (icon + title) and fully custom tab bar items
- 🛠️ **Result Builder Support** - Declarative syntax with `@StaticTabContentBuilder`

## Requirements

- iOS 17.0+
- Swift 6.2+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add SwiftKunai to your project using Swift Package Manager.

#### In Xcode:

1. Go to **File > Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/isxq-rakuten/SwiftKunai.git
   ```
3. Select the version rule and click **Add Package**

#### In Package.swift:

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/isxq-rakuten/SwiftKunai.git", from: "1.0.0")
]
```

Then add `SwiftKunai` to your target's dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["SwiftKunai"]
)
```

## Usage

### Basic Usage

```swift
import SwiftUI
import SwiftKunai

enum Tab {
    case home
    case settings
}

struct ContentView: View {
    @State private var selection: Tab = .home

    var body: some View {
        StaticTabView(selection: $selection) {
            StaticTab("Home", systemImage: "house", value: .home) {
                HomeView()
            }
            StaticTab("Settings", systemImage: "gear", value: .settings) {
                SettingsView()
            }
        }
    }
}
```

### Custom Tab Items

Create fully customized tab bar items with the custom initializer:

```swift
StaticTabView(selection: $selection) {
    StaticTab(value: .home) {
        HomeView()
    } tabItem: { isSelected in
        VStack {
            Image(systemName: isSelected ? "house.fill" : "house")
                .font(.title2)
            Text("Home")
                .font(.caption2)
        }
        .foregroundColor(isSelected ? .blue : .gray)
    }
    
    StaticTab(value: .settings) {
        SettingsView()
    } tabItem: { isSelected in
        VStack {
            Image(systemName: isSelected ? "gearshape.fill" : "gearshape")
                .font(.title2)
            Text("Settings")
                .font(.caption2)
        }
        .foregroundColor(isSelected ? .blue : .gray)
    }
}
```

### Using TabContentBuilder

For better code organization, use `@StaticTabContentBuilder` to separate tab definitions:

```swift
struct ContentView: View {
    @State private var selection: Tab = .home

    var body: some View {
        StaticTabView(selection: $selection) {
            tabs
        }
    }

    @StaticTabContentBuilder<Tab>
    private var tabs: some StaticTabContent<Tab> {
        homeTab
        searchTab
        profileTab
    }

    private var homeTab: some StaticTabContent<Tab> {
        StaticTab("Home", systemImage: "house", value: .home) {
            HomeView()
        }
    }

    private var searchTab: some StaticTabContent<Tab> {
        StaticTab("Search", systemImage: "magnifyingglass", value: .search) {
            SearchView()
        }
    }

    private var profileTab: some StaticTabContent<Tab> {
        StaticTab("Profile", systemImage: "person", value: .profile) {
            ProfileView()
        }
    }
}
```

## API Reference

### StaticTabView

| Parameter | Type | Description |
|-----------|------|-------------|
| `selection` | `Binding<SelectionValue>` | A binding to the currently selected tab value |
| `content` | `@StaticTabContentBuilder` | A closure that returns the tab content |

### StaticTab

#### Default Initializer

```swift
StaticTab(_ title: String, systemImage: String, value: SelectionValue, content: () -> Content)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | `String` | The text label displayed below the icon |
| `systemImage` | `String` | The SF Symbol name for the tab icon |
| `value` | `SelectionValue` | The selection value for this tab |
| `content` | `() -> Content` | The view content displayed when tab is selected |

#### Custom Tab Item Initializer

```swift
StaticTab(value: SelectionValue, content: () -> Content, tabItem: (Bool) -> TabItem)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | `SelectionValue` | The selection value for this tab |
| `content` | `() -> Content` | The view content displayed when tab is selected |
| `tabItem` | `(Bool) -> TabItem` | A closure that returns the custom tab bar item view. The boolean parameter indicates whether the tab is selected |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created with ❤️ by isxq-rakuten
