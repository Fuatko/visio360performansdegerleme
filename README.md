# VISIO 360° Platform - Kurulum Rehberi

## 🔐 GÜVENLİK SİSTEMİ
TC Kimlik numaraları **şifre** olarak kullanılır ve hiçbir yerde görünmez!

## 📊 SİSTEM AKIŞI

```
SÜPER ADMİN (Sadece Siz)
    │
    ├── 1. Kurumları ekle
    ├── 2. Personeli ekle (isim + TC)
    ├── 3. Dönem oluştur
    ├── 4. MATRİKS: Kim kimi değerlendirecek
    ├── 5. Linkleri oluştur
    └── 6. Linkleri kişilere gönder (WhatsApp/Email)

DEĞERLENDİRİCİLER
    │
    └── Linke tıklar → GİRİŞ YAPMADAN form doldurur → Gönderir
```

## 📁 Dosyalar
- `index.html` - Admin giriş sayfası
- `super-admin.html` - Admin yönetim paneli
- `form.html` - Public değerlendirme formu (link ile erişim)
- `VISIO_360_DATABASE_SETUP.sql` - İlk kurulum scripti
- `UPDATE_TOKEN_FIELD.sql` - Token güncelleme scripti

---

## 🚀 İLK KURULUM

### 1. Supabase
- https://supabase.com → Hesap aç
- New Project → Region: Frankfurt

### 2. Veritabanı
- SQL Editor → `VISIO_360_DATABASE_SETUP.sql` çalıştır
- SQL Editor → `UPDATE_TOKEN_FIELD.sql` çalıştır

### 3. Bağlantı
- Settings → API → URL ve Key kopyala
- Admin panelinde yapıştır

---

## 📋 KULLANIM

### Adım 1: Kurum Ekle
🏢 Kurumlar → + Yeni Kurum

### Adım 2: Personel Ekle
👥 Kullanıcılar → + Yeni Kullanıcı
- Ad Soyad: Değerlendirecek kişinin adı
- TC Kimlik: (sadece kayıt için, görünmez)
- Rol: Kullanıcı

### Adım 3: Dönem Oluştur
📅 Dönemler → + Yeni Dönem
- İsim: "2025 Q1 Değerlendirmesi"
- Tarih aralığı gir

### Adım 4: Matris Oluştur
🎯 Değerlendirme Matrisi
- Dönem seç
- Kurum seç
- Checkbox'larla kim kimi değerlendirecek işaretle
- "Matrisi Kaydet" tıkla

### Adım 5: Linkleri Gönder
- "Linkleri Oluştur" tıkla
- Her satırda "Kopyala" ile linki al
- WhatsApp/Email ile ilgili kişiye gönder

---

## 🔑 Admin Giriş
- Kullanıcı Adı: Fuat Kocabıçak
- Şifre: TC Kimlik numaranız

---

## 🚀 VERCEL DEPLOY (Bulut Erişim)

### Adım 1: Vercel Hesabı
1. https://vercel.com → GitHub ile giriş

### Adım 2: Deploy
1. **Add New** → **Project**
2. **Import Git Repository** veya **Upload** seçin
3. ZIP içindeki tüm dosyaları yükleyin
4. **Deploy** tıklayın

### Adım 3: Domain
Deploy tamamlandığında size bir URL verilir:
```
https://visio360-xxx.vercel.app
```

### Adım 4: Kullanım
- **Admin Paneli:** `https://sizin-domain.vercel.app/`
- **Form Linki:** `https://sizin-domain.vercel.app/form.html?token=xxx`

---

## 📊 SİSTEM ÖZELLİKLERİ

### REEL Puanlama
- 7'li skala (1-7 arası)
- 10 kategori, 39 soru
- Ağırlıklı ortalama hesaplama

### Standart Puanlama  
- REEL puanına göre normalize
- Değerlendirici sayısına göre bonus
- 100 üzerinden skor

### SWOT Analizi
- Güçlü yönler (5+ puan)
- Gelişim alanları (4- puan)
- Fırsatlar (4-5 arası)
- Dikkat edilmesi gerekenler (3- puan)

### Grafikler
- Radar grafik (kategori bazlı)
- Bar grafik (kişi karşılaştırması)
- İlerleme çubukları

### Raporlar
- Excel'e aktarma
- PDF rapor (yakında)
- Kişi bazlı detay
