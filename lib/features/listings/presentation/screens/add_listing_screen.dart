import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/listing_model.dart';
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

  ListingCategory _selectedCategory = ListingCategory.sherehe;
  ListingType _selectedType = ListingType.kukodisha;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitListing() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final user = ref.read(currentUserProvider);

    final newListing = ListingModel(
      id: 'listing_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: user?.id ?? 'user_1',
      ownerName: user?.name ?? 'Mwenye Kifaa',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      type: _selectedType,
      pricePerDay: double.tryParse(_priceController.text.trim()) ?? 10000,
      images: const ['placeholder.jpg'],
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : 'Dar es Salaam, Tanzania',
      isAvailable: true,
      rating: 5.0,
      reviewCount: 0,
      createdAt: DateTime.now(),
    );

    ref.read(listingsProvider.notifier).addListing(newListing);

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kifaa chako kimeongezwa kwa mafanikio! 🎉'),
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
      backgroundColor: AppColors.background, // 70% Neutral Base
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
              // Photo Upload Box (70% Surface + 10% Accent touch)
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chagua picha kutoka kwenye simu yako.')),
                  );
                },
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, size: 28, color: AppColors.primary),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Bofya kuongeza picha ya kifaa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Picha ya mbele, ya wazi na yenye mwanga mzuri',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
          color: AppColors.textPrimary, // 20% Typography
        ),
      ),
    );
  }
}
