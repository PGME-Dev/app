# 🖼️ Asset Upload Guide for PGME App

This guide will help you upload all the images and assets to the correct folders.

## 📂 Folder Structure

Your project should have these folders:
```
flutter apk/
└── assets/
    ├── images/         ← Upload general images here
    ├── icons/          ← Upload app icons here
    ├── illustrations/  ← Upload onboarding illustrations here
    └── fonts/          ← Upload custom fonts here (optional)
```

## 📥 What to Upload

### 1️⃣ SPLASH SCREEN IMAGES

**Folder:** `assets/images/`

#### splash_pattern.png
- **What it is:** Checkered pattern background for splash screen
- **From your design:** The blue and white block pattern you see in the Splash Screen
- **Size:** 1080 x 1920 pixels (or any 9:16 ratio)
- **Format:** PNG
- **Upload to:** `assets/images/splash_pattern.png`

> **Note:** If you don't have this, the app will show a plain background

---

### 2️⃣ ONBOARDING ILLUSTRATIONS

**Folder:** `assets/illustrations/`

You have 4 onboarding screens. Upload 4 illustration images:

#### onboarding_1.png
- **Screen:** "Welcome to PGME"
- **What to upload:** The illustration showing a person with medical education interface
- **From your design:** Onboarding screen 1 illustration
- **Size:** 600 x 600 pixels minimum
- **Format:** PNG with transparent background
- **Upload to:** `assets/illustrations/onboarding_1.png`

#### onboarding_2.png
- **Screen:** "Learn Subject by Subject"
- **What to upload:** The illustration showing books/educational content
- **From your design:** Onboarding screen 2 illustration
- **Size:** 600 x 600 pixels minimum
- **Format:** PNG with transparent background
- **Upload to:** `assets/illustrations/onboarding_2.png`

#### onboarding_3.png
- **Screen:** "Watch Recorded Lectures"
- **What to upload:** The illustration showing video/laptop with play button
- **From your design:** Onboarding screen 3 illustration
- **Size:** 600 x 600 pixels minimum
- **Format:** PNG with transparent background
- **Upload to:** `assets/illustrations/onboarding_3.png`

#### onboarding_4.png
- **Screen:** "Stay Updated with Live Webinars"
- **What to upload:** The illustration showing broadcast tower/streaming
- **From your design:** Onboarding screen 4 illustration
- **Size:** 600 x 600 pixels minimum
- **Format:** PNG with transparent background
- **Upload to:** `assets/illustrations/onboarding_4.png`

---

### 3️⃣ APP ICON

**Folder:** `assets/icons/`

#### app_icon.png
- **What it is:** Your app launcher icon
- **From your design:** The PGME logo with blue blocks (P icon)
- **Size:** 1024 x 1024 pixels
- **Format:** PNG with transparent background
- **Upload to:** `assets/icons/app_icon.png`

---

### 4️⃣ OTHER IMAGES (Optional)

**Folder:** `assets/images/`

#### flag_india.png (Optional)
- **What it is:** Indian flag for phone number input
- **Size:** 48 x 48 pixels
- **Format:** PNG
- **Upload to:** `assets/images/flag_india.png`
- **Note:** App uses emoji 🇮🇳 if not provided

---

## 🎨 How to Extract Images from Your Design

### If you have Figma/Adobe XD:
1. Select the illustration
2. Right-click → Export
3. Choose PNG format
4. Set 2x or 3x scale for better quality
5. Save with the exact filename mentioned above

### If you have screenshots:
1. Crop the illustration part only (remove text and UI)
2. Use an online tool to remove background (remove.bg)
3. Resize to recommended dimensions
4. Save as PNG

---

## ✅ Upload Checklist

Use VS Code or any file manager to upload:

**Required Images:**
- [ ] `assets/illustrations/onboarding_1.png`
- [ ] `assets/illustrations/onboarding_2.png`
- [ ] `assets/illustrations/onboarding_3.png`
- [ ] `assets/illustrations/onboarding_4.png`
- [ ] `assets/icons/app_icon.png`

**Optional Images:**
- [ ] `assets/images/splash_pattern.png`
- [ ] `assets/images/flag_india.png`

---

## 🚀 After Upload

Once you've uploaded all images:

1. **Verify Upload:**
   - Open VS Code
   - Check the `assets/` folder
   - Ensure all files are there with correct names

2. **Run the app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Test each screen:**
   - Splash screen should show pattern
   - Onboarding screens should show illustrations
   - App should work smoothly

---

## 🎯 Quick Upload Steps (VS Code)

1. Open VS Code
2. Open your project folder: `flutter apk`
3. In the left sidebar, navigate to `assets/illustrations/`
4. Drag and drop your 4 onboarding images
5. Rename them to match:
   - `onboarding_1.png`
   - `onboarding_2.png`
   - `onboarding_3.png`
   - `onboarding_4.png`
6. Navigate to `assets/icons/`
7. Drag and drop your app icon
8. Rename it to `app_icon.png`
9. Done! ✅

---

## ❓ FAQ

**Q: What if I don't have these images yet?**
A: The app will show placeholder icons and colors. It will still work, but won't look as polished.

**Q: Can I use different file names?**
A: No, use the exact names mentioned. The code references these specific filenames.

**Q: What format should images be?**
A: PNG is preferred, especially for illustrations (supports transparency).

**Q: Can images be larger than recommended?**
A: Yes, but they'll increase app size. Optimize images before uploading.

**Q: Do I need to restart the app after uploading?**
A: Yes, run `flutter clean` and restart the app to see new images.

---

## 📧 Need Help?

If images are not showing:
1. Check filename spelling (case-sensitive)
2. Ensure images are in correct folders
3. Run `flutter clean && flutter pub get`
4. Restart the app

---

**You're all set! Upload your images and enjoy your PGME app! 🎉**
