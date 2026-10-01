import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class EditableMediaWidget extends ConsumerStatefulWidget {
  final String? mediaUrl;
  final Widget fallbackWidget;
  final Function(Uint8List, String, String, bool isVideo) onUpload;
  
  const EditableMediaWidget({
    super.key,
    this.mediaUrl,
    required this.fallbackWidget,
    required this.onUpload,
  });

  @override
  ConsumerState<EditableMediaWidget> createState() => _EditableMediaWidgetState();
}

class _EditableMediaWidgetState extends ConsumerState<EditableMediaWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickMedia(bool isVideo) async {
    final XFile? pickedFile = isVideo 
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);
        
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      final bytes = await pickedFile.readAsBytes();
      final mimeType = pickedFile.mimeType ?? (isVideo ? 'video/mp4' : 'image/jpeg');
      await widget.onUpload(bytes, pickedFile.name, mimeType, isVideo);
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      return widget.fallbackWidget;
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        widget.fallbackWidget,
        if (_isUploading)
          Container(
            color: Colors.black87,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.amber),
            ),
          ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Material(
            color: Colors.transparent,
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xF0141312),
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: AppColors.amber, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MediaActionPill(
                    icon: Icons.videocam,
                    label: 'VIDEO',
                    onTap: () => _pickMedia(true),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 16, color: AppColors.hairline),
                  const SizedBox(width: 8),
                  _MediaActionPill(
                    icon: Icons.image,
                    label: 'IMAGE',
                    onTap: () => _pickMedia(false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.amber, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.interTight(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.amber,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
