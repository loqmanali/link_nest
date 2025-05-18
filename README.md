# LinkNest

LinkNest is a simple offline Flutter application for storing and organizing LinkedIn posts. It allows users to save, categorize, and prioritize important LinkedIn content without requiring any cloud services.

## 🎯 Features

- Save LinkedIn post links with custom titles and notes
- Categorize posts by type (Job, Article, Tip, Opportunity, Other)
- Assign priority levels (High, Medium, Low)
- Search and filter saved posts
- 100% offline - all data stored locally on your device
- No account or sign-in required

## 📱 Screenshots

(Add screenshots once the app is built)

## 🧱 App Architecture

### Data Layer

- **Local Storage**: Hive database for offline storage
- **State Management**: BLoC pattern with flutter_bloc
- **Dependencies**: SharedPreferences for app settings

### UI Layer

- Material Design UI components
- Flutter Hooks for efficient state management
- Custom widgets for consistent styling

## 🔧 Setup Instructions

1. **Clone the repository**

   ``
   git clone https://github.com/yourusername/link_nest.git
   cd link_nest
   ``

2. **Install dependencies**

   ``
   flutter pub get
   ``

3. **Generate Hive adapters**

   ``
   flutter pub run build_runner build --delete-conflicting-outputs
   ``

4. **Run the app**

   ``
   flutter run
   ``

## 📦 Dependencies

- flutter_bloc: State management
- flutter_hooks: UI state utilities
- hive & hive_flutter: Local database
- url_launcher: Opening links in browser
- intl: Date formatting
- equatable: Value comparison
- path_provider: File system access

## 🚀 Getting Started

To use the app:

1. Click the "+" button to add a new LinkedIn post
2. Paste the LinkedIn post URL
3. Add a title/note to help you remember why you saved it
4. Select the post type and priority
5. Save the post
6. Use the filter options to organize your saved posts

## 🌟 Arabic Explanation / شرح باللغة العربية

**لينك نست** هو تطبيق فلاتر بسيط يعمل بدون إنترنت مخصص لحفظ وتنظيم منشورات لينكد إن. يسمح للمستخدمين بحفظ الروابط المهمة وتصنيفها وتحديد أولوياتها بدون الحاجة لأي خدمات سحابية.

### المميزات الأساسية

- حفظ روابط منشورات لينكد إن مع عناوين مخصصة وملاحظات
- تصنيف المنشورات حسب النوع (وظيفة، مقالة، نصيحة، فرصة، أخرى)
- تحديد مستويات الأولوية (عالية، متوسطة، منخفضة)
- البحث والتصفية في المنشورات المحفوظة
- يعمل بالكامل بدون إنترنت - كل البيانات مخزنة محلياً على جهازك
- لا يتطلب حساب أو تسجيل دخول

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.
