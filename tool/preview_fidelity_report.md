# Audit Fidelity Preview Animasi

Dibuat: 2026-11-09T10:46:26.334310

## Ringkasan

| Metrik | Nilai |
|---|---:|
| Total preset | 900 |
| Preset built-in | 100 |
| Preset library | 800 |
| ID unik | 900 |
| Nama unik | 886 |
| Preview eksplisit (case khusus) | 436 |
| Preview generik (fallback kategori) | 464 |
| Transformasi statis (di luar overlay painter) | 1 |
| Kandidat nama vs preview tidak cocok (heuristik) | 77 |
| Gaya preview unik (fingerprint) | 448 |
| ID duplikat | 0 |
| Nama duplikat | 14 |

## Distribusi kategori & tipe

| Kategori | Jumlah |
|---|---:|
| trending | 100 |
| shake | 100 |
| basic | 100 |
| light | 100 |
| glitch | 100 |
| threeD | 100 |
| motion | 100 |
| retro | 100 |
| cinematic | 100 |

| Tipe deklarasi | Jumlah |
|---|---:|
| comboAnimation | 683 |
| inAnimation | 167 |
| outAnimation | 50 |

## Preset dengan transformasi statis (1)

Catatan: widget preview juga menggambar overlay `TrendingVisualEffectPainter` dan `GlitchVisualEffectPainter`, sehingga transformasi statis belum tentu berarti preview benar-benar diam.

- `glitch_defective_ccd_sensor_line` — Defective CCD Sensor Line

## Kandidat nama vs preview tidak cocok (77)

Heuristik kata kunci pada ID/nama versus sinyal transformasi. Angka ini adalah kandidat untuk dicek visual, bukan vonis otomatis.

Format: `id` — nama — sinyal yang diharapkan tetapi tidak muncul.
- `trending_laser_beam_sweep` — Sapuan Sorot Laser — mask/wipe
- `trending_datamosh_compression` — Sapuan Datamosh Glitch — mask/wipe
- `trending_8mm_silent_film_jitter` — 8mm Silent Film Jitter — retro/vhs
- `trending_16mm_projector_hum` — 16mm Projector Hum — retro/vhs
- `trending_kodachrome_64_vintage` — Kodachrome 64 Warmth — retro/vhs
- `trending_bleach_bypass_war_film` — Bleach Bypass War Tone — retro/vhs
- `aurora_borealis` — Aurora Borealis Glow — flash/light
- `lightning_strike` — Lightning Strike Flash — flash/light
- `beacon_light` — Beacon Sweep Light — slide/pan
- `phosphor_screen` — Phosphor Green CRT Glow — flash/light, retro/vhs
- `quantization_noise` — Quantization Error Noise — glitch
- `rgb_strobe_jitter` — RGB Strobe Jitter — flash/light
- `lcd_pixel_dead` — Dead Pixel Cluster Wave — glitch
- `anamorphic_glitch_streak` — Anamorphic Flare Tear — flash/light
- `sub_zero_freeze_glitch` — Frost Glitch Freeze — glitch
- `glitch_split_horiz` — Horizontal Split Shudder — mask/wipe
- `tumble_in_space` — 3D Tumble In Space — 3d/depth
- `prism_refract_3d` — 3D Prism Refract — 3d/depth
- `floating_tiles_in` — 3D Floating Tiles In — 3d/depth
- `floating_tiles_out` — 3D Floating Tiles Out — 3d/depth
- `wave_mesh_distortion` — 3D Mesh Wave Grid — 3d/depth
- `page_turn_curled` — 3D Curled Page Turn — 3d/depth
- `unfold_accordion` — 3D Accordion Unfold — 3d/depth
- `camera_dolly_zoom` — 3D Vertigo Dolly Zoom — 3d/depth
- `cube_zoom_burst` — 3D Cube Burst Zoom — 3d/depth
- `pyramid_slice_in` — 3D Pyramid Slice In — 3d/depth
- `billboard_swing` — 3D Billboard Sign Swing — 3d/depth
- `galaxy_spiral_in` — 3D Galaxy Spiral Arms — 3d/depth
- `floating_diamond_hover` — 3D Floating Diamond — 3d/depth
- `mirror_dimension_fold` — 3D Mirror Dimension Fold — 3d/depth
- `zenith_drop_3d` — 3D Zenith Gravity Drop — 3d/depth
- `anti_gravity_rise` — 3D Anti-Gravity Rise — 3d/depth
- `subtle_breathing_zoom` — Subtle Breathing Zoom — zoom/scale
- `fast_staccato_whip` — Staccato Whip Snap — slide/pan
- `spiral_centrifugal` — Centrifugal Force Spin — rotate
- `eight_millimeter_jitter` — 8mm Silent Film Jitter — retro/vhs
- `sixteen_millimeter_grain` — 16mm Projector Hum — retro/vhs
- `retro_split_flap_board` — Split-Flap Train Board — mask/wipe
- `retro_neon_motel_buzz` — Neon Motel Sign Hum — retro/vhs
- `faded_seventies_print` — Faded 70s Color Paper — fade
- `retro_radar_sweep` — Green Radar CRT Sweep — retro/vhs
- `old_newspaper_press` — Rotary Newspaper Press Spin — rotate
- `retro_lens_flare_amber` — Amber Optical Flare — retro/vhs
- `faded_kodachrome_red` — Kodachrome Vivid Red — fade
- `super_eight_overexposure` — Super 8 Shutter Flash Out — flash/light
- `retro_radio_tuning_drift` — AM Radio Dial Drift — retro/vhs
- `golden_hour_silhouette` — Golden Hour Silhouette Flare — flash/light
- `bleach_bypass_grit` — Bleach Bypass War Film Grit — retro/vhs
- `macro_eye_reflection` — Macro Eye Iris Reflection — mask/wipe
- `cinematic_flashback_tint` — Faded Memory Flashback Tint — fade
- `cinematic_iris_focus` — Circular Iris Transition Soft — mask/wipe
- `telephoto_compression` — Telephoto Perspective Crunch — 3d/depth
- `dramatic_cross_light` — Chiaroscuro Side Split Light — mask/wipe
- `corridor_vanishing_point` — One-Point Perspective Hallway — 3d/depth
- `cinematic_final_curtain` — CinemaScope Fade Out To Black — mask/wipe
- `shake_subwoofer_heavy_pulse` — Subwoofer Heavy Pulse — shake
- `shake_sub_depth_charge_blast` — Depth Charge Blast — 3d/depth
- `light_cyber_grid_laser_sweep` — Cyber Grid Laser Sweep — slide/pan
- `glitch_vram_memory_leak_artifact` — VRAM Artifact Corruption — flash/light
- `glitch_cracked_lcd_screen_bleed` — Cracked LCD Bleed — glitch
- `glitch_hdmi_handshake_failure` — HDMI Handshake Intermittent — shake, glitch
- `glitch_corrupted_nvram_boot` — Corrupted NVRAM Boot — glitch
- `glitch_crt_degauss_coil_wobble` — CRT Degauss Coil Wobble — retro/vhs
- `glitch_defective_ccd_sensor_line` — Defective CCD Sensor Line — glitch
- `glitch_laserdisc_dropout_snow` — Laserdisc Dropout Snow — glitch
- `glitch_raster_beam_collapse` — Raster Beam Collapse — glitch
- `threed_camera_dolly_zoom_vertigo` — 3D Hitchcock Dolly Vertigo — zoom/scale
- `threed_orbital_satellite_sweep` — 3D Orbital Satellite Sweep — slide/pan
- `motion_kinetic_whip_pan_left` — Kinetic Whip Pan Left — slide/pan
- `motion_kinetic_whip_tilt_down` — Kinetic Whip Tilt Down — slide/pan
- `motion_camera_boom_arc_sweep` — Camera Boom Arc Sweep — slide/pan
- `retro_technicolor_two_strip` — Technicolor Two-Strip — retro/vhs
- `retro_35mm_panavision_grain` — 35mm Panavision Vintage Grain — retro/vhs
- `retro_arcade_crt_curved_glass` — Arcade CRT Curved Glass Glow — flash/light
- `retro_viewmaster_3d_reel` — View-Master 3D Reel Disk — retro/vhs
- `retro_holga_toy_camera_light_leak` — Holga 120 Toy Camera Leak — retro/vhs
- `retro_diana_f_soft_focus_glow` — Diana F+ Dreamy Soft Focus — retro/vhs

## Gaya preview paling banyak dipakai bersama

| Jumlah preset | Contoh ID |
|---:|---|
| 48 | `trending_wipe_sweep_right`, `trending_circle_iris_open`, `trending_checkerboard_reveal`, `trending_split_vertical_in`, `trending_curtain_open_smooth`, `trending_venetian_blinds_in` |
| 43 | `golden_shimmer`, `ambient_glow_magenta`, `headlight_glare`, `neon_pulse_blue`, `disco_ball_shimmer`, `soft_backlight` |
| 24 | `hologram_flicker`, `halo_angelic`, `warm_tungsten`, `cool_mercury_arc`, `billboard_swing`, `mirror_dimension_fold` |
| 21 | `shining_star`, `fiber_optic_stream`, `pulsar_radiation`, `opal_iridescence`, `subtle_lens_glint`, `wave_mesh_distortion` |
| 19 | `warm_candle_flicker`, `solar_eclipse_rim`, `aurora_borealis`, `fluorescent_buzz`, `phosphor_screen`, `pulse_loop` |
| 18 | `breathing_motion`, `rubber_band_bounce`, `kinetic_typography_flow`, `action_sprint_rush`, `micro_bounce_pop`, `kinetic_rebound` |
| 18 | `trending_jelly_physics_wobble`, `quantization_noise`, `lcd_pixel_dead`, `digital_jitter_fast`, `speed_ramp_curve`, `skate_glide_curve` |
| 18 | `stage_spotlight`, `neon_pulse_red`, `ember_glow`, `glimmer_haze`, `optical_ring_flare`, `blue_hour_twilight_mood` |
| 16 | `fade_in`, `tumble_in_space`, `floating_tiles_in`, `page_turn_curled`, `unfold_accordion`, `pyramid_slice_in` |
| 15 | `radiant_core`, `anti_gravity_rise`, `floating_air`, `heartbeat_rhythm`, `smooth_elevator_sink`, `hyperlapse_stride` |
| 13 | `spiral_orbit_3d`, `orbit_camera_360`, `floating_cube_matrix`, `cinematic_flyby`, `perlin_terrain_3d`, `threed_perspective_pitch_up` |
| 12 | `ambient_glow_cyan`, `bokeh_glimmer`, `fairy_dust_sparkle`, `beacon_light`, `shimmer_dust`, `neon_noir_rain_puddle` |
| 11 | `matrix_glint`, `depth_pull_z`, `threed_perspective_tilt_right`, `threed_infinite_mirror_tunnel`, `threed_hyperbolic_space_warp`, `threed_vortex_drain_suction` |
| 9 | `rolling_cylinder_spin`, `dramatic_doorway_frame`, `slow_tilt_up_monument`, `threed_floating_card_hover`, `threed_depth_layer_separation`, `threed_door_swing_close_3d` |
| 9 | `slow_drift_ambient`, `smooth_glide_right`, `elastic_stretch_y`, `fluid_dynamic_flow`, `aerial_drone_sweep`, `motion_smooth_pedestal_rise` |

## Duplikasi

ID duplikat: tidak ada.

- Nama "3D Depth Push Z-Axis" muncul 2 kali
- Nama "3D Tunnel Dive In" muncul 2 kali
- Nama "3D Anti-Gravity Rise" muncul 2 kali
- Nama "3D Floating Card Hover" muncul 2 kali
- Nama "Speed Ramp Curve" muncul 2 kali
- Nama "Hyper Speed Dash" muncul 2 kali
- Nama "Rubber Band Bounce" muncul 2 kali
- Nama "FPV Drone Flythrough" muncul 2 kali
- Nama "VHS Vintage Flicker" muncul 2 kali
- Nama "8mm Silent Film Jitter" muncul 2 kali
- Nama "16mm Projector Hum" muncul 2 kali
- Nama "Polaroid Instant Develop" muncul 2 kali
- Nama "Blockbuster Hero Reveal" muncul 2 kali
- Nama "Peleburan Skala Silang" muncul 2 kali
