# last_park_app

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# admob 관련 버그 해결 방법
## 현상 : 실행시 제대로 실행이 안됨
## 해결 방법 : Podfile에 아래 문구 작성
  # Try adding this
  pod 'Google-Mobile-Ads-SDK', '~> 7.69.0'