# 📚 Platform E-Learning & CBT Berbasis Ruby on Rails & React

[![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3+-CC342D?style=flat-square&logo=ruby&logoColor=white)](https://www.ruby-lang.org)
[![Rails 8](https://img.shields.io/badge/Rails-8.0+-D30001?style=flat-square&logo=rubyonrails&logoColor=white)](https://rubyonrails.org)
[![React 19](https://img.shields.io/badge/React-19-61DAFB?style=flat-square&logo=react&logoColor=black)](https://react.dev)
[![Tailwind CSS v4](https://img.shields.io/badge/Tailwind_CSS-v4-06B6D4?style=flat-square&logo=tailwindcss&logoColor=white)](https://tailwindcss.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Redis](https://img.shields.io/badge/Redis-7-DC382D?style=flat-square&logo=redis&logoColor=white)](https://redis.io)
[![Spring Edition](https://img.shields.io/badge/Spring_Boot_Version-Tersedia-6DB33F?style=flat-square&logo=springboot&logoColor=white)](https://github.com/mfarim/spring-elearning-react)
[![FastAPI Edition](https://img.shields.io/badge/FastAPI_Version-Tersedia-009688?style=flat-square&logo=fastapi&logoColor=white)](https://github.com/mfarim/fastapi-elearning-react)
[![Laravel Edition](https://img.shields.io/badge/Laravel_Version-Tersedia-FF2D20?style=flat-square&logo=laravel&logoColor=white)](https://github.com/mfarim/laravel-elearning)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

> 🇬🇧 [Read in English](README.md)
>
> 💎 Edisi **Ruby on Rails 8 & React 19** dari platform Learning Management System (LMS) dan Computer Based Test (CBT) akademik multi-peran tingkat enterprise.

Aplikasi web **E-Learning** dan **Computer Based Test (CBT)** berfitur lengkap yang dirancang untuk mengelola seluruh kegiatan belajar mengajar modern antara **Admin**, **Guru**, dan **Siswa**. Dibangun dengan arsitektur modern terpisah (decoupled): **Ruby on Rails 8 API mode, React 19, Vite, dan Tailwind CSS v4**, dilengkapi otentikasi JWT tanpa status (stateless) dengan impersonasi admin, persistensi PostgreSQL 16, cache Redis, telemetri proctoring ujian real-time, dan pemrosesan batch file Excel.

---

## ✨ Fitur Utama

### 👨‍💼 Panel Administrator
| Fitur | Deskripsi |
|---|---|
| **Dashboard** | Ringkasan statistik real-time: total guru, siswa, kelas, mata pelajaran, metrik CBT |
| **Manajemen Guru** | CRUD lengkap dengan provisi akun otomatis & validasi NIP unik |
| **Manajemen Siswa** | CRUD + filter kelas + **📥 Batch Import Excel** (`.xlsx`) + Cetak Kartu Peserta Ujian |
| **Manajemen Kelas** | CRUD + penugasan wali kelas + manajemen kapasitas & tahun ajaran |
| **Mata Pelajaran** | CRUD + kode mapel + bobot SKS/jam pelajaran + pemetaan guru pengampu |
| **Pengumuman** | CRUD + penyiaran multi-target (Semua / Guru / Siswa) + status publikasi |
| **Impersonasi Akun** | Login instan 1-klik sebagai guru atau siswa untuk keperluan verifikasi dan debugging admin |
| **Keamanan** | Token stateless JWT, hashing BCrypt, dan otorisasi berbasis peran (RBAC) |

### 👨‍🏫 Panel Guru
| Fitur | Deskripsi |
|---|---|
| **Dashboard** | Metrik jam mengajar, ujian terjadwal, tugas aktif, dan aktivitas terkini |
| **Materi Pembelajaran** | CRUD + multi-tipe konten (Dokumen, Video, Teks, Tautan, Audio) + pelacakan status baca siswa |
| **Tugas & Diskusi** | CRUD + tenggat waktu + instruksi + penilaian submission dengan umpan balik + forum diskusi |
| **Ujian CBT** | CRUD + timer durasi + KKM + acak urutan soal/opsi + izin remedial |
| **Penyusun Soal** | Pilihan Ganda (A-E), Benar/Salah, Essay + alokasi poin + **📥 Import Soal Excel** |
| **Monitor Telemetri Live** | Status kandidat ujian real-time, bilah progres pengerjaan, dan alarm anti-cheat |
| **Kartu Ujian Siswa** | Cetak kartu resmi peserta CBT siap pakai dengan barcode NIS |

### 👨‍🎓 Panel Siswa — Desain Mobile-First
| Fitur | Deskripsi |
|---|---|
| **Dashboard Siswa** | Drawer navigasi mobile responsif, hitung mundur ujian, tugas aktif, pengumuman |
| **Modul Belajar** | Jelajahi, baca, dan pelajari modul materi pembelajaran terstruktur per mata pelajaran |
| **Pusat Tugas** | Lihat detail instruksi tugas + dropzone unggah file + tinjauan nilai dan feedback guru |
| **Ruang Ujian CBT** | Runner ujian layar penuh (fullscreen) dengan timer tersinkronisasi, anti-cheat, dan auto-submit |
| **Rapor & Rekap Nilai** | Rincian nilai rata-rata per mapel, bilah kemajuan, dan status kelulusan KKM |

---

## 🛠️ Arsitektur Teknologi

| Lapisan (Layer) | Teknologi |
|---|---|
| **Backend Core** | Ruby 3.3+, Ruby on Rails 8.0 (API Mode) |
| **Keamanan & Auth** | BCrypt, JWT (stateless token), Role-based Access Control, Mesin Impersonasi |
| **Penyimpanan Data** | PostgreSQL 16, Active Record, Database Migrations |
| **Cache & Realtime** | Redis 7, ActionCable / Redis Telemetry PubSub |
| **Batch Processing** | Roo (`.xlsx`, `.xls`, `.csv` batch parser untuk Siswa & Bank Soal) |
| **Frontend Core** | React 19, TypeScript 5+, Vite 6 |
| **Styling** | Tailwind CSS v4 (Mesin CSS native dengan `@tailwindcss/vite`) |
| **State Management** | Zustand 5, Axios dengan interceptor JWT |
| **Pengujian (Testing)**| RSpec (`rspec-rails`), FactoryBot, DatabaseCleaner, Oxlint |
| **Deployment & CI** | Docker Compose, Dockerfile Multi-stage, GitHub Actions CI/CD |

---

## 🚀 Panduan Memulai Cepat (Docker Compose)

Pastikan Docker dan Docker Compose telah terpasang di sistem Anda.

```bash
# 1. Clone repositori
git clone https://github.com/mfarim/ruby-rails-elearning-react.git
cd ruby-rails-elearning-react

# 2. Salin environment file
cp .env.example .env

# 3. Jalankan seluruh layanan
docker compose up -d --build

# 4. Pantau log backend
docker compose logs -f backend
```

Akses aplikasi di peramban web:
- **Frontend Web Application**: [http://localhost:3002](http://localhost:3002)
- **Backend API**: [http://localhost:8000/health](http://localhost:8000/health)

---

## 🔑 Kredensial Akun Bawaan

| Peran | Email | Password |
|---|---|---|
| **Admin** | `admin@elearning.test` | `password123` |
| **Guru** | `teacher@elearning.test` | `password123` |
| **Siswa** | `student@elearning.test` | `password123` |

---

## 🔄 Alur CI/CD GitHub Actions

Repositori ini telah dikonfigurasi dengan workflow otomatis GitHub Actions:
1. **Backend CI (`.github/workflows/backend-ci.yml`)**:
   - Menjalankan kontainer PostgreSQL 16 & Redis 7 dengan healthcheck.
   - Menyiapkan Ruby 3.3 dan caching gem bundler.
   - Menjalankan migrasi database dan pengujian seed data.
   - Menjalankan test suite RSpec dan analisis kode RuboCop.
2. **Frontend CI (`.github/workflows/frontend-ci.yml`)**:
   - Menyiapkan Node.js 20 dengan caching npm.
   - Menjalankan instalasi dependensi (`npm ci`).
   - Menjalankan linter `oxlint` dan build produksi Vite + TypeScript.

---

## 📄 Lisensi
Proyek ini dilisensikan di bawah [Lisensi MIT](LICENSE).
