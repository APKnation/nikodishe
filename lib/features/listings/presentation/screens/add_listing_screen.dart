import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../data/models/listing_model.dart';
import '../../../../data/services/api_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/listings_provider.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  ListingCategory _selectedCategory = ListingCategory.sherehe;
  ListingType _selectedType = ListingType.kukodisha;
  bool _isSubmitting = false;

  // Selected images list (Device file paths, URLs, or templates)
  final List<String> _selectedImages = [];

  // Sampuli za picha bora za vifaa kulingana na aina
  final Map<ListingCategory, List<Map<String, String>>> _sampleTemplates = {
    ListingCategory.sherehe: [
      {
        'title': 'Viti 100 vya Sherehe',
        'url': 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800',
      },
      {
        'title': 'Meza za Sherehe',
        'url': 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
      },
      {
        'title': 'Mahema na Tenti',
        'url': 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      },
      {
        'title': 'Spika na Mziki (PA)',
        'url': 'https://images.unsplash.com/photo-1545128485-c400e7702796?w=800',
      },
    ],
    ListingCategory.ujenzi: [
      {
        'title': 'Scaffolding za Chuma',
        'url': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800',
      },
      {
        'title': 'Mixer ya Saruji',
        'url': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800',
      },
      {
        'title': 'Generator ya Umeme',
        'url': 'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=800',
      },
      {
        'title': 'Compactor / Rola',
        'url': 'https://images.unsplash.com/photo-1578328819058-b69f3a3b0f6b?w=800',
      },
    ],
    ListingCategory.ukumbi: [
      {
        'title': 'Ukumbi wa Harusi',
        'url': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      },
      {
        'title': 'Ukumbi wa Mikutano (AC)',
        'url': 'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?w=800',
      },
      {
        'title': 'Bustani ya Nje (Garden)',
        'url': 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
      },
    ],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// 1. Fungua device gallery / storage kuchagua picha moja au zaidi
  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (final file in pickedFiles) {
            if (!_selectedImages.contains(file.path)) {
              _selectedImages.add(file.path);
            }
          }
        });
      }
    } catch (e) {
      // Fallback kwa single image picker ikiwa multi-image haipatikani kwenye mfumo
      try {
        final XFile? singleFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1600,
        );
        if (singleFile != null) {
          setState(() {
            if (!_selectedImages.contains(singleFile.path)) {
              _selectedImages.add(singleFile.path);
            }
          });
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hitilafu ya kufungua mafaili: $err'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// 2. Piga picha mpya kwa kamera ya kifaa
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (photo != null) {
        setState(() {
          if (!_selectedImages.contains(photo.path)) {
            _selectedImages.add(photo.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hitilafu ya kamera: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 3. Fungua Modal BottomSheet yenye machaguo yote
  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildImagePickerDialog(),
    );
  }

  Widget _buildImagePickerDialog() {
    final urlInputController = TextEditingController();
    final templates = _sampleTemplates[_selectedCategory] ?? [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chagua Njia ya Kuweka Picha',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Unaweza kubrowse picha kutoka kwenye simu yako au kupiga picha mpya.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Kitufe cha 1: BROWSE DEVICE GALLERY
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              tileColor: AppColors.primaryLight.withOpacity(0.3),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: Colors.white, size: 22),
              ),
              title: const Text(
                'Chagua Kutoka Simuni (Browse Files)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
              ),
              subtitle: const Text(
                'Fungua matunzio au mafaili ya picha kwenye simu yako',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
              onTap: () {
                Navigator.pop(context);
                _pickImagesFromGallery();
              },
            ),

            const SizedBox(height: 10),

            // Kitufe cha 2: CAMERA
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              tileColor: Colors.grey.shade50,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
              ),
              title: const Text(
                'Piga Picha kwa Kamera (Take Photo)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Tumia kamera kupiga picha ya kifaa chako sasa hivi',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Kitufe cha 3: SAMPULI ZA HARAKA
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Au Tumia Sampuli za Picha (${_getCategoryName(_selectedCategory)})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 95,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final template = templates[index];
                  final isAlreadyAdded = _selectedImages.contains(template['url']);

                  return GestureDetector(
                    onTap: () {
                      if (!isAlreadyAdded) {
                        setState(() {
                          _selectedImages.add(template['url']!);
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 95,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAlreadyAdded ? AppColors.success : AppColors.border,
                              width: isAlreadyAdded ? 2 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: AppNetworkImage(
                              imageUrl: template['url']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (isAlreadyAdded)
                          Container(
                            width: 95,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(Icons.check_circle, color: Colors.white, size: 24),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                            ),
                            child: Text(
                              template['title']!,
                              style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Kitufe cha 4: WEKA LINK YA PICHA (URL)
            const Row(
              children: [
                Icon(Icons.link, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Au Weka Link ya Mtandaoni (Image URL)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlInputController,
              decoration: InputDecoration(
                hintText: 'https://...',
                prefixIcon: const Icon(Icons.image_search, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: () {
                    final text = urlInputController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        _selectedImages.add(text);
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(ListingCategory category) {
    switch (category) {
      case ListingCategory.sherehe:
        return 'Sherehe';
      case ListingCategory.ujenzi:
        return 'Ujenzi';
      case ListingCategory.ukumbi:
        return 'Ukumbi';
    }
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final user = ref.read(currentUserProvider);

    // Upload local device images to backend if available
    final List<String> uploadedImages = [];
    final apiService = ApiService();

    for (final path in _selectedImages) {
      if (path.startsWith('/') || path.startsWith('file://')) {
        try {
          final file = File(path.replaceFirst('file://', ''));
          if (file.existsSync()) {
            final remoteUrl = await apiService.uploadImageFile(file);
            if (remoteUrl.isNotEmpty) {
              uploadedImages.add(remoteUrl);
              continue;
            }
          }
        } catch (_) {
          // Keep local path if upload fails
        }
      }
      uploadedImages.add(path);
    }

    // Kama mtumiaji hajaweka picha yoyote, chukua sampuli nzuri ya kwanza ya category husika
    final finalImages = uploadedImages.isNotEmpty
        ? uploadedImages
        : [
            _sampleTemplates[_selectedCategory]?.first['url'] ??
                'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800'
          ];

    final newListing = ListingModel(
      id: 'listing_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: user?.id ?? 'user_1',
      ownerName: user?.name ?? 'Mwenye Kifaa',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      type: _selectedType,
      pricePerDay: double.tryParse(_priceController.text.trim()) ?? 10000,
      images: finalImages,
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : 'Dar es Salaam, Tanzania',
      isAvailable: true,
      rating: 5.0,
      reviewCount: 0,
      createdAt: DateTime.now(),
    );

    await ref.read(listingsProvider.notifier).addListing(newListing);

    setState(() {
      _isSubmitting = false;
      _selectedImages.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kifaa chako na picha za simu zimehifadhiwa kwa mafanikio! 🎉'),
        backgroundColor: AppColors.success,
      ),
    );

    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _locationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Weka Kifaa Kipya'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('Picha za Kifaa Kutoka Kwenye Simu * (${_selectedImages.length} zimechaguliwa)'),
              const SizedBox(height: 6),

              // Sehemu ya Kupakia Picha
              if (_selectedImages.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, size: 30, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Weka picha halisi ya kifaa chako',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Picha ya wazi inasaidia wateja kuamini na kukodi haraka.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Vitufe viwili vya wazi vya BROWSE na CAMERA
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.photo_library_outlined, size: 20),
                                label: const Text('Browse Files', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: _pickImagesFromGallery,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                                label: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: _pickImageFromCamera,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.textSecondary),
                        label: const Text('Au fungua machaguo zaidi na sampuli', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        onPressed: _showImagePickerModal,
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    // Horizontal Selected Images List
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          if (index == _selectedImages.length) {
                            // Kitufe cha kuongeza picha nyingine kutoka kwenye simu
                            return GestureDetector(
                              onTap: _showImagePickerModal,
                              child: Container(
                                width: 125,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.primary, width: 1.5),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined, size: 30, color: AppColors.primary),
                                    SizedBox(height: 6),
                                    Text(
                                      'Ongeza Picha',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                    Text(
                                      'Browse/Kamera',
                                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final imgPath = _selectedImages[index];
                          final isPrimary = index == 0;

                          return Stack(
                            children: [
                              Container(
                                width: 130,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isPrimary ? AppColors.primary : AppColors.border,
                                    width: isPrimary ? 2.5 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AppNetworkImage(
                                    imageUrl: imgPath,
                                    width: 130,
                                    height: 140,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (isPrimary)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Jalada Kuu',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Picha ya kwanza ndiyo itakayoonekana kama jalada.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedImages.clear();
                            });
                          },
                          child: const Text('Futa Zote', style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // Title
              _buildSectionLabel('Jina la Kifaa *'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Mfano: Scaffolding za Ujenzi, Viti 50 vya Plastiki',
                  prefixIcon: Icon(Icons.handyman_outlined, color: AppColors.primary),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Tafadhali ingiza jina la kifaa' : null,
              ),

              const SizedBox(height: 18),

              // Category selector
              _buildSectionLabel('Category ya Kifaa *'),
              DropdownButtonFormField<ListingCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary),
                ),
                items: const [
                  DropdownMenuItem(value: ListingCategory.sherehe, child: Text('🎉 Vifaa vya Sherehe')),
                  DropdownMenuItem(value: ListingCategory.ujenzi, child: Text('🏗️ Vifaa vya Ujenzi')),
                  DropdownMenuItem(value: ListingCategory.ukumbi, child: Text('🏛️ Ukumbi / Venue')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),

              const SizedBox(height: 18),

              // Type (Kukodisha / Kuuza)
              _buildSectionLabel('Aina ya Ofa *'),
              DropdownButtonFormField<ListingType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.sell_outlined, color: AppColors.primary),
                ),
                items: const [
                  DropdownMenuItem(value: ListingType.kukodisha, child: Text('Kukodisha tu')),
                  DropdownMenuItem(value: ListingType.kuuza, child: Text('Kuuza tu')),
                  DropdownMenuItem(value: ListingType.zote, child: Text('Kukodisha na Kuuza')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),

              const SizedBox(height: 18),

              // Price
              _buildSectionLabel('Bei ya Kukodisha (TZS kwa siku) *'),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Mfano: 25,000',
                  prefixText: 'TZS ',
                  prefixStyle: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  prefixIcon: Icon(Icons.payments_outlined, color: AppColors.primary),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Tafadhali ingiza bei' : null,
              ),

              const SizedBox(height: 18),

              // Location
              _buildSectionLabel('Eneo / Location ya Kifaa *'),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Mfano: Mwenge, Dar es Salaam',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Tafadhali ingiza eneo' : null,
              ),

              const SizedBox(height: 18),

              // Description
              _buildSectionLabel('Maelezo Kamili ya Kifaa *'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Eleza ubora, hali yake (mpya/imetumika), idadi, na masharti yoyote...',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Tafadhali andika maelezo ya kifaa' : null,
              ),

              const SizedBox(height: 32),

              // Submit Button (10% Accent CTA)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitListing,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Weka Kifaa Kwenye Mfumo',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
