import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedding_invitation/data/wedding_data.dart';
import 'package:wedding_invitation/theme.dart';
import 'package:wedding_invitation/data/common.dart';


class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  Future<void> _openMaps() async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': WeddingData.mapsQuery,
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return SectionShell(
      doubleRules: true,
      child: Reveal(
        child: Column(
          children: [
            Text('Location', style: AppText.script(narrow ? 56 : 72)),
            const SizedBox(height: 16),
            Text(
              WeddingData.locationName,
              textAlign: TextAlign.center,
              style: AppText.display(32, weight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '${WeddingData.locationCity}\n${WeddingData.locationCountry}'
                  .toUpperCase(),
              textAlign: TextAlign.center,
              style: AppText.label(
                14,
                color: AppColors.ink(0.7),
                spacing: 2.8,
                weight: FontWeight.w300,
              ).copyWith(height: 2),
            ),
            const SizedBox(height: 32),
            // Live, interactive Google Map.
            _MapCard(onTap: _openMaps),
            const SizedBox(height: 32),
            PillButton(
              label: 'Get directions',
              icon: Icons.near_me_outlined,
              onPressed: _openMaps,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final VoidCallback onTap;
  const _MapCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Container(
      height: narrow ? 256 : 320,
      decoration: BoxDecoration(border: Border.all(color: AppColors.ink(0.1))),
      child: _GoogleMapEmbed(query: WeddingData.mapsQuery, onTap: onTap),
    );
  }
}

class _GoogleMapEmbed extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  const _GoogleMapEmbed({required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: TuscanLandscapePainter(variant: 0.35),
        child: const SizedBox.expand(),
      ),
    );
  }
}
