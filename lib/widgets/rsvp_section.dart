import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../data/wedding_data.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../data/common.dart';

/// Live list of guest wishes, backed by the Firestore `wishes` collection.
///
/// Starts from [WeddingData.initialWishes] (currently empty, so the Wishes
/// section shows its empty state) until the first snapshot arrives.
class WishesController extends ValueNotifier<List<Wish>> {
  WishesController() : super(List.of(WeddingData.initialWishes)) {
    _sub = _collection
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .listen(
          _onSnapshot,
          onError: (Object e) => debugPrint('Wishes stream error: $e'),
        );
  }

  static final _collection = FirebaseFirestore.instance.collection('wishes');
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _sub;

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    final wishes = [
      for (final doc in snap.docs)
        Wish(
          doc.data()['name'] as String? ?? '',
          doc.data()['message'] as String? ?? '',
        ),
    ];
    value = wishes.isEmpty ? List.of(WeddingData.initialWishes) : wishes;
  }

  /// Saves a wish. The live stream shows it right away (local write); the
  /// returned future completes once the server has accepted it.
  Future<void> add(Wish wish) => _collection.add({
    'name': wish.name,
    'message': wish.message,
    'createdAt': FieldValue.serverTimestamp(),
  });

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class RsvpSection extends StatefulWidget {
  final WishesController wishes;
  const RsvpSection({super.key, required this.wishes});

  @override
  State<RsvpSection> createState() => _RsvpSectionState();
}

class _RsvpSectionState extends State<RsvpSection> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _message = TextEditingController();
  bool _sent = false;
  bool _sending = false;
  String _sentName = '';

  @override
  void dispose() {
    _name.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending || !_form.currentState!.validate()) return;
    final name = _name.text.trim();
    setState(() => _sending = true);
    try {
      await widget.wishes.add(Wish(name, _message.text.trim()));
      if (!mounted) return;
      setState(() {
        _sentName = name;
        _sent = true;
      });
      _message.clear();
    } catch (e) {
      debugPrint('Failed to send wish: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.sendFailed(context))));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      doubleRules: true,
      maxWidth: 520,
      child: Reveal(
        child: Column(
          children: [
            SectionTitle(
              eyebrow: S.saySomethingSweet(context),
              title: S.leaveMessage(context),
            ),
            Text(
              S.shareWishes(context),
              textAlign: TextAlign.center,
              style: AppText.body(
                18,
                color: AppColors.ink(0.75),
                style: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _sent ? _thanks() : _formBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thanks() => Column(
    key: const ValueKey('thanks'),
    children: [
      Text(
        _sentName.isEmpty
            ? S.thankYou(context)
            : S.thankYouName(context, _sentName),
        textAlign: TextAlign.center,
        style: AppText.script(context.isNarrow ? 36 : 44),
      ),
      const SizedBox(height: 8),
      Text(
        S.messageMeansWorld(context),
        textAlign: TextAlign.center,
        style: AppText.body(19),
      ),
      const SizedBox(height: 24),
      PillButton(
        label: S.writeAnother(context),
        onPressed: () => setState(() => _sent = false),
      ),
    ],
  );

  Widget _formBody() => Form(
    key: _form,
    child: Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _name,
          style: AppText.body(17, height: 1.3),
          decoration: InputDecoration(labelText: S.yourNameOptional(context)),
          validator: (v) => (v != null && v.trim().length > 60)
              ? S.nameTooLong(context)
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _message,
          maxLines: 4,
          maxLength: 300,
          style: AppText.body(17, height: 1.4),
          decoration: InputDecoration(labelText: S.yourMessage(context)),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? S.pleaseWriteMessage(context)
              : null,
        ),
        const SizedBox(height: 20),
        Center(
          child: PillButton(
            label: (_sending ? S.sending : S.sendMessage)(context),
            filled: true,
            onPressed: _sending ? null : _submit,
          ),
        ),
      ],
    ),
  );
}
