import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/imgbb_storage_service.dart';
import '../../services/firebase_product_service.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';

class CreateProductScreen extends ConsumerStatefulWidget {
  const CreateProductScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateProductScreen> createState() =>
      _CreateProductScreenState();
}

class _CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  // ── Colors ───────────────────────────────────────────────────────────────────
  static const _background    = Color(0xFFF2F5FB);
  static const _inputFill     = Color(0xFFEAF1FF);
  static const _primary       = Color(0xFF2979FF);
  static const _textPrimary   = Color(0xFF101828);
  static const _textSecondary = Color(0xFF667085);
  static const _textHint      = Color(0xFF9CA3AF);
  static const _border        = Color(0xFFE4EAF3);
  static const _success       = Color(0xFF059669);
  static const _successLight  = Color(0xFFD1FAE5);
  static const _error         = Color(0xFFDC2626);

  // ── Controllers ──────────────────────────────────────────────────────────────
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;

  // ── Form state ───────────────────────────────────────────────────────────────
  ProductCategory  _selectedCategory  = ProductCategory.electronics;
  ProductCondition _selectedCondition = ProductCondition.new_;
  bool _isLoading   = false;
  bool _isUploading = false;

  // ── Image state ──────────────────────────────────────────────────────────────
  final List<File>   _selectedImages    = [];
  final List<String> _uploadedImageUrls = [];

  // ── Services ─────────────────────────────────────────────────────────────────
  final ImgBBStorageService    _storageService = ImgBBStorageService();
  final FirebaseProductService _productService  = FirebaseProductService();
  final ImagePicker            _imagePicker     = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController       = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController       = TextEditingController();
    _locationController    = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ── Condition helpers ────────────────────────────────────────────────────────
  String _conditionLabel(ProductCondition cond) {
    switch (cond) {
      case ProductCondition.new_:
        return 'New';
      case ProductCondition.likeNew:
        return 'Like New';
      case ProductCondition.good:
        return 'Good';
      case ProductCondition.fair:
        return 'Fair';
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Listing',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image section
            _buildImageSection(),
            const SizedBox(height: 24),

            // 2. Section header
            Text(
              'Product Details',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Text fields
            _buildTextField(
              _titleController,
              'Product Title',
              Icons.title_rounded,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              _descriptionController,
              'Description',
              Icons.description_rounded,
              maxLines: 4,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              _priceController,
              'Price',
              Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              _locationController,
              'Location',
              Icons.location_on_rounded,
            ),
            const SizedBox(height: 14),

            // 4. Category dropdown
            _buildDropdown<ProductCategory>(
              label: 'Category',
              icon: Icons.category_rounded,
              value: _selectedCategory,
              items: ProductCategory.values,
              itemLabel: (c) => _capitalize(c.name),
              onChanged: (v) => setState(
                () => _selectedCategory = v ?? ProductCategory.electronics,
              ),
            ),
            const SizedBox(height: 14),

            // 5. Condition dropdown
            _buildDropdown<ProductCondition>(
              label: 'Condition',
              icon: Icons.info_outline_rounded,
              value: _selectedCondition,
              items: ProductCondition.values,
              itemLabel: _conditionLabel,
              onChanged: (v) => setState(
                () => _selectedCondition = v ?? ProductCondition.new_,
              ),
            ),
            const SizedBox(height: 32),

            // 6. Submit button
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Image section ────────────────────────────────────────────────────────────
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Photos',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add up to 5 photos of your item',
          style: GoogleFonts.inter(fontSize: 13, color: _textSecondary),
        ),
        const SizedBox(height: 12),

        if (_selectedImages.isEmpty) ...[
          // ── Empty state placeholder ─────────────────────────────────────────
          GestureDetector(
            onTap: (_isLoading || _isUploading) ? null : _pickImages,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: _inputFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      color: _primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add photos',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'JPG, PNG up to 32MB each',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: _textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // ── Image thumbnail list ────────────────────────────────────────────
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length +
                  (_selectedImages.length < 5 ? 1 : 0),
              itemBuilder: (ctx, i) {
                // "Add more" tile
                if (i == _selectedImages.length) {
                  return GestureDetector(
                    onTap: (_isLoading || _isUploading) ? null : _pickImages,
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _primary.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: _primary, size: 32),
                    ),
                  );
                }

                // Image thumbnail with remove button
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_selectedImages[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedImages.removeAt(i)),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: _error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Upload / success banner ─────────────────────────────────────────
          if (_uploadedImageUrls.isEmpty)
            ElevatedButton.icon(
              onPressed:
                  (_isUploading || _isLoading) ? null : _uploadImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary.withOpacity(0.1),
                foregroundColor: _primary,
                elevation: 0,
                disabledBackgroundColor: _primary.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: _isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _primary),
                    )
                  : const Icon(Icons.cloud_upload_outlined, size: 20),
              label: Text(
                _isUploading
                    ? 'Uploading...'
                    : 'Upload ${_selectedImages.length} Photo(s)',
                style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _successLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: _success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_uploadedImageUrls.length} photo(s) uploaded',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _success,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  // ── Text field builder ───────────────────────────────────────────────────────
  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: _textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: _textHint),
        prefixIcon: Icon(icon, color: _textSecondary, size: 20),
        filled: true,
        fillColor: _inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // ── Dropdown builder ─────────────────────────────────────────────────────────
  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF667085)),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          selectedItemBuilder: (ctx) => items.map((item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(icon, size: 20, color: _textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    itemLabel(item),
                    style: GoogleFonts.inter(
                        fontSize: 14, color: _textPrimary),
                  ),
                ],
              ),
            );
          }).toList(),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: GoogleFonts.inter(
                        fontSize: 14, color: _textPrimary),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── Submit button ────────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed:
            (_isLoading || _isUploading) ? null : _handleCreateProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: _primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Creating listing...',
                    style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Text(
                'Post Listing',
                style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────
  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxHeight: 1000,
        maxWidth: 1000,
      );
      if (pickedFiles.isNotEmpty) {
        setState(() {
          final remaining = 5 - _selectedImages.length;
          _selectedImages.addAll(
            pickedFiles.take(remaining).map((f) => File(f.path)),
          );
          // Reset uploaded URLs so the user must re-upload after changing images.
          _uploadedImageUrls.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick images: $e')),
        );
      }
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;
    setState(() => _isUploading = true);
    try {
      _uploadedImageUrls.clear();
      for (int i = 0; i < _selectedImages.length; i++) {
        if (!_storageService.validateImage(_selectedImages[i])) {
          throw Exception('Invalid image at position ${i + 1}');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Uploading photo ${i + 1} of ${_selectedImages.length}...'),
              duration: const Duration(milliseconds: 800),
            ),
          );
        }
        final url = await _storageService.uploadImage(_selectedImages[i]);
        _uploadedImageUrls.add(url);
      }
      if (mounted) {
        setState(() {}); // Refresh to show success banner
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photos uploaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handleCreateProduct() async {
    // ── Validation ────────────────────────────────────────────────────────────
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    if (_uploadedImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload at least one photo')),
      );
      return;
    }

    final authState = ref.read(authStateProvider);
    final userId    = authState.value?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to post')),
      );
      return;
    }

    // ── Create ────────────────────────────────────────────────────────────────
    setState(() => _isLoading = true);
    try {
      final product = ProductModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        category: _selectedCategory,
        condition: _selectedCondition,
        imageUrls: List<String>.from(_uploadedImageUrls),
        sellerId: userId,
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        latitude: 0.0,
        longitude: 0.0,
        location: _locationController.text.trim(),
        likes: const [],
        views: 0,
      );

      await _productService.createProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Listing posted successfully! 🎉')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating listing: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
