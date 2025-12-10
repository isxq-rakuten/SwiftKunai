//
//  StaticTabView.swift
//  SwiftKunai
//
//  Created by Shen, Xiaoqiang | CNTD on 2025/12/10.
//

import SwiftUI

// MARK: - StaticTabContent Protocol

/// A protocol that represents tab content that can be displayed in a `StaticTabView`.
///
/// Conform to this protocol to create custom tab content types.
/// The built-in `StaticTab` type already conforms to this protocol.
protocol StaticTabContent<SelectionValue> {
    associatedtype SelectionValue: Hashable
    var tabs: [AnyStaticTab<SelectionValue>] { get }
}

// MARK: - StaticTab

/// A single tab item that can be displayed in a `StaticTabView`.
///
/// `StaticTab` supports two initialization modes:
/// - **Default mode**: Uses a system image and title for the tab bar item
/// - **Custom mode**: Uses a custom view for the tab bar item
///
/// ## Default Tab Item
/// ```swift
/// StaticTab("Home", systemImage: "house", value: .home) {
///     HomeView()
/// }
/// ```
///
/// ## Custom Tab Item
/// ```swift
/// StaticTab(value: .home) {
///     HomeView()
/// } tabItem: { isSelected in
///     VStack {
///         Image(systemName: isSelected ? "house.fill" : "house")
///         Text("Home")
///     }
///     .foregroundColor(isSelected ? .blue : .gray)
/// }
/// ```
struct StaticTab<SelectionValue: Hashable, Content: View, TabItem: View>: StaticTabContent, Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let value: SelectionValue
    let content: Content
    let customTabItem: ((Bool) -> TabItem)?
    
    var tabs: [AnyStaticTab<SelectionValue>] {
        [AnyStaticTab(self)]
    }
    
    /// Default tab item (icon + title)
    init(
        _ title: String,
        systemImage: String,
        value: SelectionValue,
        @ViewBuilder content: () -> Content
    ) where TabItem == EmptyView {
        self.title = title
        self.systemImage = systemImage
        self.value = value
        self.content = content()
        self.customTabItem = nil
    }
    
    /// Custom tab item view
    init(
        value: SelectionValue,
        @ViewBuilder content: () -> Content,
        @ViewBuilder tabItem: @escaping (_ isSelected: Bool) -> TabItem
    ) {
        self.title = ""
        self.systemImage = ""
        self.value = value
        self.content = content()
        self.customTabItem = tabItem
    }
}

// MARK: - StaticTabGroup

/// A container that groups multiple tabs together.
///
/// This type is used internally by `StaticTabContentBuilder` to combine multiple `StaticTab` instances.
/// You typically don't need to create this type directly.
struct StaticTabGroup<SelectionValue: Hashable>: StaticTabContent {
    let tabs: [AnyStaticTab<SelectionValue>]
    
    init(_ tabs: [AnyStaticTab<SelectionValue>]) {
        self.tabs = tabs
    }
}

// MARK: - StaticTabContentBuilder

/// A result builder that constructs tab content from multiple `StaticTab` instances.
///
/// Use this builder with the `@StaticTabContentBuilder` attribute to create tab content declaratively.
///
/// ```swift
/// @StaticTabContentBuilder<MyTab>
/// var tabs: some StaticTabContent<MyTab> {
///     homeTab
///     settingsTab
/// }
/// ```
@resultBuilder
struct StaticTabContentBuilder<SelectionValue: Hashable> {
    static func buildBlock<T: StaticTabContent>(_ content: T) -> T where T.SelectionValue == SelectionValue {
        content
    }
    
    static func buildBlock<T0: StaticTabContent, T1: StaticTabContent>(
        _ t0: T0,
        _ t1: T1
    ) -> StaticTabGroup<SelectionValue> where T0.SelectionValue == SelectionValue, T1.SelectionValue == SelectionValue {
        StaticTabGroup(t0.tabs + t1.tabs)
    }
    
    static func buildBlock<T0: StaticTabContent, T1: StaticTabContent, T2: StaticTabContent>(
        _ t0: T0,
        _ t1: T1,
        _ t2: T2
    ) -> StaticTabGroup<SelectionValue> where T0.SelectionValue == SelectionValue, T1.SelectionValue == SelectionValue, T2.SelectionValue == SelectionValue {
        StaticTabGroup(t0.tabs + t1.tabs + t2.tabs)
    }
    
    static func buildBlock<T0: StaticTabContent, T1: StaticTabContent, T2: StaticTabContent, T3: StaticTabContent>(
        _ t0: T0,
        _ t1: T1,
        _ t2: T2,
        _ t3: T3
    ) -> StaticTabGroup<SelectionValue> where T0.SelectionValue == SelectionValue, T1.SelectionValue == SelectionValue, T2.SelectionValue == SelectionValue, T3.SelectionValue == SelectionValue {
        StaticTabGroup(t0.tabs + t1.tabs + t2.tabs + t3.tabs)
    }
    
    static func buildBlock<T0: StaticTabContent, T1: StaticTabContent, T2: StaticTabContent, T3: StaticTabContent, T4: StaticTabContent>(
        _ t0: T0,
        _ t1: T1,
        _ t2: T2,
        _ t3: T3,
        _ t4: T4
    ) -> StaticTabGroup<SelectionValue> where T0.SelectionValue == SelectionValue, T1.SelectionValue == SelectionValue, T2.SelectionValue == SelectionValue, T3.SelectionValue == SelectionValue, T4.SelectionValue == SelectionValue {
        StaticTabGroup(t0.tabs + t1.tabs + t2.tabs + t3.tabs + t4.tabs)
    }
}

// MARK: - AnyStaticTab

/// A type-erased wrapper for `StaticTab` that allows storing tabs with different content types.
///
/// This type is used internally by `StaticTabView` and `StaticTabContentBuilder`.
/// You typically don't need to interact with this type directly.
struct AnyStaticTab<SelectionValue: Hashable>: Identifiable {
    let id: UUID
    let title: String
    let systemImage: String
    let value: SelectionValue
    let content: AnyView
    let customTabItem: ((Bool) -> AnyView)?
    
    init<Content: View, TabItem: View>(_ tab: StaticTab<SelectionValue, Content, TabItem>) {
        self.id = tab.id
        self.title = tab.title
        self.systemImage = tab.systemImage
        self.value = tab.value
        self.content = AnyView(tab.content)
        if let customTabItem = tab.customTabItem {
            self.customTabItem = { isSelected in AnyView(customTabItem(isSelected)) }
        } else {
            self.customTabItem = nil
        }
    }
}

// MARK: - StaticTabView

/// A custom tab view with a classic tab bar style that doesn't move with the keyboard.
///
/// `StaticTabView` provides a tab-based navigation interface similar to SwiftUI's `TabView`,
/// but with the following features:
/// - **Classic tab bar style**: No floating glass effect (iOS 26+)
/// - **No zoom animation**: Instant tab switching without transition animations
/// - **Keyboard-aware**: Tab bar stays fixed at the bottom when keyboard appears
/// - **Customizable tab items**: Support both default and custom tab bar items
///
/// ## Basic Usage
/// ```swift
/// struct ContentView: View {
///     @State private var selection: Tab = .home
///
///     var body: some View {
///         StaticTabView(selection: $selection) {
///             StaticTab("Home", systemImage: "house", value: .home) {
///                 HomeView()
///             }
///             StaticTab("Settings", systemImage: "gear", value: .settings) {
///                 SettingsView()
///             }
///         }
///     }
/// }
/// ```
///
/// ## Using TabContentBuilder
/// ```swift
/// struct ContentView: View {
///     @State private var selection: Tab = .home
///
///     var body: some View {
///         StaticTabView(selection: $selection) {
///             tabs
///         }
///     }
///
///     @StaticTabContentBuilder<Tab>
///     private var tabs: some StaticTabContent<Tab> {
///         homeTab
///         settingsTab
///     }
///
///     private var homeTab: some StaticTabContent<Tab> {
///         StaticTab("Home", systemImage: "house", value: .home) {
///             HomeView()
///         }
///     }
/// }
/// ```
struct StaticTabView<SelectionValue: Hashable, Content: StaticTabContent>: View where Content.SelectionValue == SelectionValue {
    @Binding var selection: SelectionValue
    let content: Content
    
    @State private var tabBarHeight: CGFloat = 0
    @State private var isKeyboardVisible: Bool = false
    
    /// Creates a static tab view with the specified selection binding and tab content.
    ///
    /// - Parameters:
    ///   - selection: A binding to the currently selected tab value.
    ///   - content: A closure that returns the tab content using `StaticTabContentBuilder`.
    init(
        selection: Binding<SelectionValue>,
        @StaticTabContentBuilder<SelectionValue> content: () -> Content
    ) {
        self._selection = selection
        self.content = content()
    }
    
    private var tabs: [AnyStaticTab<SelectionValue>] {
        content.tabs
    }
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                ZStack {
                    ForEach(tabs) { tab in
                        tab.content
                            .opacity(selection == tab.value ? 1 : 0)
                    }
                }
                .safeAreaPadding(.bottom, isKeyboardVisible ? 0 : tabBarHeight)
                
                VStack {
                    Spacer()
                    tabBar
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear { tabBarHeight = geo.size.height }
                                    .onChange(of: geo.size.height) { _, newValue in
                                        tabBarHeight = newValue
                                    }
                            }
                        )
                }
                .ignoresSafeArea(.keyboard)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.smooth(duration: 0.25)) {
                isKeyboardVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.smooth(duration: 0.25)) {
                isKeyboardVisible = false
            }
        }
    }
    
    private var tabBar: some View {
        HStack {
            ForEach(tabs) { tab in
                Button {
                    selection = tab.value
                } label: {
                    if let customTabItem = tab.customTabItem {
                        customTabItem(selection == tab.value)
                            .frame(maxWidth: .infinity)
                    } else {
                        DefaultTabItemView(
                            title: tab.title,
                            systemImage: tab.systemImage,
                            isSelected: selection == tab.value
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            Rectangle()
                .fill(.bar)
                .shadow(color: .black.opacity(0.1), radius: 0.5, y: -0.5)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - DefaultTabItemView

/// The default tab bar item view used by `StaticTabView`.
///
/// This view displays a system image above a title text, with color changes based on selection state.
/// You can use this as a reference when creating custom tab items.
///
/// - Parameters:
///   - title: The text label displayed below the icon.
///   - systemImage: The SF Symbol name for the tab icon.
///   - isSelected: Whether the tab is currently selected.
struct DefaultTabItemView: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 22))
            Text(title)
                .font(.caption2)
        }
        .foregroundColor(isSelected ? .accentColor : .gray)
    }
}


#Preview {
    @Previewable @State var selection = 0
    StaticTabView(selection: $selection) {
        StaticTab("Home", systemImage: "house", value: 0) {
            Text("Home")
        }
        StaticTab("Settings", systemImage: "gear", value: 1) {
            Text("Settings")
        }
    }
}
