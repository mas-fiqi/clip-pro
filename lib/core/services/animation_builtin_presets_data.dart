import '../models/animation_model.dart';

/// Preset animasi bawaan QuickClip Pro (offline, siap pakai).
///
/// Dipisahkan dari AnimationLibraryService agar data murni Dart ini bisa
/// dipakai juga oleh tool audit ekspor dan test tanpa dependensi Flutter.
class AnimationBuiltinPresetsData {
  static const List<AnimationPresetModel> allPresets = [
    AnimationPresetModel(
      id: 'zoom_burst',
      name: 'Letupan Skala Cepat',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Pembesaran skala meletup cepat yang sering digunakan di video jedag-jedug',
    ),
    AnimationPresetModel(
      id: 'trending_fade_in_cinematic',
      name: 'Pudar Masuk Sinematik',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Pudar masuk transparan lembut pembuka video vlog viral',
    ),
    AnimationPresetModel(
      id: 'trending_spin_drop',
      name: 'Putaran Jatuh Meluncur',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Putaran rotasi 360 derajat jatuh ke layar secara dinamis',
    ),
    AnimationPresetModel(
      id: 'trending_wipe_sweep_right',
      name: 'Sapuan Usap ke Kanan',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Sapu garis datar ke kanan yang populer untuk transisi ritme cepat',
    ),
    AnimationPresetModel(
      id: 'trending_circle_iris_open',
      name: 'Bukaan Iris Lingkaran',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Iris lingkaran membesar dramatis dari tengah layar',
    ),
    AnimationPresetModel(
      id: 'trending_diamond_iris_pop',
      name: 'Letupan Iris Berlian',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Iris belah ketupat modern pembuka adegan highlight',
    ),
    AnimationPresetModel(
      id: 'trending_checkerboard_reveal',
      name: 'Singkapan Papan Catur',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Petak papan catur membuka adegan secara bergantian',
    ),
    AnimationPresetModel(
      id: 'trending_split_vertical_in',
      name: 'Belah Vertikal Masuk',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Pemisahan bingkai dari tengah ke atas-bawah ala intro video musik',
    ),
    AnimationPresetModel(
      id: 'trending_slide_left_fast',
      name: 'Meluncur Cepat ke Kiri',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Geser kiri berkecepatan tinggi dengan kurva snap yang tajam',
    ),
    AnimationPresetModel(
      id: 'trending_curtain_open_smooth',
      name: 'Bukaan Tirai Halus',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Tirai panggung terbuka lembut menyambut subjek utama',
    ),
    AnimationPresetModel(
      id: 'trending_elastic_scale_pop',
      name: 'Hentakan Skala Elastis',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Letupan skala elastis memantul menghentak ketukan musik',
    ),
    AnimationPresetModel(
      id: 'trending_box_zoom_impact',
      name: 'Dampak Zoom Persegi',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Zoom kotak persegi tegas fokus pada wajah model',
    ),
    AnimationPresetModel(
      id: 'trending_venetian_blinds_in',
      name: 'Tirai Kisi-Kisi Masuk',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Kisi-kisi bilah horizontal membuka gambar secara artistik',
    ),
    AnimationPresetModel(
      id: 'trending_bass_boom_shake',
      name: 'Guncangan Dentuman Bass',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Hentakan getaran bass kuat sinkron dengan drop beat musik jedag-jedug',
    ),
    AnimationPresetModel(
      id: 'trending_camera_shake_heavy',
      name: 'Guncangan Kamera Dahsyat',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Guncangan kamera tangan berbobot tinggi pada momen klimaks aksi',
    ),
    AnimationPresetModel(
      id: 'trending_micro_jitter_fast',
      name: 'Getaran Mikro Cepat',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Getaran mikro frekuensi tinggi memberikan ketegangan visual instan',
    ),
    AnimationPresetModel(
      id: 'trending_explosion_shockwave',
      name: 'Gelombang Kejut Ledakan',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Goncangan gelombang kejut ledakan menghantam kanvas video',
    ),
    AnimationPresetModel(
      id: 'trending_punch_impact_recoil',
      name: 'Sentakan Hentakan Pukulan',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Hentakan pukulan keras menyentak sudut pandang kamera',
    ),
    AnimationPresetModel(
      id: 'trending_gunfire_kickback',
      name: 'Hentakan Tembakan Aksi',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Sentakan tolak balik tembakan beruntun berirama cepat',
    ),
    AnimationPresetModel(
      id: 'trending_earthquake_rumble',
      name: 'Gempa Gemuruh Bumi',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Getaran gempa bumi horizontal dan vertikal simultan',
    ),
    AnimationPresetModel(
      id: 'trending_stumble_jolt',
      name: 'Goncangan Terhuyung Goyang',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Guncangan tersandung mendadak memberi efek dramatis tak terduga',
    ),
    AnimationPresetModel(
      id: 'trending_helicopter_turbulence',
      name: 'Turbulensi Helikopter',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Goyangan turbulensi baling-baling helikopter menghempas sudut',
    ),
    AnimationPresetModel(
      id: 'trending_subwoofer_pulse',
      name: 'Denyutan Subwoofer Keras',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Getaran getar frekuensi rendah 30Hz yang mengguncang layar',
    ),
    AnimationPresetModel(
      id: 'trending_speed_bump_hop',
      name: 'Lompatan Gundukan Jalan',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Lompatan hentakan suspensi mobil melibas polisi tidur',
    ),
    AnimationPresetModel(
      id: 'trending_aftershock_wave',
      name: 'Gelombang Susulan Gempa',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Getaran gempa susulan berdenyut ritmis setelah dentuman',
    ),
    AnimationPresetModel(
      id: 'trending_white_flash_bang',
      name: 'Kilatan Kilap Putih',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Kilatan putih terang menyilaukan pada transisi beat musik',
    ),
    AnimationPresetModel(
      id: 'trending_lens_flare_streak',
      name: 'Goresan Suar Lensa',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Pendaran silau garis flare horizontal lensa sinematik',
    ),
    AnimationPresetModel(
      id: 'trending_anamorphic_blue_streak',
      name: 'Goresan Anamorfik Biru',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Kilau garis biru tajam ala film fiksi ilmiah blockbuster',
    ),
    AnimationPresetModel(
      id: 'trending_light_leak_golden',
      name: 'Bocoran Cahaya Keemasan',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Bocoran cahaya kuning keemasan hangat khas momen senja viral',
    ),
    AnimationPresetModel(
      id: 'trending_paparazzi_strobe',
      name: 'Lampu Kilat Paparazi',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Rentetan kilatan blitz fotografer bergantian berkecepatan tinggi',
    ),
    AnimationPresetModel(
      id: 'trending_laser_beam_sweep',
      name: 'Sapuan Sorot Laser',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Sapu garis laser neon membelah kegelapan panggung rave',
    ),
    AnimationPresetModel(
      id: 'trending_prism_rainbow_flare',
      name: 'Pendar Pelangi Prisma',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Pembiasan spektrum warna pelangi estetik di sudut rekaman',
    ),
    AnimationPresetModel(
      id: 'trending_aurora_borealis_glow',
      name: 'Pendar Cahaya Aurora',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Pendar cahaya kutub utara hijau toska bergelombang lembut',
    ),
    AnimationPresetModel(
      id: 'trending_glow_pulse_rhythm',
      name: 'Irama Denyut Cahaya',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Denyutan pendar cahaya mengikuti ketukan tempo lagu',
    ),
    AnimationPresetModel(
      id: 'trending_lightning_strike_flash',
      name: 'Kilatan Sambaran Petir',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Sambaran kilat petir menyinari adegan dalam sepersekian detik',
    ),
    AnimationPresetModel(
      id: 'trending_supernova_burst',
      name: 'Ledakan Bintang Supernova',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Ledakan cahaya kosmik bintang meluas dari titik pusat',
    ),
    AnimationPresetModel(
      id: 'trending_disco_light_dots',
      name: 'Titik Cahaya Disko',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Bintik-bintik cahaya bola cermin berputar gemerlap di lantai dansa',
    ),
    AnimationPresetModel(
      id: 'trending_rgb_split_chromatic',
      name: 'Pemisahan Warna RGB',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Pemisahan kanal warna merah, hijau, dan biru yang paling disukai kreator',
    ),
    AnimationPresetModel(
      id: 'trending_datamosh_compression',
      name: 'Sapuan Datamosh Glitch',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Efek lelehan frame kompresi video digital ala tren TikTok',
    ),
    AnimationPresetModel(
      id: 'trending_vhs_tracking_noise',
      name: 'Derau Pelacak Pita VHS',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Garis derau pelacak kaset pita kusut retro klasik',
    ),
    AnimationPresetModel(
      id: 'trending_static_tv_snow',
      name: 'Bintik Salju TV Statis',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Salju semut derau televisi tabung rusak berderisik',
    ),
    AnimationPresetModel(
      id: 'trending_pixel_sort_down',
      name: 'Air Terjun Sortir Piksel',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Pikselasi meleleh mengalir ke bawah seperti air terjun digital',
    ),
    AnimationPresetModel(
      id: 'trending_scanline_crt_buzz',
      name: 'Dengung Garis Pindai CRT',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Garis pemindai horizontal monitor tabung kaca berosilasi',
    ),
    AnimationPresetModel(
      id: 'trending_corrupted_ram_blocks',
      name: 'Blok Memori RAM Rusak',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Blok memori video rusak berkedip acak membentuk corak heksadesimal',
    ),
    AnimationPresetModel(
      id: 'trending_block_displacement',
      name: 'Pergeseran Blok Piksel',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Pergeseran lempengan blok piksel horizontal yang terputus-putus',
    ),
    AnimationPresetModel(
      id: 'trending_digital_tear_fast',
      name: 'Robekan Digital Cepat',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Sobekan digital linier melintang cepat membagi dua adegan',
    ),
    AnimationPresetModel(
      id: 'trending_h264_macroblock_loss',
      name: 'Hilang Blok Kompresi',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Kotak artefak dekompresi paket data video yang hilang',
    ),
    AnimationPresetModel(
      id: 'trending_chroma_channel_shift',
      name: 'Pergeseran Kanal Warna',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Pergeseran lapisan warna kroma menjauhi kontur objek asli',
    ),
    AnimationPresetModel(
      id: 'trending_glitch_teleport_burst',
      name: 'Letupan Teleportasi Glitch',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Kedipan lompat teleportasi futuristik ala film cyberpunk',
    ),
    AnimationPresetModel(
      id: 'trending_3d_card_flip_horiz',
      name: 'Balik Kartu 3D Horizontal',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Pembalikan kartu 3D berputar pada sumbu tengah dengan ketebalan bayangan',
    ),
    AnimationPresetModel(
      id: 'trending_3d_cube_rotation',
      name: 'Rotasi Kubus 3D',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Rotasi kubus 4 sisi tiga dimensi berganti ke sisi adegan berikutnya',
    ),
    AnimationPresetModel(
      id: 'trending_3d_door_swing_open',
      name: 'Ayun Pintu 3D Terbuka',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Bidang video mengayun terbuka seperti pintu masuk ke ruangan 3D',
    ),
    AnimationPresetModel(
      id: 'trending_3d_origami_fold',
      name: '3D Origami Fold',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Pelipatan geometris bidang datar menjadi lipatan origami 3D',
    ),
    AnimationPresetModel(
      id: 'trending_3d_spatial_cylinder_roll',
      name: '3D Cylinder Roll',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Penggulungan bidang video melingkar seperti tabung silinder tiga dimensi',
    ),
    AnimationPresetModel(
      id: 'trending_3d_depth_push_z',
      name: '3D Depth Push Z-Axis',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Penerobosan maju menembus bidang kedalaman sumbu Z',
    ),
    AnimationPresetModel(
      id: 'trending_3d_tunnel_dive_in',
      name: '3D Tunnel Dive In',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Menukik masuk ke dalam lorong silinder tiga dimensi yang tak terbatas',
    ),
    AnimationPresetModel(
      id: 'trending_3d_shatter_glass',
      name: '3D Shattered Glass',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Hamburan pecahan kaca tiga dimensi melayang ke arah penonton',
    ),
    AnimationPresetModel(
      id: 'trending_3d_tesseract_spin',
      name: '3D Tesseract Spin',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Perputaran hiperkubus dimensi empat berputar memukau',
    ),
    AnimationPresetModel(
      id: 'trending_3d_anti_gravity_rise',
      name: '3D Anti-Gravity Rise',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Objek melayang bebas melawan gravitasi mengapung di ruang 3D',
    ),
    AnimationPresetModel(
      id: 'trending_3d_infinite_mirror_zoom',
      name: '3D Infinite Mirror Zoom',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Lorong cermin tanpa batas meluncur menuju titik lenyap',
    ),
    AnimationPresetModel(
      id: 'trending_3d_floating_card_hover',
      name: '3D Floating Card Hover',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Kartu mengapung melayang dengan sudut perspektif bebas',
    ),
    AnimationPresetModel(
      id: 'trending_speed_ramp_curve',
      name: 'Speed Ramp Curve',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Kurva kecepatan dinamis lambat lalu cepat mengunci beat lagu',
    ),
    AnimationPresetModel(
      id: 'trending_kinetic_flow_whip',
      name: 'Kinetic Whip Pan',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Sabetan pan horizontal super cepat dengan motion blur alami',
    ),
    AnimationPresetModel(
      id: 'trending_hyper_speed_dash',
      name: 'Hyper Speed Dash',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Gerakan melesat secepat kilat meninggalkan bayangan garis cepat',
    ),
    AnimationPresetModel(
      id: 'trending_rubber_band_bounce',
      name: 'Rubber Band Bounce',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Pantulan karet kenyal menghentak elastis saat mencapai batas',
    ),
    AnimationPresetModel(
      id: 'trending_fpv_drone_flythrough',
      name: 'FPV Drone Flythrough',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Manuver penerbangan drone balap FPV meliuk di antara celah',
    ),
    AnimationPresetModel(
      id: 'trending_jelly_physics_wobble',
      name: 'Jelly Physics Wobble',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Goyangan kenyal puding jeli berosilasi setelah menerima dampak',
    ),
    AnimationPresetModel(
      id: 'trending_magnetic_pull_snap',
      name: 'Magnetic Pull Snap',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Tarikan magnetik menarik frame ke titik pusat dengan akselerasi tajam',
    ),
    AnimationPresetModel(
      id: 'trending_pendulum_swing_in',
      name: 'Pendulum Swing In',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Ayunan bandul berkecepatan tinggi meluncur dari luar kanvas',
    ),
    AnimationPresetModel(
      id: 'trending_slingshot_release',
      name: 'Slingshot Release',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Lepasan tarikan ketapel melontarkan sudut pandang ke depan',
    ),
    AnimationPresetModel(
      id: 'trending_camera_slider_push',
      name: 'Motorized Slider Push',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Dorongan kamera slider bermotor mendekati objek secara presisi',
    ),
    AnimationPresetModel(
      id: 'trending_smooth_pedestal_up',
      name: 'Smooth Pedestal Up',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Kamera naik vertikal secara mulus mempertahankan horizontalitas',
    ),
    AnimationPresetModel(
      id: 'trending_rollercoaster_dive',
      name: 'Rollercoaster Dive',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Luncuran menukik curam kereta luncur memacu adrenalin',
    ),
    AnimationPresetModel(
      id: 'trending_vhs_vintage_flicker',
      name: 'VHS Vintage Flicker',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Nuansa rekaman video kaset pita 80-an dengan flicker khas',
    ),
    AnimationPresetModel(
      id: 'trending_8mm_silent_film_jitter',
      name: '8mm Silent Film Jitter',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Goyangan frame rate dan butiran film bisu 1920-an',
    ),
    AnimationPresetModel(
      id: 'trending_16mm_projector_hum',
      name: '16mm Projector Hum',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Proyektor film seluloid 16mm dengan goresan garis vertikal',
    ),
    AnimationPresetModel(
      id: 'trending_film_countdown_leader',
      name: 'Film Leader 5-4-3-2-1',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Hitungan mundur lingkar film bioskop klasik sebelum adegan mulai',
    ),
    AnimationPresetModel(
      id: 'trending_polaroid_develop_fade',
      name: 'Polaroid Instant Develop',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Foto polaroid memudar dari putih kimiawi ke warna retro',
    ),
    AnimationPresetModel(
      id: 'trending_halftone_comic_pop',
      name: 'Halftone Comic Pop',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Pola titik raster komik cetak pop art tahun 1960-an',
    ),
    AnimationPresetModel(
      id: 'trending_crt_phosphor_decay',
      name: 'CRT Phosphor Decay',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Jejak pendar fosfor tabung monitor saat objek bergerak cepat',
    ),
    AnimationPresetModel(
      id: 'trending_typewriter_clack_frame',
      name: 'Typewriter Text Frame',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Hentakan mekanis mesin tik jadul mengetuk bingkai gambar',
    ),
    AnimationPresetModel(
      id: 'trending_gramophone_scratch_audio',
      name: 'Gramophone Vinyl Dust',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Debu dan goresan piringan hitam vinil klasik berputar',
    ),
    AnimationPresetModel(
      id: 'trending_kodachrome_64_vintage',
      name: 'Kodachrome 64 Warmth',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Kekayaan warna kuning dan merah khas film slide legendaris',
    ),
    AnimationPresetModel(
      id: 'trending_technicolor_vivid_strip',
      name: 'Technicolor Vivid Strip',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Warna saturated film musikal Hollywood keemasan era 1940-an',
    ),
    AnimationPresetModel(
      id: 'trending_super8_home_movie_edge',
      name: 'Super 8 Home Movie Edge',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Bingkai film keluarga dengan lubang perforasi sprocket di samping',
    ),
    AnimationPresetModel(
      id: 'trending_cinema_letterbox_in',
      name: '2.39:1 Cinema Letterbox',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Bilah hitam layar lebar sinema Hollywood menutup atas-bawah',
    ),
    AnimationPresetModel(
      id: 'trending_blockbuster_hero_reveal',
      name: 'Blockbuster Hero Reveal',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Pengungkapan pahlawan utama berkecepatan lambat megah',
    ),
    AnimationPresetModel(
      id: 'trending_teal_orange_grade',
      name: 'Teal & Orange Color Grade',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Gradasi warna sinematik kontras hangat kulit dan dingin latar',
    ),
    AnimationPresetModel(
      id: 'trending_rack_focus_bokeh',
      name: 'Rack Focus Bokeh',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Perpindahan titik fokus lensa dari latar depan ke latar belakang',
    ),
    AnimationPresetModel(
      id: 'trending_hitchcock_vertigo_dolly',
      name: 'Hitchcock Dolly Zoom',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Efek vertigo distorsi perspektif legendaris sutradara Alfred Hitchcock',
    ),
    AnimationPresetModel(
      id: 'trending_epic_crane_shot_swoop',
      name: 'Epic Crane Shot Swoop',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Lengan derek kamera melayang turun dari ketinggian langit',
    ),
    AnimationPresetModel(
      id: 'trending_bleach_bypass_war_film',
      name: 'Bleach Bypass War Tone',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Desaturasi perak film perang dengan kontras bayangan tajam',
    ),
    AnimationPresetModel(
      id: 'trending_chiaroscuro_noir_shadow',
      name: 'Chiaroscuro Noir Shadow',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Permainan bayangan pekat dan sorotan tunggal film detektif 1940-an',
    ),
    AnimationPresetModel(
      id: 'trending_anamorphic_oval_bokeh',
      name: 'Anamorphic Oval Bokeh',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Titik lingkaran cahaya berbentuk oval khas lensa sinema sejati',
    ),
    AnimationPresetModel(
      id: 'trending_fpv_ridge_sweep_cinema',
      name: 'FPV Ridge Sweep Cinema',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Penerbangan menyusuri punggung bukit pegunungan berkabut',
    ),
    AnimationPresetModel(
      id: 'trending_dramatic_slow_push',
      name: 'Dramatic Slow Push In',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Pendekatan kamera lambat menembus emosi ketegangan adegan',
    ),
    AnimationPresetModel(
      id: 'trending_cinema_dolly_lateral',
      name: 'Cinematic Lateral Dolly',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Kamera tracking menyamping sinematik melintasi deretan tiang pilar',
    ),
    AnimationPresetModel(
      id: 'trending_action_impact_cut',
      name: 'Potongan Hentakan Laga Cepat',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description:
          'Lompatan potongan adegan laga berkecepatan tinggi yang menggugah',
    ),
    AnimationPresetModel(
      id: 'trending_cross_scale_dissolve',
      name: 'Peleburan Skala Silang',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Peleburan dua frame berpadu skala mikro yang elegan',
    ),
    AnimationPresetModel(
      id: 'trending_cinema_curtain_reveal',
      name: 'Singkapan Tirai Layar Bioskop',
      category: AnimationCategory.trending,
      type: AnimationApplicationType.comboAnimation,
      description: 'Bukaan tabir layar perak bioskop membuka adegan agung',
    ),
  ];
}
