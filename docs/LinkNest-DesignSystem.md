# LinkNest Design System

## 1. نظام التصميم (Design System)

### الألوان (Colors)
```dart
// Primary Colors
static const Color primaryColor = Color(0xFF0077B5); // LinkedIn Blue
static const Color primaryForeground = Color(0xFFFFFFFF);
static const Color secondary = Color(0xFF0A66C2);

// Semantic Colors
static const Color accent = Color(0xFF22C55E);
static const Color destructive = Color(0xFFEF4444);
static const Color warning = Color(0xFFF59E0B);
static const Color info = Color(0xFF3B82F6);

// Background Colors
static const Color backgroundColor = Color(0xFFF8FAFC);
static const Color cardColor = Color(0xFFFFFFFF);
static const Color mutedColor = Color(0xFFF3F4F6);

// Border & Text Colors
static const Color borderColor = Color(0xFFE5E7EB);
static const Color foregroundColor = Color(0xFF0F172A);
static const Color mutedForeground = Color(0xFF6B7280);
```

### التايبوجرافي (Typography)
```dart
// Font Weights
static const FontWeight light = FontWeight.w300;
static const FontWeight regular = FontWeight.w400;
static const FontWeight medium = FontWeight.w500;
static const FontWeight semibold = FontWeight.w600;
static const FontWeight bold = FontWeight.w700;

// Text Styles
static const TextStyle displayLarge = TextStyle(fontSize: 24, height: 1.33, fontWeight: bold);
static const TextStyle headingLarge = TextStyle(fontSize: 20, height: 1.4, fontWeight: semibold);
static const TextStyle titleMedium = TextStyle(fontSize: 16, height: 1.5, fontWeight: semibold);
static const TextStyle bodyMedium = TextStyle(fontSize: 14, height: 1.43, fontWeight: regular);
static const TextStyle captionMedium = TextStyle(fontSize: 12, height: 1.33, fontWeight: medium);
```

### المسافات (Spacing)
```dart
static const double spacing1 = 2.0;
static const double spacing2 = 4.0;
static const double spacing3 = 8.0;
static const double spacing4 = 12.0;
static const double spacing5 = 16.0;
static const double spacing6 = 20.0;
static const double spacing7 = 24.0;
```

### الحواف والظلال (Borders & Shadows)
```dart
// Border Radius
static const double radiusSm = 6.0;
static const double radiusMd = 8.0;
static const double radiusLg = 12.0;

// Shadows
static const List<BoxShadow> subtleShadow = [
  BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
];
```

## 2. الذكاء الاصطناعي (AI Features)

### الوظائف الأساسية
- **اقتراح Tags**: تحليل عنوان ومحتوى الرابط لاقتراح tags مناسبة
- **تلخيص Highlights**: استخراج النقاط المهمة من محتوى LinkedIn
- **Smart Reminders**: اقتراح أوقات تذكير بناءً على الأولوية والنوع

### تفاعل المستخدم
- زر "Suggest Tags" في قسم Tags
- زر "Auto Highlights" في قسم Highlights  
- خيار "Smart Reminder" عند إضافة تذكير

## 3. مكونات واجهة المستخدم (UI Components)

### SectionCard
```dart
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final List<Widget>? actions;
  
  // Consistent styling for all sections
}
```

### حالات المكونات (Component States)
- **Default**: الحالة العادية
- **Hover**: عند التمرير
- **Focus**: عند التركيز
- **Disabled**: عند التعطيل
- **Error**: عند وجود خطأ

## 4. حالات التطبيق (App States)

### BLoC State Management
- PostBloc: إدارة المنشورات
- FolderBloc: إدارة المجلدات
- TagBloc: إدارة العلامات
- ReminderBloc: إدارة التذكيرات

### مؤشرات الحالة
- LinearProgressIndicator للتحديثات الرئيسية
- CircularProgressIndicator للعمليات المحلية
- Skeleton loaders للمحتوى

## 5. حالات التحميل (Loading States)

### أنواع التحميل
- **محلي**: <200ms - Hive operations
- **شبكة**: 500ms-2s - External requests
- **AI**: 1-3s - AI processing

### مؤشرات التحميل
- Shimmer effects للبطاقات
- Progress indicators للعمليات الطويلة
- Skeleton screens للمحتوى الكبير

## 6. حالات النجاح (Success States)

### رسائل النجاح
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Operation completed successfully!'),
    backgroundColor: AppTheme.accent,
    duration: Duration(seconds: 2),
  ),
);
```

## 7. معالجة الأخطاء (Error Handling)

### تصنيف الأخطاء
- **Validation**: أخطاء التحقق من البيانات
- **Storage**: أخطاء قاعدة البيانات المحلية
- **Network**: أخطاء الشبكة
- **AI**: أخطاء معالجة الذكاء الاصطناعي

### عرض الأخطاء
- Inline validation للحقول
- Snackbar للأخطاء العامة
- Dialog للأخطاء الحرجة

## 8. حالة الاتصال (Online/Offline)

### Online Features
- فتح الروابط في المتصفح
- مزامنة البيانات
- ميزات الذكاء الاصطناعي

### Offline Features  
- عرض وتعديل البيانات المحلية
- إضافة tags وhighlights
- تعيين تذكيرات محلية

### مؤشرات الاتصال
- Toast message عند استعادة الاتصال
- Disabled state للميزات المعتمدة على الشبكة

## 9. إرشادات التطبيق

### مبادئ التصميم
1. **البساطة**: تجنب التعقيد غير الضروري
2. **الوضوح**: استخدم تباين عالي للقراءة
3. **الاتساق**: طبق نفس الأنماط في كل مكان
4. **الاستجابة**: ردود فعل فورية للتفاعلات

### أفضل الممارسات
- استخدم spacing ثابت (8px grid)
- اجعل الأيقونات 16-20px
- استخدم animations مدتها 150-300ms
- طبق focus states واضحة للوصولية
