import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class EditableImageWidget extends ConsumerStatefulWidget {
  final String? imageUrl;
  final Widget? fallbackWidget;
  final Function(Uint8List, String, String) onUpload;
  
  const EditableImageWidget({
    super.key,
    this.imageUrl,
    this.fallbackWidget,
    required this.onUpload,
  });

  @override
  ConsumerState<EditableImageWidget> createState() => _EditableImageWidgetState();
}

class _EditableImageWidgetState extends ConsumerState<EditableImageWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      final bytes = await pickedFile.readAsBytes();
      final mimeType = pickedFile.mimeType ?? 'image/jpeg';
      await widget.onUpload(bytes, pickedFile.name, mimeType);
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    Widget imageWidget = widget.imageUrl != null && widget.imageUrl!.isNotEmpty
        ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
        : (widget.fallbackWidget ?? const Icon(Icons.image, size: 50, color: AppColors.textMuted));

    if (!isAdmin) {
      return imageWidget;
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        imageWidget,
        if (_isUploading) const CircularProgressIndicator(color: AppColors.amber),
        Positioned(
          right: 8,
          bottom: 8,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            color: AppColors.amber,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: Colors.black26, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.black, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'PHOTO',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
