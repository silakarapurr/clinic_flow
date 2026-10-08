# ClinicFlow — Klinik Yönetim & Randevu Takip Sistemi (iOS)

ClinicFlow; küçük ve orta ölçekli klinikler (diş klinikleri, psikologlar, fizyoterapistler, estetik merkezleri) için geliştirilmiş, **production-ready**, yüksek güvenlikli ve Apple App Store gereksinimlerine tam uyumlu modern bir mobil klinik yönetim uygulamasıdır.

---

## 1. Mimari & Teknoloji Yığını

* **Framework:** Flutter 3.x (iOS 15.0+ hedefli)
* **Dil:** Dart 3.x (Sealed Classes, Records & Pattern Matching)
* **Mimari:** Feature-First Pragmatic Clean Architecture
* **State Management:** `flutter_bloc` (Bloc & Cubit)
* **Bağımlılık Enjeksiyonu (DI):** `get_it`
* **Navigasyon:** `go_router` & iOS Shell Navigation
* **Güvenli Depolama:** `flutter_secure_storage` (iOS Keychain `first_unlock_this_device`)
* **Hata Yönetimi:** Merkezi `ErrorHandler` ve `Failure` tipleri (Kullanıcıya teknik exception sızdırmaz)
* **KVKK/Gizlilik Uyumlu Loglama:** BLoC durum geçişlerini loglayan ancak hasta sağlık verilerini gizleyen `AppBlocObserver`
* **App Store Hazırlığı:** iOS Privacy Manifest (`PrivacyInfo.xcprivacy`) ve Guideline 5.1.1(v) uyumlu Hesap Silme akışı

---

## 2. Klasör Yapısı

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp, Theme & MultiBlocProvider
│   ├── app_observer.dart          # KVKK-safe BLoC logging
│   └── shell/
│       └── main_shell_view.dart   # 5-Tab iOS Bottom Navigation Bar
├── core/
│   ├── config/                    # EnvConfig (Compile-time defines)
│   ├── constants/                 # AppStrings (TR), AppConstants
│   ├── di/                        # GetIt servis ve repository kayıtları
│   ├── error/                     # Failure, Exception, ErrorHandler
│   ├── network/                   # SeedData & Backend bağlantısı
│   ├── storage/                   # SecureStorageService (iOS Keychain)
│   └── theme/                     # AppColors, AppTypography, AppSpacing, AppTheme
├── features/
│   ├── auth/                      # Login, Forgot Password, AuthCubit, Session
│   ├── dashboard/                 # KPI sayaçları, bugünün akışı, DashboardCubit
│   ├── appointments/              # Günlük timeline, randevu oluşturma, çakışma kontrolü
│   ├── patients/                  # Arama, hasta listesi, detay, hasta oluşturma
│   ├── doctors/                   # Hekim listesi, çalışma saatleri, seans süreleri
│   └── settings/                  # Profil, klinik bilgileri, Apple zorunlu hesap silme
└── shared/
    ├── models/                    # AppointmentStatus enum & renkleri
    └── widgets/                   # AppButton, AppTextField, AppCard, AppStatusBadge, StateViews
```

---

## 3. Kurulum ve Yerel Çalıştırma (Local Setup)

### Gereksinimler
* macOS (Xcode 15+ kurulu olmalı)
* Flutter SDK (3.19.0 veya üstü)
* iOS Simülatörü

### Adım Adım Başlatma

1. **Depoya gidin:**
   ```bash
   cd ~/.gemini/antigravity/scratch/clinic_flow
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **iOS Platform sarmalayıcılarını oluşturun:**
   ```bash
   flutter create . --org com.clinicflow --platforms ios
   ```

4. **iOS Simülatörünü açın ve uygulamayı çalıştırın:**
   ```bash
   open -a Simulator
   flutter run
   ```

---

## 4. Testleri Çalıştırma

ClinicFlow yüksek test kapsamına sahiptir. Birim, Repository, BLoC ve Widget testlerini çalıştırmak için:

```bash
# Tüm testleri çalıştır
flutter test

# Kod kalitesi ve lint analizi
flutter analyze
```

---

## 5. Çevre Değişkenleri (Environment Variables)

API anahtarları kaynak kod içine **asla gömülmez**. `--dart-define` ile derleme anında enjekte edilir:

```bash
flutter run \
  --dart-define=APP_ENV=production \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-supabase-anon-key
```

---

## 6. App Store Yayını ve Güvenlik Notları

1. **Account Deletion (Guideline 5.1.1(v)):** Apple Reviewers için `Ayarlar -> Hesabımı Sil` akışı eksiksiz uygulanmıştır.
2. **Privacy Manifest:** `ios/Runner/PrivacyInfo.xcprivacy` dosyasında UserDefaults ve kişisel veri tipleri beyan edilmiştir.
3. **Demo Giriş:** Apple Review aşamasında doğrudan hazır demo kimlik bilgileri giriş ekranında doldurulmuş olarak gelir (`dr.zeynep@clinicflow.com` / `123456`).
4. **Çakışma Önleme:** Aynı doktora aynı zaman aralığında birden fazla randevu yazılması durumunda sistem çakışmayı tespit eder ve randevu oluşturulmasını engeller.
