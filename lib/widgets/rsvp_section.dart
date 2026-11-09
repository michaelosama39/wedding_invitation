import 'package:flutter/material.dart';
import '../data/wedding_data.dart';
import '../theme.dart';
import '../data/common.dart';

class WishesController extends ValueNotifier<List<Wish>> {
  WishesController() : super(List.of(WeddingData.initialWishes));

  void add(Wish wish) => value = [wish, ...value];
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
  String _sentName = '';

  @override
  void dispose() {
    _name.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    widget.wishes.add(Wish(_name.text.trim(), _message.text.trim()));
    setState(() {
      _sentName = _name.text.trim();
      _sent = true;
    });
    _message.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      doubleRules: true,
      maxWidth: 520,
      child: Reveal(
        child: Column(
          children: [
            const SectionTitle(
              eyebrow: 'Say something sweet',
              title: 'Leave a Message',
            ),
            Text(
              'Share your wishes and love for the couple',
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
        'Thank you, $_sentName',
        textAlign: TextAlign.center,
        style: AppText.script(context.isNarrow ? 36 : 44),
      ),
      const SizedBox(height: 8),
      Text(
        'Your message means the world to us.',
        textAlign: TextAlign.center,
        style: AppText.body(19),
      ),
      const SizedBox(height: 24),
      PillButton(
        label: 'Write another',
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
          decoration: const InputDecoration(labelText: 'Your name'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _message,
          maxLines: 4,
          maxLength: 300,
          style: AppText.body(17, height: 1.4),
          decoration: const InputDecoration(labelText: 'Your message'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please write a message' : null,
        ),
        const SizedBox(height: 20),
        Center(
          child: PillButton(
            label: 'Send Message',
            filled: true,
            onPressed: _submit,
          ),
        ),
      ],
    ),
  );
}
