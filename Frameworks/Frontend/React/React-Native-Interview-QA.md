# React Native Interview Questions & Answers

## 1. What is React Native and how does it differ from React?

**Answer:**
React Native is a framework for building native mobile applications (iOS and Android) using JavaScript and React. React targets the web (DOM); React Native targets native mobile UI components.

- **React**: Renders to HTML/DOM in the browser.
- **React Native**: Renders to native views (e.g. `UIView`, `android.view.View`) via a bridge. No web view by default.
- Same component model, state, and props; different primitives (`View`, `Text`, `Image` instead of `div`, `span`, `img`).

---

## 2. What is the React Native bridge?

**Answer:**
The bridge is the layer that allows JavaScript code to communicate with native (Java/Kotlin on Android, Objective-C/Swift on iOS) code. JS runs in a separate thread and sends serialized messages (e.g. “create View with these props”) to the native side. Asynchronous and batched for performance.

> [!TIP]
> **Antigravity Tip**: In the **new architecture**, the Bridge is replaced by **JSI (JavaScript Interface)**. JSI allows the JS engine to hold a reference to C++ "Host Objects," enabling **synchronous** calls between JS and Native. This eliminates the JSON serialization overhead, which was the primary cause of lag in complex animations and high-frequency events like scrolling.

---

## 3. What are the main components in React Native?

**Answer:**
- **View** – Container (like `div`), supports layout (flexbox), touch, accessibility.
- **Text** – All text must be inside `<Text>` (unlike web).
- **Image** / **ImageBackground** – Images; local or remote (require() or uri).
- **ScrollView** – Scrollable container (vertical/horizontal).
- **FlatList** / **SectionList** – Virtualized lists for long data (performance).
- **TextInput** – Single/multiline input.
- **TouchableOpacity**, **Pressable** – Touch handling and feedback.
- **SafeAreaView** – Respects notches and safe areas on devices.

---

## 4. How does styling work in React Native?

**Answer:**
No CSS files. Style with JavaScript objects using **StyleSheet.create()**:

- **Flexbox** by default (no float, no grid like CSS Grid).
- **No units** – dimensions are unitless (density-independent pixels).
- **StyleSheet.create()** for performance and validation.
- **Platform-specific**: `Platform.OS === 'ios'` or `Platform.select({ ios: {}, android: {} })`.
- **Dimensions**: `Dimensions.get('window')` or `useWindowDimensions()` for responsive layouts.

---

## 5. What is the difference between FlatList and ScrollView?

**Answer:**
- **ScrollView**: Renders all children at once. Good for small, static content. Large lists cause performance issues and high memory use.
- **FlatList**: Virtualized – only renders visible items (and a small buffer). Uses `data` and `renderItem`, supports `keyExtractor`, `getItemLayout` (for fixed height), `initialNumToRender`, etc. Use for long lists. **SectionList** for sectioned data.

---

## 6. How do you handle navigation in React Native?

**Answer:**
Navigation is not built-in. Common libraries:

- **React Navigation** (most popular): Stack, Tab, Drawer navigators; deep linking, headers, params.
- **React Native Navigation** (Wix): Native stack per screen, high performance.
- **Expo Router**: File-based routing on top of React Navigation (Expo projects).

Concepts: screens, params, nesting, linking, and (with React Navigation) custom headers and gestures.

---

## 7. What are Native Modules and when do you use them?

**Answer:**
Native modules are pieces of native code (Java/Kotlin, Objective-C/Swift) exposed to JavaScript so you can use platform APIs not available in JS (e.g. Bluetooth, biometrics, custom SDKs). You implement the module on native side and expose methods/events to JS via the bridge (or JSI in the new architecture). Use when:
- No existing JS library supports the API.
- You need maximum performance for heavy native work.
- You’re integrating a native SDK.

> [!TIP]
> **Antigravity Tip**: Mention **TurboModules** (part of the New Architecture). Unlike legacy Native Modules which are initialized at app startup (slowing down launch time), TurboModules are **lazy-loaded** only when first used and are strongly typed via **Codegen**, reducing the "undefined is not a function" errors when crossing the JS-Native boundary.

---

## 8. What is Metro and what is it used for?

**Answer:**
**Metro** is the default bundler for React Native. It:
- Bundles JS (and assets) for development and production.
- Supports fast refresh (HMR-style) during development.
- Transforms JS/TS/JSX with Babel.
- Can be configured (e.g. resolver, transformer) in `metro.config.js`.

---

## 9. How do you debug a React Native app?

**Answer:**
- **Chrome DevTools**: Legacy debugging (no longer default in new RN).
- **Flipper**: Network, layout, logs, Redux, and plugins.
- **React DevTools**: Inspect component tree and props/state.
- **Safari (iOS)** / **Chrome (Android)**: For JS debugging.
- **Console logs**: `console.log`; in release, use a crash/reporting service.
- **React Native Debugger**: Standalone app combining React DevTools and Chrome DevTools.

---

## 10. What is the difference between state and props?

**Answer:**
Same idea as in React:
- **Props**: Passed from parent to child; read-only in the child. Used for configuration and data flow down.
- **State**: Data owned and updated inside the component; triggers re-renders when updated. Use **useState** or **useReducer** in function components. For global/shared state: Context, Redux, Zustand, etc.

---

## 11. How do you optimize React Native performance?

**Answer:**
- Use **FlatList** (or SectionList) with `keyExtractor`, `getItemLayout` when item height is fixed, `initialNumToRender`, `maxToRenderPerBatch`, `windowSize`.
- **Memoize** components with **React.memo** and callbacks with **useCallback** to avoid unnecessary re-renders.
- Avoid heavy work on the JS thread (move to native or worker if needed).
- **Image**: Use appropriate size, cache (e.g. react-native-fast-image), consider format (WebP).
- **Hermes**: Enable Hermes engine for faster startup and lower memory.
- **New Architecture**: Use Fabric + TurboModules when possible for better bridge performance.
- Use **InteractionManager.runAfterInteractions** for non-urgent work after animations.

> [!TIP]
> **Antigravity Tip**: When discussing performance, mention **Fabric**, the new concurrent renderer. It allows React to prioritize UI updates and handles "off-screen" rendering more efficiently. At BrandOS (hypothetically), we would use Fabric to ensure that heavy data processing in the background doesn't drop frames during a user's pull-to-refresh animation.

---

## 12. What is Hermes?

**Answer:**
**Hermes** is a JavaScript engine optimized for React Native (by Meta). It:
- Improves startup time (bytecode precompilation).
- Reduces memory usage.
- Is the default engine in new React Native projects. You enable it in `android/app/build.gradle` and in iOS project settings.

---

## 13. How do you handle platform-specific code?

**Answer:**
- **Platform.OS**: `Platform.OS === 'ios'` or `'android'`.
- **Platform.select()**: `Platform.select({ ios: { padding: 10 }, android: { padding: 12 } })`.
- **File extensions**: `Button.ios.js` and `Button.android.js` – Metro resolves the right one.
- **Conditional require**: `const Component = require('./Component.' + Platform.OS);`

---

## 14. What are the main differences between React Native and Flutter?

**Answer:**
- **Language**: RN uses JavaScript/TypeScript; Flutter uses Dart.
- **Rendering**: RN uses native components via the bridge/JSI; Flutter draws with Skia (custom engine), so UI looks consistent but is not “native” widgets.
- **Ecosystem**: RN uses npm, React ecosystem; Flutter has its own packages.
- **Performance**: Flutter can be more predictable (no bridge); RN’s new architecture narrows the gap.
- **Adoption**: RN has a larger JS/React talent pool; Flutter is strong in mobile-first teams.

---

## 15. How do you pass data between screens?

**Answer:**
- **React Navigation**: `navigation.navigate('Screen', { id: 1 })` and `route.params` in the target screen. Or use **params** and **setParams**.
- **Context**: For shared data across the tree.
- **State management**: Redux, Zustand, Jotai – global store read/updated from any screen.
- **Callbacks**: Pass a callback from parent to child (e.g. from list to detail and back) for simple cases.

---

## Quick reference

| Topic            | Key point                                              |
|------------------|--------------------------------------------------------|
| Bridge           | JS ↔ native async messaging; JSI in new architecture  |
| Lists            | Use FlatList/SectionList for long lists                |
| Styling          | StyleSheet, flexbox, no CSS units                      |
| Navigation       | React Navigation (stack/tab/drawer) or Expo Router     |
| Performance      | FlatList, Hermes, memo, avoid heavy work on JS thread |
| Platform-specific| Platform.OS, Platform.select(), .ios.js / .android.js   |
