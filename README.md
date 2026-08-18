# Brain Fog Tracker v3 — Supabase

## 1) Supabase veritabanını kur
Supabase projesinde:
- SQL Editor'a gir
- `setup.sql` dosyasının tamamını çalıştır

Bu işlem 7 tablo oluşturur ve Row Level Security (RLS) ile her kullanıcının yalnızca kendi verisini görmesini sağlar.

## 2) Proje URL ve publishable key'i al
Supabase Dashboard içinden Project URL ve public/publishable key'i kopyala.

`config.js` içinde şu iki alanı değiştir:
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

`service_role` key kullanma.

## 3) Auth URL ayarı
Supabase Auth URL Configuration'da:
Site URL:
https://gribalikcil.github.io/brainfog-tracker/

Redirect URLs içine de aynı URL'yi ekle.

`config.js` içindeki `SITE_URL` de bu GitHub Pages adresi olmalı; Supabase proje URL'si olmamalı.

## 4) GitHub'a yükle
Mevcut brainfog-tracker reposunda:
- eski `index.html` yerine bu `index.html`
- yeni `config.js`

dosyalarını yükle/replace et ve commit et.

`setup.sql` GitHub'a koymak zorunda değilsin.

## 5) İlk giriş
Canlı siteyi aç:
https://gribalikcil.github.io/brainfog-tracker/

- Yeni hesap oluştur
- E-posta doğrulaması istenirse doğrula
- Giriş yap

Bundan sonra veriler Supabase PostgreSQL'de saklanır ve cihazlar arasında senkron olur.
