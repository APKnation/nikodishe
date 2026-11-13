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
        content: Text('Kifaa chako kimeongezwa kwa mafanikio!'),
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo upload placeholder
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Uchaguzi wa picha utafunguliwa.')),
                  );
                },
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primary),
                      const SizedBox(height: 8),
                      const Text(
                        'Bofya kuongeza picha ya kifaa',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text('Jina la Kifaa *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Mfano: Scaffolding za Ujenzi, Viti 50 vya Plastiki',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Tafadhali ingiza jina la kifaa' : null,
              ),

              const SizedBox(height: 16),

              // Category selector
              const Text('Category ya Kifaa *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<ListingCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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

              const SizedBox(height: 16),

              // Type (Kukodisha / Kuuza)
              const Text('Aina ya Ofa *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<ListingType>(
                value: _selectedType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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

              const SizedBox(height: 16),

              // Price
              const Text('Bei (TZS kwa siku) *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Mfano: 25000',
                  prefixText: 'TZS ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Tafadhali ingiza bei' : null,
              ),

              const SizedBox(height: 16),

              // Location
              const Text('Eneo / Location *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Mfano: Mwenge, Dar es Salaam',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Tafadhali ingiza eneo' : null,
              ),

              const SizedBox(height: 16),

              // Description
              const Text('Maelezo ya Kifaa *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Eleza ubora, hali yake, idadi, masharti, n.k.',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Tafadhali andika maelezo' : null,
              ),

              const SizedBox(height: 28),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Weka Kifaa Kwenye Mfumo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

