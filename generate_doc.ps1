$csv = Import-Csv "C:\flater\video_clipper_app\presets_catalog_raw.csv"

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# KATALOG & DOKUMENTASI LENGKAP 800 PRESET ANIMASI QUICKCLIP PRO")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("> File dokumentasi teknis ini merinci ke-800 efek preset animasi yang ada di dalam aplikasi QuickClip Pro (`video_clipper_app`), dibagi ke dalam 8 kategori besar (masing-masing 100 efek). Termasuk analisis karakter gerakan, jenis preview visual, dan cara kerjanya.")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Ringkasan Kategori (Total: 800 Efek)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| No | Kategori | Jumlah Efek | Karakter Utama Animasi | Tampilan Preview Visual |")
[void]$sb.AppendLine("|---|---|---|---|---|")
[void]$sb.AppendLine("| 1 | **Shake** (Guncangan & Hentakan) | 100 efek | Guncangan kamera aksi, gempa, hentakan bass, detak | Getaran X/Y frekuensi tinggi (12-35Hz), shockwave flash |")
[void]$sb.AppendLine("| 2 | **Basic** (Transisi Geometris) | 100 efek | Geser, putar, fade, iris lingkaran, tirai, blinds | Clipping masker geometris, slide 4 arah, spin, snap zoom |")
[void]$sb.AppendLine("| 3 | **Light & Flash** (Cahaya & Kilatan) | 100 efek | Suar lensa, glow neon, strobo pendaran, aurora | Flash overlay putih/warna, pulsating bloom, spectrum lens |")
[void]$sb.AppendLine("| 4 | **Glitch** (Distorsi Digital) | 100 efek | Rusak piksel, vhs tracking, rgb split, data mosh | RGB chromatic aberration (red/cyan), garis scanline CRT |")
[void]$sb.AppendLine("| 5 | **3D & Perspektif** | 100 efek | Balik kartu, kubus rotasi, tunnel z, origami fold | Transformasi Matrix4 3D asli (Yaw, Pitch, Z-depth) |")
[void]$sb.AppendLine("| 6 | **Motion & Kinetik** | 100 efek | Whip pan cepat, drone dive, elastis jelly, drift | Laju kurva dinamis, squash-stretch, blur kecepatan |")
[void]$sb.AppendLine("| 7 | **Retro & Vintage** | 100 efek | Film 8mm/16mm, kamera tua, vhs analog, CRT arcade | Flicker pencahayaan seluloid tua, goyangan rol, derau scanline |")
[void]$sb.AppendLine("| 8 | **Cinematic** (Gaya Bioskop) | 100 efek | Letterbox 2.39:1, slow push, dolly zoom vertigo | Tarikan zoom halus, bilah letterbox bioskop, rack focus blur |")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("")

$catNames = @{
    "shake" = "1. KATEGORI SHAKE (100 EFEK GUNCANGAN & HENTAKAN)"
    "basic" = "2. KATEGORI BASIC & TRANSISI (100 EFEK GEOMETRIS & PERGESERAN)"
    "light" = "3. KATEGORI LIGHT & FLASH (100 EFEK KILATAN CAHAYA & SUAR)"
    "glitch" = "4. KATEGORI GLITCH & DISTORSI (100 EFEK RUSAK DIGITAL & RGB)"
    "threeD" = "5. KATEGORI 3D & PERSPEKTIF SPASIAL (100 EFEK TIGA DIMENSI)"
    "motion" = "6. KATEGORI MOTION & KINETIK (100 EFEK LAJU DINAMIS & ELASTIS)"
    "retro" = "7. KATEGORI RETRO & VINTAGE (100 EFEK FILM ANALOG & KLASIK)"
    "cinematic" = "8. KATEGORI CINEMATIC (100 EFEK BIOSKOP & KAMERA HOLLYWOOD)"
}

$categories = @("shake", "basic", "light", "glitch", "threeD", "motion", "retro", "cinematic")

foreach ($cat in $categories) {
    [void]$sb.AppendLine("## $($catNames[$cat])")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| No | ID Preset | Nama Efek | Tipe Aplikasi | Penjelasan Karakter Visual & Preview |")
    [void]$sb.AppendLine("|---|---|---|---|---|")
    
    $items = $csv | Where-Object { $_.Category -eq $cat }
    $idx = 1
    foreach ($item in $items) {
        $typeLabel = switch($item.Type) {
            "inAnimation" { "In (Masuk)" }
            "outAnimation" { "Out (Keluar)" }
            "comboAnimation" { "Combo (Loop)" }
            default { $item.Type }
        }
        $desc = $item.Desc -replace "\|", "/"
        [void]$sb.AppendLine("| $idx | `${($item.Id)}` | **$($item.Name)** | $typeLabel | $desc |")
        $idx++
    }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
}

Set-Content -Path "C:\flater\video_clipper_app\DAFTAR_800_EFEK_ANIMASI.md" -Value $sb.ToString() -Encoding utf8
Write-Output "File DAFTAR_800_EFEK_ANIMASI.md created successfully!"
