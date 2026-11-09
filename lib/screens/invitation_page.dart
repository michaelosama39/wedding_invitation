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
import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/footer_section.dart';

class InvitationPage extends StatefulWidget {
  const InvitationPage({super.key});

  @override
  State<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
  late final Ticker _autoScroller;
  Timer? _autoScrollStart;
  Duration _lastTick = Duration.zero;
  bool _autoScrollStopped = false;

  @override
  void initState() {
    super.initState();
    // Created eagerly: a lazy ticker would first be built inside dispose(),
    // when looking up TickerMode on the deactivated element throws.
    _autoScroller = createTicker(_onAutoScrollTick);
    WidgetsBinding.instance.addObserver(this);
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
    if (!mounted) return;
    setState(() => _hasMusic = true);
    await _playMusic();
  }

  /// True once the track has been loaded (prepared) by the native player.
  bool _sourceReady = false;
  Future<void>? _loading;

  /// Whether the app is in the foreground. Music never plays in background.
  bool _foreground = true;

  /// Loads the track once. Android's MediaPlayer throws MEDIA_ERROR -38
  /// ("invalid state") if it is told to loop/play before the source is
  /// prepared, so each step waits for the previous one.
  Future<void> _ensureLoaded() {
    if (_sourceReady) return Future.value();
    return _loading ??= () async {
      try {
        // AssetSource adds the "assets/" prefix itself (audioplayers' default
        // AudioCache prefix), so pass the path without it.
        final source = WeddingAssets.music.replaceFirst(
          RegExp(r'^assets/'),
          '',
        );
        await _player.setSource(AssetSource(source)); // completes once prepared
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.setVolume(0.6);
        _sourceReady = true;
      } finally {
        _loading = null;
      }
    }();
  }

  /// Starts the music, unless the guest paused it or the app went to the
  /// background while the track was still loading.
  Future<void> _playMusic() async {
    if (mounted) setState(() => _playing = true);
    try {
      await _ensureLoaded();
      if (!mounted || !_playing || !_foreground) return;
      await _player.resume();
    } catch (e) {
      // Autoplay blocked (web) or the player failed: reset so the next tap on
      // the music button starts from a clean player.
      debugPrint('Music could not start: $e');
      _sourceReady = false;
      await _player.stop().catchError((_) {});
      if (mounted) setState(() => _playing = false);
    }
  }

  Future<void> _pauseMusic() async {
    if (mounted) setState(() => _playing = false);
    if (_sourceReady) await _player.pause().catchError((_) {});
  }

  Future<void> _toggleMusic() => _playing ? _pauseMusic() : _playMusic();

  /// Pause when the app is hidden (home button, lock screen, app switch) and
  /// resume on return if the guest had the music on.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasForeground = _foreground;
    _foreground = state == AppLifecycleState.resumed;
    if (!_sourceReady || wasForeground == _foreground) return;
    if (_foreground) {
      if (_playing) _player.resume().catchError((_) {});
    } else {
      _player.pause().catchError((_) {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoScrollStart?.cancel();
    _autoScroller.dispose();
    _scroll.dispose();
    _wishes.dispose();
    // Stop before releasing so the native player can't keep sounding.
    _player.stop().catchError((_) {}).whenComplete(_player.dispose);
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
              tooltip: (_playing ? S.pauseMusic : S.playMusic)(context),
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
