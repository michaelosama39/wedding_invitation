import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/wedding_data.dart';
import '../theme.dart';
import '../widgets/sections.dart';

class InvitationPage extends StatefulWidget {
  const InvitationPage({super.key});

  @override
  State<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  final _scroll = ScrollController();
  final _rsvpKey = GlobalKey();
  final _wishes = WishesController();
  final _player = AudioPlayer();
  bool _hasMusic = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _startMusic();
  }

  /// Plays assets/audio/music.mp3 if the couple added one. The envelope tap
  /// counts as the user gesture browsers require for autoplay.
  Future<void> _startMusic() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    if (!manifest.listAssets().contains('assets/${WeddingAssets.music}')) return;
    await _player.setReleaseMode(ReleaseMode.loop);
    try {
      await _player.play(AssetSource(WeddingAssets.music), volume: 0.6);
      if (mounted) setState(() => _hasMusic = _playing = true);
    } catch (_) {
      // Autoplay blocked — show the button so the guest can start it.
      if (mounted) setState(() => _hasMusic = true);
    }
  }

  Future<void> _toggleMusic() async {
    if (_playing) {
      await _player.pause();
    } else {
      await _player.resume();
    }
    setState(() => _playing = !_playing);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _wishes.dispose();
    _player.dispose();
    super.dispose();
  }

  void _goToRsvp() {
    final ctx = _rsvpKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 900), curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _hasMusic
          ? FloatingActionButton.small(
              onPressed: _toggleMusic,
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              foregroundColor: AppColors.foreground,
              elevation: 2,
              tooltip: _playing ? 'Pause music' : 'Play music',
              child: Icon(_playing ? Icons.music_note : Icons.music_off_outlined),
            )
          : null,
      body: SingleChildScrollView(
        controller: _scroll,
        child: Column(
          children: [
            HeroSection(onRsvp: _goToRsvp),
            const CountdownSection(),
            const ItinerarySection(),
            const WelcomeSection(),
            const GallerySection(),
            const VenueSection(),
            // const DressCodeSection(),
            // const GiftsSection(),
            RsvpSection(key: _rsvpKey, wishes: _wishes),
            WishesSection(wishes: _wishes),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}
