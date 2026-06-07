import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/imgbb_storage_service.dart';
import '../../services/firebase_product_service.dart';
import '../../models/product_model.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final ProductModel product;
  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  // ── Colors ────────────────────────────────────────────────────────────────
  static const _primary      = Color(0xFF2979FF);
  static const _bg           = Color(0xFFF2F5FB);
  static const _inputFill    = Color(0xFFEAF1FF);
  static const _border       = Color(0xFFE4EAF3);
  static const _textPrimary  = Color(0xFF101828);
  static const _textSecondary= Color(0xFF667085);
  static const _textHint     = Color(0xFF9CA3AF);
  static const _success      = Color(0xFF059669);
  static const _successLight = Color(0xFFD1FAE5);
  static const _error        = Color(0xFFDC2626);

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _locationCtrl;

  late ProductCategory  _category;
  late ProductCondition _condition;

  // Images: existing network URLs + newly picked local files
  late List<String> _existingUrls;
  final List<File>   _newImages      = [];
  final List<String> _uploadedNewUrls = [];

  bool _isUploading = false;
  bool _isSaving    = false;

  final _storageService = ImgBBStorageService();
  final _productService = FirebaseProductService();
  final _imagePicker    = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleCtrl    = TextEditingController(text: p.title);
    _descCtrl     = TextEditingController(text: p.description);
    _priceCtrl    = TextEditingController(text: p.price.toStringAsFixed(2));
    _locationCtrl = TextEditingController(text: p.location);
    _category     = p.category;
    _condition    = p.condition;
    _existingUrls = List<String>.from(p.imageUrls);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  List<String> get _allImageUrls =>
      [..._existingUrls, ..._uploadedNewUrls];

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    if (_allImageUrls.length >= 5) {
      _snack('Maximum 5 photos allowed');
      return;
    }
    try {
      final files = await _imagePicker.pickMultiImage(
          imageQuality: 80, maxWidth: 1000, maxHeight: 1000);
      if (files.isNotEmpty) {
        setState(() {
          final space = 5 - _allImageUrls.length;
          _newImages.addAll(files.take(space).map((f) => File(f.path)));
        });
      }
    } catch (e) {
      _snack('Could not pick images: $e');
    }
  }

  Future<void> _uploadNewImages() async {
    if (_newImages.isEmpty) return;
    setState(() => _isUploading = true);
    try {
      for (int i = 0; i < _newImages.length; i++) {
        _snack('Uploading photo ${i + 1} of ${_newImages.length}…');
        final url = await _storageService.uploadImage(_newImages[i]);
        _uploadedNewUrls.add(url);
      }
      _newImages.clear();
      if (mounted) setState(() {});
      _snack('Photos uploaded ✓');
    } catch (e) {
      _snack('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty ||
        _priceCtrl.text.trim().isEmpty ||
        _locationCtrl.text.trim().isEmpty) {
      _snack('Please fill in all fields');
      return;
    }
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      _snack('Enter a valid price');
      return;
    }
    if (_allImageUrls.isEmpty) {
      _snack('Please keep at least one photo');
      return;
    }
    if (_newImages.isNotEmpty) {
      _snack('Upload your new photos first');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await _productService.updateProduct(widget.product.id, {
        'title':       _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price':       price,
        'location':    _locationCtrl.text.trim(),
        'category':    _category.name,
        'condition':   _condition.name,
        'imageUrls':   _allImageUrls,
        'updatedAt':   DateTime.now().toIso8601String(),
      });
      if (mounted) {
        _snack('Listing updated ✓');
        Navigator.pop(context);
      }
    } catch (e) {
      _snack('Error saving: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String _conditionLabel(ProductCondition c) {
    switch (c) {
      case ProductCondition.new_:    return 'New';
      case ProductCondition.likeNew: return 'Like New';
      case ProductCondition.good:    return 'Good';
      case ProductCondition.fair:    return 'Fair';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Listing',
            style: GoogleFonts.outfit(
                fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text('Save',
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photos section
            Text('Photos',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary)),
            const SizedBox(height: 8),
            Text('Tap a photo to remove it',
                style: GoogleFonts.inter(fontSize: 13, color: _textSecondary)),
            const SizedBox(height: 12),

            // Existing + new image previews
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Existing network images
                  ..._existingUrls.asMap().entries.map((e) => _networkThumb(
                      e.value, () => setState(() => _existingUrls.removeAt(e.key)))),

                  // Newly picked local images (not yet uploaded)
                  ..._newImages.asMap().entries.map((e) => _localThumb(
                      e.value, () => setState(() => _newImages.removeAt(e.key)))),

                  // Add more button
                  if (_allImageUrls.length + _newImages.length < 5)
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 90, height: 90,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _primary.withOpacity(0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.add_photo_alternate_rounded,
                            color: _primary, size: 28),
                      ),
                    ),
                ],
              ),
            ),

            // Upload new images button
            if (_newImages.isNotEmpty) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadNewImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary.withOpacity(0.1),
                  foregroundColor: _primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: _isUploading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _primary))
                    : const Icon(Icons.cloud_upload_outlined, size: 20),
                label: Text(
                  _isUploading
                      ? 'Uploading…'
                      : 'Upload ${_newImages.length} new photo(s)',
                  style: GoogleFonts.outfit(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],

            if (_uploadedNewUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: _success, size: 18),
                    const SizedBox(width: 8),
                    Text('${_uploadedNewUrls.length} new photo(s) uploaded',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _success)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text('Details',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary)),
            const SizedBox(height: 12),

            _field(_titleCtrl,    'Title',       Icons.title_rounded),
            const SizedBox(height: 12),
            _field(_descCtrl,     'Description', Icons.description_rounded,
                maxLines: 4),
            const SizedBox(height: 12),
            _field(_priceCtrl,    'Price',       Icons.attach_money_rounded,
                keyboard: TextInputType.number),
            const SizedBox(height: 12),
            _field(_locationCtrl, 'Location',    Icons.location_on_rounded),
            const SizedBox(height: 12),

            _dropdown<ProductCategory>(
              label: 'Category',
              icon: Icons.category_rounded,
              value: _category,
              items: ProductCategory.values,
              label2: (c) => c.name,
              onChanged: (v) =>
                  setState(() => _category = v ?? ProductCategory.electronics),
            ),
            const SizedBox(height: 12),
            _dropdown<ProductCondition>(
              label: 'Condition',
              icon: Icons.info_outline_rounded,
              value: _condition,
              items: ProductCondition.values,
              label2: _conditionLabel,
              onChanged: (v) =>
                  setState(() => _condition = v ?? ProductCondition.good),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text('Save Changes',
                        style: GoogleFonts.outfit(
                            fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _networkThumb(String url, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 90, height: 90,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _inputFill,
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 2, right: 10,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(
                  color: _error, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _localThumb(File file, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 90, height: 90,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
                image: FileImage(file), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 2, right: 10,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(
                  color: _error, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: GoogleFonts.inter(fontSize: 14, color: _textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: _textHint),
        prefixIcon: Icon(icon, color: _textSecondary, size: 20),
        filled: true,
        fillColor: _inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _primary, width: 2)),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required String Function(T) label2,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: _textSecondary, size: 20),
        filled: true,
        fillColor: _inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _primary, width: 2)),
      ),
      style: GoogleFonts.inter(fontSize: 14, color: _textPrimary),
      dropdownColor: Colors.white,
      items: items
          .map((t) => DropdownMenuItem(
              value: t,
              child: Text(label2(t),
                  style: GoogleFonts.inter(
                      fontSize: 14, color: _textPrimary))))
          .toList(),
    );
  }
}
