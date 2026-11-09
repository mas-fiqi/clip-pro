# Known Issues & Technical Debt

| ID | Severity | Area | Problem | Impact | Workaround / Action | Status |
|---|---|---|---|---|---|---|
| KI-001 | P0 | Export Pipeline | 464 dari 800 preset animasi belum memiliki filter FFmpeg eksplisit sehingga jatuh ke string kosong pada video render | Efek tampil di preview HP tetapi tidak muncul pada video hasil ekspor | Tambahkan mapping filter eksplisit dan fallback kategori generik cerdas per kategori | OPEN |
| KI-002 | P0 | Git Repository | Project 39k baris belum diinisialisasi git | Risiko fatal kehilangan kode / riwayat commit | Lakukan `git init`, set `.gitignore`, dan initial commit | OPEN |
| KI-003 | P1 | AI & Online Audio | Service `OnlineAiEffectApiService` mengklaim fitur "AI" padahal hanya search HF model metadata; iTunes API unofficial | Pelanggaran kebijakan Play Store (misleading claim) & hak cipta audio | Ubah penamaan fitur menjadi efek preset offline & prioritaskan audio lokal bebas royalti | OPEN |
| KI-004 | P1 | Architecture | `video_clipper_screen.dart` memiliki 1.793 baris dengan single monolithic state | Sukar di-maintain dan rentan side-effect saat menambah fitur | Pecah ke controller spesifik | OPEN |
| KI-005 | P2 | Platform Claims | Scaffolding Web dan Windows memicu runtime crash karena dependensi mobile | Pengguna bingung saat menjalankan di web/desktop | Nyatakan resmi bahwa QuickClip Pro adalah mobile-first (Android & iOS) dan berikan guard pada inisialisasi plugin | OPEN |

