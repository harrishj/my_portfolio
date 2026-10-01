import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/widgets/scroll_reveal.dart';
import 'package:portfolio/widgets/editable_text.dart';
import 'package:portfolio/providers/app_providers.dart';

class ContactSection extends ConsumerWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 960;

    final contentAsync = ref.watch(contentProvider('contact'));
    final data = contentAsync.value ?? {};

    final leftLabel = data['leftLabel'] ?? '05 / CONTACT';
    final locationTag = data['locationTag'] ?? 'EST. 2026 / CHENNAI — WORLDWIDE';
    final title = data['title'] ?? "LET'S TALK";
    final subtitle = data['subtitle'] ??
        'Open for software engineering roles, mobile architecture, and high-impact product launches.';
    final infoTitle = data['infoTitle'] ?? 'DIRECT CHANNELS';
    final email = data['email'] ?? 'harrishcsbs@gmail.com';
    final github = data['github'] ?? 'github.com/harrishj';
    final linkedin = data['linkedin'] ?? 'linkedin.com/in/harrish-j-908378269';
    final formTitle = data['formTitle'] ?? 'TRANSMIT A MESSAGE';
    final submitBtnLabel = data['submitBtnLabel'] ?? 'DISPATCH INQUIRY';

    void updateDoc(String key, String val) {
      ref.read(dbServiceProvider).updateContent('contact', {key: val});
    }

    return Container(
      width: double.infinity,
      color: AppColors.sand, // INVERTED SAND BAND
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 64,
        vertical: isMobile ? 56 : 100,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: ScrollReveal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Meta Row with responsive wrap
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, color: AppColors.ink),
                        const SizedBox(width: 10),
                        EditableTextWidget(
                          text: leftLabel,
                          onSave: (val) => updateDoc('leftLabel', val),
                          style: GoogleFonts.unbounded(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    EditableTextWidget(
                      text: locationTag,
                      onSave: (val) => updateDoc('locationTag', val),
                      style: GoogleFonts.interTight(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.ink.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: AppColors.ink.withValues(alpha: 0.2), height: 1),
                const SizedBox(height: 40),

                // Giant Inverted Heading
                EditableTextWidget(
                  text: title,
                  onSave: (val) => updateDoc('title', val),
                  style: GoogleFonts.unbounded(
                    fontSize: isMobile ? 40 : 88,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2.0,
                    height: 0.9,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 20),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: EditableTextWidget(
                    text: subtitle,
                    onSave: (val) => updateDoc('subtitle', val),
                    style: GoogleFonts.interTight(
                      fontSize: isMobile ? 15 : 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 56),

                // Split Layout: Left Direct Channels, Right Message Form
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDirectInfo(context, infoTitle, email, github, linkedin, updateDoc),
                          const SizedBox(height: 48),
                          _InvertedContactForm(
                            recipientEmail: email,
                            formTitle: formTitle,
                            submitBtnLabel: submitBtnLabel,
                            onFormTitleSave: (v) => updateDoc('formTitle', v),
                            onSubmitBtnLabelSave: (v) => updateDoc('submitBtnLabel', v),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 9,
                            child: _buildDirectInfo(context, infoTitle, email, github, linkedin, updateDoc),
                          ),
                          const SizedBox(width: 48),
                          Container(
                            width: 1,
                            height: 420,
                            color: AppColors.ink.withValues(alpha: 0.15),
                          ),
                          const SizedBox(width: 48),
                          Expanded(
                            flex: 11,
                            child: _InvertedContactForm(
                              recipientEmail: email,
                              formTitle: formTitle,
                              submitBtnLabel: submitBtnLabel,
                              onFormTitleSave: (v) => updateDoc('formTitle', v),
                              onSubmitBtnLabelSave: (v) => updateDoc('submitBtnLabel', v),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectInfo(
    BuildContext context,
    String infoTitle,
    String email,
    String github,
    String linkedin,
    Function(String, String) updateDoc,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditableTextWidget(
          text: infoTitle,
          onSave: (val) => updateDoc('infoTitle', val),
          style: GoogleFonts.interTight(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 24),

        // Email 1-click copy row
        _SandActionRow(
          label: 'PRIMARY EMAIL (CLICK TO COPY)',
          value: email,
          icon: Icons.copy_rounded,
          onTap: () {
            Clipboard.setData(ClipboardData(text: email));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email copied to clipboard!'),
                backgroundColor: AppColors.ink,
                duration: Duration(seconds: 2),
              ),
            );
          },
          onSave: (v) => updateDoc('email', v),
        ),
        const SizedBox(height: 20),

        // GitHub Row
        _SandActionRow(
          label: 'GITHUB REPOSITORIES',
          value: github,
          icon: Icons.arrow_outward_rounded,
          onTap: () async {
            final clean = github.replaceFirst('https://', '').replaceFirst('http://', '');
            final uri = Uri.parse('https://$clean');
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
          onSave: (v) => updateDoc('github', v),
        ),
        const SizedBox(height: 20),

        // LinkedIn Row
        _SandActionRow(
          label: 'LINKEDIN NETWORK',
          value: linkedin,
          icon: Icons.arrow_outward_rounded,
          onTap: () async {
            final clean = linkedin.replaceFirst('https://', '').replaceFirst('http://', '');
            final uri = Uri.parse('https://$clean');
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
          onSave: (v) => updateDoc('linkedin', v),
        ),
      ],
    );
  }
}

class _SandActionRow extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Function(String) onSave;

  const _SandActionRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.onSave,
  });

  @override
  State<_SandActionRow> createState() => _SandActionRowState();
}

class _SandActionRowState extends State<_SandActionRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _hovered ? AppColors.ink : AppColors.ink.withValues(alpha: 0.25),
                width: _hovered ? 1.5 : 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.interTight(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.ink.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 4),
                    EditableTextWidget(
                      text: widget.value,
                      onSave: widget.onSave,
                      style: GoogleFonts.unbounded(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(widget.icon, size: 16, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvertedContactForm extends ConsumerStatefulWidget {
  final String recipientEmail;
  final String formTitle;
  final String submitBtnLabel;
  final Function(String) onFormTitleSave;
  final Function(String) onSubmitBtnLabelSave;

  const _InvertedContactForm({
    required this.recipientEmail,
    required this.formTitle,
    required this.submitBtnLabel,
    required this.onFormTitleSave,
    required this.onSubmitBtnLabelSave,
  });

  @override
  ConsumerState<_InvertedContactForm> createState() => _InvertedContactFormState();
}

class _InvertedContactFormState extends ConsumerState<_InvertedContactForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final senderEmail = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || senderEmail.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out your name, email, and message before sending.'),
          backgroundColor: AppColors.ink,
        ),
      );
      return;
    }

    if (!senderEmail.contains('@') || !senderEmail.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid email address so I can reply.'),
          backgroundColor: AppColors.ink,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final emailService = ref.read(emailContactServiceProvider);
      final result = await emailService.sendMessage(
        recipientEmail: widget.recipientEmail,
        senderName: name,
        senderEmail: senderEmail,
        messageContent: message,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppColors.ink,
              duration: const Duration(seconds: 4),
            ),
          );
          _nameController.clear();
          _emailController.clear();
          _messageController.clear();
        } else {
          // Failure: Show informative toast with mailto fallback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.message} Opening direct mail client...'),
              backgroundColor: AppColors.ink,
              duration: const Duration(seconds: 4),
            ),
          );
          final mailtoUri = Uri.parse(
            'mailto:${widget.recipientEmail}?subject=${Uri.encodeComponent('Inquiry from $name')}&body=${Uri.encodeComponent('Name: $name\nEmail: $senderEmail\n\n$message')}',
          );
          if (await canLaunchUrl(mailtoUri)) {
            await launchUrl(mailtoUri);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error dispatching inquiry: $e'),
            backgroundColor: AppColors.ink,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderStyle = UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.ink.withValues(alpha: 0.3), width: 1),
    );
    final focusBorderStyle = const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.ink, width: 2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditableTextWidget(
          text: widget.formTitle,
          onSave: widget.onFormTitleSave,
          style: GoogleFonts.interTight(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          enabled: !_isSubmitting,
          style: GoogleFonts.interTight(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'YOUR NAME',
            labelStyle: GoogleFonts.interTight(color: AppColors.ink.withValues(alpha: 0.7), fontSize: 11, letterSpacing: 1.2),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: borderStyle,
            enabledBorder: borderStyle,
            focusedBorder: focusBorderStyle,
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _emailController,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.interTight(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'YOUR EMAIL',
            labelStyle: GoogleFonts.interTight(color: AppColors.ink.withValues(alpha: 0.7), fontSize: 11, letterSpacing: 1.2),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: borderStyle,
            enabledBorder: borderStyle,
            focusedBorder: focusBorderStyle,
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _messageController,
          enabled: !_isSubmitting,
          maxLines: 4,
          style: GoogleFonts.interTight(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: 'PROJECT DETAILS & INQUIRY',
            labelStyle: GoogleFonts.interTight(color: AppColors.ink.withValues(alpha: 0.7), fontSize: 11, letterSpacing: 1.2),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: borderStyle,
            enabledBorder: borderStyle,
            focusedBorder: focusBorderStyle,
          ),
        ),
        const SizedBox(height: 36),
        InkWell(
          onTap: _isSubmitting ? null : _handleSubmit,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting) ...[
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.sand,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'TRANSMITTING...',
                    style: GoogleFonts.interTight(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: AppColors.sand,
                    ),
                  ),
                ] else ...[
                  EditableTextWidget(
                    text: widget.submitBtnLabel,
                    onSave: widget.onSubmitBtnLabelSave,
                    style: GoogleFonts.interTight(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: AppColors.sand,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 14, color: AppColors.sand),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
