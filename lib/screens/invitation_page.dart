import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:wedding_invitation/widgets/countdown_section.dart';
import 'package:wedding_invitation/widgets/gallery_section.dart';
import 'package:wedding_invitation/widgets/hero_section.dart';
import 'package:wedding_invitation/widgets/itinerary_section.dart';
import 'package:wedding_invitation/widgets/rsvp_section.dart';
import 'package:wedding_invitation/widgets/location_section.dart';
import 'package:wedding_invitation/widgets/wishes_section.dart';

import '../data/wedding_data.dart';
import '../theme.dart';
import '../widgets/footer_section.dart';

class InvitationPage extends StatefulWidget {
  const InvitationPage({super.key});

  @override
  State<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  final _rsvpKey = GlobalKey();
  final _wishes = WishesController();
  final _player = AudioPlayer();
  bool _hasMusic = false;
  bool _playing = false;

  /// Gentle auto-scroll through the invitation, starting once the hero intro
  /// animation has played. Any guest interaction stops it for good.
  static const _autoScrollDelay = Duration(milliseconds: 3200);
  static const _autoScrollSpeed = 45.0; // logical pixels per second
  late final Ticker _autoScroller = createTicker(_onAutoScrollTick);
  Timer? _autoScrollStart;
  Duration _lastTick = Duration.zero;
  bool _autoScrollStopped = false;

  @override
  void initState() {
    super.initState();
    _startMusic();
    _autoScrollStart = Timer(_autoScrollDelay, () {
      if (!mounted || _autoScrollStopped) return;
      if (MediaQuery.of(context).disableAnimations) return;
      _lastTick = Duration.zero;
      _autoScroller.start();
    });
  }

  void _onAutoScrollTick(Duration elapsed) {
    if (!_scroll.hasClients) return;
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final pos = _scroll.position;
    final next = pos.pixels + _autoScrollSpeed * dt;
    if (next >= pos.maxScrollExtent) {
      _scroll.jumpTo(pos.maxScrollExtent);
      _stopAutoScroll();
      return;
    }
    _scroll.jumpTo(next);
  }

  void _stopAutoScroll() {
    if (_autoScrollStopped) return;
    _autoScrollStopped = true;
    _autoScrollStart?.cancel();
    if (_autoScroller.isActive) _autoScroller.stop();
  }

  /// Plays assets/audio/music.mp3 if the couple added one. The envelope tap
  /// counts as the user gesture browsers require for autoplay.
  Future<void> _startMusic() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    if (!manifest.listAssets().contains(WeddingAssets.music)) return;
    await _player.setReleaseMode(ReleaseMode.loop);
    try {
      // AssetSource adds the "assets/" prefix itself (audioplayers' default
      // AudioCache prefix), so pass the path without it.
      final source = WeddingAssets.music.replaceFirst(RegExp(r'^assets/'), '');
      await _player.play(AssetSource(source), volume: 0.6);
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
    _autoScrollStart?.cancel();
    _autoScroller.dispose();
    _scroll.dispose();
    _wishes.dispose();
    _player.dispose();
    super.dispose();
  }

  void _goToRsvp() {
    final ctx = _rsvpKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );
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
              child: Icon(
                _playing ? Icons.music_note : Icons.music_off_outlined,
              ),
            )
          : null,
      // Stop auto-scrolling on any touch, click, mouse wheel or user scroll.
      body: Listener(
        onPointerDown: (_) => _stopAutoScroll(),
        onPointerSignal: (_) => _stopAutoScroll(),
        child: NotificationListener<UserScrollNotification>(
          onNotification: (n) {
            if (n.direction != ScrollDirection.idle) _stopAutoScroll();
            return false;
          },
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      controller: _scroll,
      child: Column(
        children: [
          HeroSection(onRsvp: _goToRsvp),
          const CountdownSection(),
          const ItinerarySection(),
          const GallerySection(),
          const LocationSection(),
          RsvpSection(key: _rsvpKey, wishes: _wishes),
          WishesSection(wishes: _wishes),
          const FooterSection(),
        ],
      ),
    );
  }
}
