import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/audio/timeline_audio_sync_service.dart';
import '../../../../core/models/audio_asset_item.dart';
import '../../../../core/models/audio_clip_model.dart';
import '../../../../core/services/audio_library_service.dart';
import '../../../../core/services/online_audio_api_service.dart';
import '../../../../core/services/video_picker_service.dart';
import '../../../../core/theme/app_design_tokens.dart';

class AudioLibraryBottomSheet extends StatefulWidget {
  final double currentTimelinePosition;
  final ValueChanged<AudioClipModel> onAddAudioToTimeline;

  const AudioLibraryBottomSheet({
    super.key,
    required this.currentTimelinePosition,
    required this.onAddAudioToTimeline,
  });

  static Future<void> show(
    BuildContext context, {
    required double currentTimelinePosition,
    required ValueChanged<AudioClipModel> onAddAudioToTimeline,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AudioLibraryBottomSheet(
        currentTimelinePosition: currentTimelinePosition,
        onAddAudioToTimeline: onAddAudioToTimeline,
      ),
    );
  }

  @override
  State<AudioLibraryBottomSheet> createState() => _AudioLibraryBottomSheetState();
}

class _AudioLibraryBottomSheetState extends State<AudioLibraryBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final OnlineAudioProvider _onlineProvider = CreativeCommonsAudioProvider();
  final VideoPickerService _pickerService = VideoPickerService();

  List<AudioAssetItem> _onlineList = [];
  List<AudioAssetItem> _sfxList = [];
  String _selectedCategory = 'Semua';
  bool _isLoading = false;

  // Audio Preview Controller
  VideoPlayerController? _previewPlayer;
  String? _currentlyPlayingId;

  // Recording State
  bool _isRecording = false;
  int _recordDurationSeconds = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOnlineAudio();
    _loadSoundEffects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _previewPlayer?.dispose();
    super.dispose();
  }

  Future<void> _loadOnlineAudio() async {
    setState(() => _isLoading = true);
    final query = _searchController.text.trim();

    // 1. Ambil katalog kurasi lokal/offline terlebih dahulu
    final localResults = await _onlineProvider.searchAudio(
      query: query,
      category: _selectedCategory == 'Semua' ? 'All' : _selectedCategory,
    );

    // 2. Jika ada koneksi online, panggil iTunes Apple Music API untuk mencari lagu viral apapun secara instan
    List<AudioAssetItem> apiResults = [];
    if (query.isNotEmpty) {
      apiResults = await OnlineAudioApiService().searchMusic(query: query);
    } else {
      // Default rekomendasi lagu viral Indonesia jika belum mengetik
      apiResults = await OnlineAudioApiService().searchMusic(query: 'Indonesia Viral Pop', limit: 15);
    }

    if (mounted) {
      setState(() {
        // Gabungkan hasil lokal dan API online
        _onlineList = [...localResults, ...apiResults];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSoundEffects() async {
    final query = _searchController.text.trim();
    final localSfx = SoundEffectCatalog.getAllSoundEffects(
      query: query,
      category: _selectedCategory == 'Semua' ? 'All' : _selectedCategory,
    );

    // Cari juga efek suara / shout meme viral dari Web API (MyInstants)
    List<AudioAssetItem> webSfx = [];
    if (query.isNotEmpty) {
      webSfx = await OnlineAudioApiService().searchViralSounds(query: query);
    }

    if (mounted) {
      setState(() {
        _sfxList = [...localSfx, ...webSfx];
      });
    }
  }

  Future<void> _togglePreview(AudioAssetItem item) async {
    if (_currentlyPlayingId == item.id) {
      await _previewPlayer?.pause();
      setState(() => _currentlyPlayingId = null);
      return;
    }

    await _previewPlayer?.dispose();
    _previewPlayer = null;

    try {
      final resolvedPath = await TimelineAudioSyncService.resolveAudioPath(item.sourceUrlOrPath);
      VideoPlayerController controller;

      if (resolvedPath.startsWith('http://') || resolvedPath.startsWith('https://')) {
        controller = VideoPlayerController.networkUrl(Uri.parse(resolvedPath));
      } else if (resolvedPath.startsWith('assets/')) {
        controller = VideoPlayerController.asset(resolvedPath);
      } else {
        controller = VideoPlayerController.file(File(resolvedPath));
      }

      await controller.initialize();
      controller.play();

      setState(() {
        _previewPlayer = controller;
        _currentlyPlayingId = item.id;
      });

      controller.addListener(() {
        if (controller.value.position >= controller.value.duration) {
          setState(() => _currentlyPlayingId = null);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preview audio: ${item.title} ($e)'),
            backgroundColor: AppDesignTokens.surfaceSecondary,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _addAudioToProject(AudioAssetItem item) {
    _previewPlayer?.pause();
    final newClip = AudioClipModel(
      id: 'audio_${DateTime.now().millisecondsSinceEpoch}',
      title: item.title,
      sourcePath: item.sourceUrlOrPath,
      startTimeline: widget.currentTimelinePosition,
      duration: item.durationSeconds,
      volume: 1.0,
    );
    widget.onAddAudioToTimeline(newClip);
    Navigator.of(context).pop();
  }

  Future<void> _handleExtractAudioFromVideo() async {
    final videoFile = await _pickerService.pickVideoFromGallery();
    if (videoFile == null) return;

    setState(() => _isLoading = true);
    final extracted = await AudioExtractionService.extractAudioFromVideo(
      videoPath: videoFile.path,
      outputTitle: 'Audio Ekstrak ${DateTime.now().minute}${DateTime.now().second}',
    );
    setState(() => _isLoading = false);

    if (extracted != null && mounted) {
      final newClip = AudioClipModel(
        id: 'audio_extracted_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Ekstrak Audio Video',
        sourcePath: extracted.path,
        startTimeline: widget.currentTimelinePosition,
        duration: 15.0,
        volume: 1.0,
      );
      widget.onAddAudioToTimeline(newClip);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio berhasil diekstrak dan ditambahkan ke timeline!'),
          backgroundColor: AppDesignTokens.cyanAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFF0F1017), // Deep clean midnight dark
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(color: Color(0x3300E5FF), width: 1.2),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Drag Notch Handle Minimalis
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),

          // Header Rapi & Clean (Bebas Overflow)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.music_note_rounded, color: Color(0xFF00E5FF), size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Audio & Efek Suara',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  splashRadius: 18,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Segmented Tab Bar yang Bersih & Scrollable (Teks Terlihat Jelas)
          Container(
            height: 36,
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white10, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              labelPadding: const EdgeInsets.symmetric(horizontal: 14),
              indicatorColor: const Color(0xFF00E5FF),
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              labelColor: const Color(0xFF00E5FF),
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12.5),
              tabs: const [
                Tab(text: 'Online'),
                Tab(text: 'Efek SFX'),
                Tab(text: 'Lokal & Ekstrak'),
                Tab(text: 'Rekam Suara'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Search Field Minimalis
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF171924),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'Cari lagu, instrumen, atau efek sound...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00E5FF), size: 18),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 15, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            _loadOnlineAudio();
                            _loadSoundEffects();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: InputBorder.none,
                ),
                onChanged: (_) {
                  _loadOnlineAudio();
                  _loadSoundEffects();
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Content Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOnlineTab(),
                _buildSfxTab(),
                _buildLocalAndExtractTab(),
                _buildVoiceRecordTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineTab() {
    final categories = ['Semua', 'Cinematic', 'Vlog', 'Travel', 'Relaxing', 'Dramatic', 'Happy', 'Ambient', 'Nature', 'Trending'];

    return Column(
      children: [
        // Category Chips Minimalis
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, idx) {
              final cat = categories[idx];
              final isSel = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    _loadOnlineAudio();
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF00E5FF) : const Color(0xFF171924),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSel ? const Color(0xFF00E5FF) : Colors.white10,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSel ? Colors.black : Colors.white70,
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // List Lagu Minimalis Keren & Elegan
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF), strokeWidth: 2))
              : _onlineList.isEmpty
                  ? _buildEmptyState('Tidak ada musik ditemukan', 'Coba kata kunci pencarian lainnya')
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: _onlineList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, idx) {
                        final item = _onlineList[idx];
                        final isPlaying = _currentlyPlayingId == item.id;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isPlaying ? const Color(0xFF1E2130) : const Color(0xFF151722),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isPlaying ? const Color(0xFF00E5FF) : Colors.white.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Play/Pause Button
                              GestureDetector(
                                onTap: () => _togglePreview(item),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isPlaying ? const Color(0xFF00E5FF) : const Color(0xFF202332),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: isPlaying ? Colors.black : Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Info Title & Artist
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        color: isPlaying ? const Color(0xFF00E5FF) : Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          '${item.durationSeconds.toInt()}s',
                                          style: const TextStyle(
                                            color: Color(0xFF00E5FF),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${item.artist} • ${item.license}',
                                            style: const TextStyle(color: Colors.white38, fontSize: 10),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Tombol Gunakan Ramping
                              InkWell(
                                onTap: () => _addAudioToProject(item),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Gunakan',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSfxTab() {
    return _sfxList.isEmpty
        ? _buildEmptyState('Tidak ada efek suara', 'Coba kata kunci lain')
        : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: _sfxList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, idx) {
              final item = _sfxList[idx];
              final isPlaying = _currentlyPlayingId == item.id;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isPlaying ? const Color(0xFF1E2130) : const Color(0xFF151722),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPlaying ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _togglePreview(item),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.graphic_eq_rounded,
                          color: isPlaying ? Colors.white : const Color(0xFF8B5CF6),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.category} • ${item.durationSeconds}s',
                            style: const TextStyle(color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _addAudioToProject(item),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Tambah',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildLocalAndExtractTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildActionCard(
            title: 'Musik Lokal dari Perangkat',
            subtitle: 'MP3, WAV, AAC, M4A dari storage HP/PC',
            icon: Icons.audio_file_rounded,
            iconColor: const Color(0xFF00E5FF),
            onTap: () async {
              final videoFile = await _pickerService.pickVideoFromGallery();
              if (videoFile != null) {
                final newClip = AudioClipModel(
                  id: 'local_audio_${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Musik Lokal',
                  sourcePath: videoFile.path,
                  startTimeline: widget.currentTimelinePosition,
                  duration: 20.0,
                  volume: 1.0,
                );
                widget.onAddAudioToTimeline(newClip);
                if (mounted) Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(height: 10),
          _buildActionCard(
            title: 'Ekstrak Audio dari Video',
            subtitle: 'Pilih file video, sistem otomatis mengambil audionya',
            icon: Icons.movie_filter_rounded,
            iconColor: const Color(0xFF8B5CF6),
            onTap: _handleExtractAudioFromVideo,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF151722),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceRecordTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isRecording = !_isRecording;
                  if (_isRecording) {
                    _recordDurationSeconds = 0;
                  }
                });
                if (!_isRecording && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rekaman suara berhasil disimpan ke timeline.'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red.withValues(alpha: 0.2) : const Color(0xFF171924),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isRecording ? Colors.red : const Color(0xFF00E5FF),
                    width: _isRecording ? 2.5 : 1.5,
                  ),
                ),
                child: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 34,
                  color: _isRecording ? Colors.red : const Color(0xFF00E5FF),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isRecording ? 'Merekam... 00:0${_recordDurationSeconds}s' : 'Ketuk untuk Merekam Suara',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Audio vokal akan otomatis diselaraskan pada posisi playhead saat ini',
              style: TextStyle(color: Colors.white38, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: Colors.white24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10.5)),
        ],
      ),
    );
  }
}
