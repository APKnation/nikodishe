import '../models/user_model.dart';
import '../models/listing_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';
import '../models/review_model.dart';
import '../models/notification_model.dart';

// ---------------------------------------------------------------------------
// MOCK USERS
// ---------------------------------------------------------------------------

final List<UserModel> mockUsers = [
  UserModel(
    id: 'user_001',
    name: 'Amina Salehe',
    phone: '+255712345678',
    role: UserRole.owner,
    location: 'Dar es Salaam (Kinondoni)',
    photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    whatsapp: '+255712345678',
    instagram: '@amina_rentals_tz',
    facebook: 'Amina Event & Construction Equipment',
    tiktok: '@amina_kodisha_tz',
    createdAt: DateTime(2024, 1, 10),
  ),
  UserModel(
    id: 'user_002',
    name: 'John Mwangi',
    phone: '+255754321987',
    role: UserRole.renter,
    location: 'Arusha',
    photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    whatsapp: '+255754321987',
    instagram: '@john_mwangi_arusha',
    createdAt: DateTime(2024, 2, 5),
  ),
  UserModel(
    id: 'user_003',
    name: 'Fatuma Nguvu',
    phone: '+255789654321',
    role: UserRole.renter,
    location: 'Mwanza',
    photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    whatsapp: '+255789654321',
    createdAt: DateTime(2024, 3, 20),
  ),
];

// ---------------------------------------------------------------------------
// MOCK LISTINGS
// ---------------------------------------------------------------------------

final List<ListingModel> mockListings = [
  // --- SHEREHE ---
  ListingModel(
    id: 'listing_001',
    ownerId: 'user_001',
    ownerName: 'Amina Salehe',
    title: 'Meza za Sherehe (Set ya 10)',
    description:
        'Meza 10 za plastiki zenye ubora wa juu, zinafaa kwa sherehe za harusi, birthday na mikutano. Zinakuja na vitambaa vya meza bila malipo ya ziada.',
    category: ListingCategory.sherehe,
    type: ListingType.kukodisha,
    pricePerDay: 50000,
    images: [
      'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
    ],
    location: 'Kinondoni, Dar es Salaam',
    latitude: -6.7924,
    longitude: 39.2083,
    isAvailable: true,
    rating: 4.8,
    reviewCount: 24,
    createdAt: DateTime(2024, 3, 1),
  ),
  ListingModel(
    id: 'listing_002',
    ownerId: 'user_001',
    ownerName: 'Amina Salehe',
    title: 'Viti 100 vya Sherehe',
    description:
        'Viti 100 vya chuma, rangi nyeupe, bora kwa sherehe za nje na ndani. Vinasafishwa na kudisinfected kabla ya kukodishwa.',
    category: ListingCategory.sherehe,
    type: ListingType.kukodisha,
    pricePerDay: 80000,
    images: [
      'https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=800',
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
    ],
    location: 'Ilala, Dar es Salaam',
    latitude: -6.8160,
    longitude: 39.2803,
    isAvailable: true,
    rating: 4.5,
    reviewCount: 18,
    createdAt: DateTime(2024, 3, 15),
  ),
  ListingModel(
    id: 'listing_003',
    ownerId: 'user_001',
    ownerName: 'Amina Salehe',
    title: 'Hema Kubwa ya Sherehe (10x20m)',
    description:
        'Hema ya msitari, ukubwa wa 10x20 mita, inaweza kuchukua watu 200. Inajumuisha nguzo, kamba na paa la maji. Delivery ya bure ndani ya Dar es Salaam.',
    category: ListingCategory.sherehe,
    type: ListingType.kukodisha,
    pricePerDay: 300000,
    images: [
      'https://images.unsplash.com/photo-1478827387698-1527781a4887?w=800',
      'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
    ],
    location: 'Temeke, Dar es Salaam',
    latitude: -6.8713,
    longitude: 39.2947,
    isAvailable: true,
    rating: 4.9,
    reviewCount: 31,
    createdAt: DateTime(2024, 2, 20),
  ),
  ListingModel(
    id: 'listing_004',
    ownerId: 'user_001',
    ownerName: 'Amina Salehe',
    title: 'Sound System ya Sherehe (5000W)',
    description:
        'Sound system yenye nguvu ya 5000W, inajumuisha speakers 4, subwoofer 2, mixer, na DJ equipment. Inafaa kwa sherehe kubwa za nje.',
    category: ListingCategory.sherehe,
    type: ListingType.kukodisha,
    pricePerDay: 450000,
    images: [
      'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800',
      'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800',
    ],
    location: 'Kinondoni, Dar es Salaam',
    latitude: -6.7730,
    longitude: 39.2369,
    isAvailable: false,
    rating: 4.7,
    reviewCount: 15,
    createdAt: DateTime(2024, 1, 25),
  ),

  // --- UJENZI ---
  ListingModel(
    id: 'listing_005',
    ownerId: 'user_001',
    ownerName: 'Amina Salehe',
    title: 'Scaffolding ya Ujenzi (Seti Kamili)',
    description:
        'Scaffolding ya chuma, inayoweza kufikia urefu wa mita 12. Inajumuisha vipande 50 vya msingi na bodi 20 za kupanda. Imethibitishwa kwa usalama.',
    category: ListingCategory.ujenzi,
    type: ListingType.kukodisha,
    pricePerDay: 120000,
    images: [
      'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800',
      'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=800',
    ],
    location: 'Arusha Mjini',
    latitude: -3.3869,
    longitude: 36.6830,
    isAvailable: true,
    rating: 4.6,
    reviewCount: 9,
    createdAt: DateTime(2024, 4, 1),
  ),
  ListingModel(
    id: 'listing_006',
    ownerId: 'user_001',
    ownerName: 'Amina Salehe',
    title: 'Mixer ya Simiti (350L)',
    description:
        'Mixer ya simiti ya lita 350, ya umeme, inafanya kazi vizuri na ni rahisi kutumia. Inafaa kwa ujenzi wa nyumba, barabara na mradi mkubwa wa simiti.',
    category: ListingCategory.ujenzi,
    type: ListingType.zote,
    pricePerDay: 85000,
    images: [
      'https://images.unsplash.com/photo-1565008447742-97f6f38c985c?w=800',
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
    ],
    location: 'Nyamagana, Mwanza',
    latitude: -2.5165,
    longitude: 32.9007,
    isAvailable: true,
    rating: 4.3,
    reviewCount: 7,
    createdAt: DateTime(2024, 4, 10),
  ),
  ListingModel(
    id: 'listing_007',
    ownerId: 'user_001',
    ownerName: 'Amina Salehe',
    title: 'Jenereta ya 20KVA (Silent)',
    description:
        'Jenereta ya diesel ya 20KVA, silent type, inafaa kwa matumizi ya ofisi, sherehe na ujenzi. Fuel consumption ndogo. Inajumuisha mafuta ya siku 1.',
    category: ListingCategory.ujenzi,
    type: ListingType.kukodisha,
    pricePerDay: 200000,
    images: [
      'https://images.unsplash.com/photo-1558618047-f4e70e5b48de?w=800',
      'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?w=800',
    ],
    location: 'Ilemela, Mwanza',
    latitude: -2.4931,
    longitude: 32.8740,
    isAvailable: true,
    rating: 4.4,
    reviewCount: 12,
    createdAt: DateTime(2024, 2, 14),
  ),

  // --- UKUMBI ---
  ListingModel(
    id: 'listing_008',
    ownerId: 'user_001',
    ownerName: 'Amina Salehe',
    title: 'Ukumbi wa Kariakoo (Watu 300)',
    description:
        'Ukumbi mkubwa uliopo katikati ya Kariakoo, Dar es Salaam. Una uwezo wa kuchukua watu 300. Unajumuisha jukwaa, mfumo wa sauti, hewa ya kiyoyozi na parking. Unafaa kwa harusi, biashara na mikutano.',
    category: ListingCategory.ukumbi,
    type: ListingType.kukodisha,
    pricePerDay: 800000,
    images: [
      'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
    ],
    location: 'Kariakoo, Dar es Salaam',
    latitude: -6.8235,
    longitude: 39.2816,
    isAvailable: true,
    rating: 4.9,
    reviewCount: 42,
    createdAt: DateTime(2023, 11, 5),
  ),
  ListingModel(
    id: 'listing_009',
    ownerId: 'user_001',
    ownerName: 'Amina Salehe',
    title: 'Venue ya Oyster Bay (Luxury)',
    description:
        'Venue ya kifahari iko katika eneo la Oyster Bay, karibu na pwani. Ina uwezo wa watu 150, bustani nzuri ya nje, dining area ya ndani, chef wa kibinafsi na huduma kamili ya event management.',
    category: ListingCategory.ukumbi,
    type: ListingType.kukodisha,
    pricePerDay: 1500000,
    images: [
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
    ],
    location: 'Oyster Bay, Dar es Salaam',
    latitude: -6.7598,
    longitude: 39.2740,
    isAvailable: true,
    rating: 5.0,
    reviewCount: 28,
    createdAt: DateTime(2023, 10, 1),
  ),
];

// ---------------------------------------------------------------------------
// MOCK BOOKINGS
// ---------------------------------------------------------------------------

final List<BookingModel> mockBookings = [
  BookingModel(
    id: 'booking_001',
    listingId: 'listing_001',
    listingTitle: 'Meza za Sherehe (Set ya 10)',
    listingImage:
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
    renterId: 'user_002',
    renterName: 'John Mwangi',
    ownerId: 'user_001',
    startDate: DateTime(2024, 12, 20),
    endDate: DateTime(2024, 12, 23),
    totalPrice: 150000,
    status: BookingStatus.confirmed,
    createdAt: DateTime(2024, 11, 15),
  ),
  BookingModel(
    id: 'booking_002',
    listingId: 'listing_008',
    listingTitle: 'Ukumbi wa Kariakoo (Watu 300)',
    listingImage:
        'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
    renterId: 'user_003',
    renterName: 'Fatuma Nguvu',
    ownerId: 'user_001',
    startDate: DateTime(2024, 11, 30),
    endDate: DateTime(2024, 12, 1),
    totalPrice: 800000,
    status: BookingStatus.pending,
    createdAt: DateTime(2024, 11, 10),
  ),
  BookingModel(
    id: 'booking_003',
    listingId: 'listing_007',
    listingTitle: 'Jenereta ya 20KVA (Silent)',
    listingImage:
        'https://images.unsplash.com/photo-1558618047-f4e70e5b48de?w=800',
    renterId: 'user_002',
    renterName: 'John Mwangi',
    ownerId: 'user_001',
    startDate: DateTime(2024, 10, 1),
    endDate: DateTime(2024, 10, 5),
    totalPrice: 800000,
    status: BookingStatus.completed,
    createdAt: DateTime(2024, 9, 25),
  ),
  BookingModel(
    id: 'booking_004',
    listingId: 'listing_004',
    listingTitle: 'Sound System ya Sherehe (5000W)',
    listingImage:
        'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800',
    renterId: 'user_003',
    renterName: 'Fatuma Nguvu',
    ownerId: 'user_001',
    startDate: DateTime(2024, 11, 5),
    endDate: DateTime(2024, 11, 6),
    totalPrice: 450000,
    status: BookingStatus.cancelled,
    createdAt: DateTime(2024, 10, 28),
  ),
];

// ---------------------------------------------------------------------------
// MOCK PAYMENTS
// ---------------------------------------------------------------------------

final List<PaymentModel> mockPayments = [
  PaymentModel(
    id: 'pay_001',
    bookingId: 'booking_001',
    listingTitle: 'Meza za Sherehe (Set ya 10)',
    renterId: 'user_002',
    renterName: 'John Mwangi',
    ownerId: 'user_001',
    amount: 150000,
    method: PaymentMethod.mpesa,
    type: PaymentType.full,
    status: PaymentStatus.completed,
    transactionRef: 'QD829JK109',
    phoneNumber: '+255754321987',
    createdAt: DateTime(2024, 11, 2),
  ),
  PaymentModel(
    id: 'pay_002',
    bookingId: 'booking_003',
    listingTitle: 'Jenereta ya 20KVA (Silent)',
    renterId: 'user_002',
    renterName: 'John Mwangi',
    ownerId: 'user_001',
    amount: 400000,
    method: PaymentMethod.tigoPesa,
    type: PaymentType.deposit,
    status: PaymentStatus.completed,
    transactionRef: 'TG991823AA',
    phoneNumber: '+255714321987',
    createdAt: DateTime(2024, 9, 26),
  ),
];

// ---------------------------------------------------------------------------
// MOCK REVIEWS
// ---------------------------------------------------------------------------

final List<ReviewModel> mockReviews = [
  ReviewModel(
    id: 'rev_001',
    bookingId: 'booking_003',
    listingId: 'listing_007',
    renterId: 'user_002',
    renterName: 'John Mwangi',
    ownerId: 'user_001',
    rating: 5.0,
    comment: 'Jenereta ilikuwa nzuri sana na ilifanya kazi masaa yote bila shida yoyote. Huduma nzuri!',
    createdAt: DateTime(2024, 10, 6),
  ),
  ReviewModel(
    id: 'rev_002',
    bookingId: 'booking_001',
    listingId: 'listing_001',
    renterId: 'user_002',
    renterName: 'John Mwangi',
    ownerId: 'user_001',
    rating: 4.8,
    comment: 'Meza zilikuwa safi na ziliwasilishwa kwa wakati sahihi wa sherehe.',
    createdAt: DateTime(2024, 11, 16),
  ),
];

// ---------------------------------------------------------------------------
// MOCK NOTIFICATIONS
// ---------------------------------------------------------------------------

final List<AppNotificationModel> mockNotifications = [
  AppNotificationModel(
    id: 'notif_001',
    userId: 'user_001',
    title: 'Booking Mpya Imepokelewa!',
    body: 'John Mwangi ameomba kukodisha "Meza za Sherehe (Set ya 10)" kwa siku 3.',
    type: NotificationType.newBooking,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    isRead: false,
    relatedId: 'booking_001',
  ),
  AppNotificationModel(
    id: 'notif_002',
    userId: 'user_002',
    title: 'Booking Imethibitishwa 🎉',
    body: 'Amina Salehe amethibitisha booking yako ya "Meza za Sherehe". Unaweza kufanya malipo sasa.',
    type: NotificationType.bookingConfirmed,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: false,
    relatedId: 'booking_001',
  ),
  AppNotificationModel(
    id: 'notif_003',
    userId: 'user_001',
    title: 'Malipo Yamepokelewa! 💰',
    body: 'Malipo ya TZS 150,000 kupitia M-Pesa (Ref: QD829JK109) yamekamilika.',
    type: NotificationType.paymentReceived,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
    relatedId: 'pay_001',
  ),
  AppNotificationModel(
    id: 'notif_004',
    userId: 'user_002',
    title: 'Ukumbusho wa Booking ⏰',
    body: 'Kesho ni siku ya kuanza kutumia "Meza za Sherehe". Wasiliana na mwenye kifaa kwa makabidhiano.',
    type: NotificationType.bookingReminder,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
    relatedId: 'booking_001',
  ),
];

