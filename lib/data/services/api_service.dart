import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/network/api_config.dart';
import '../models/user_model.dart';
import '../models/listing_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';
import '../models/notification_model.dart';
import 'graphql_client.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final GraphQLClient _client = GraphQLClient();

  // ===========================================================================
  // AUTHENTICATION & USERS (FR1 - FR5)
  // ===========================================================================

  /// Send OTP to user phone
  Future<bool> sendOtp(String phone) async {
    const mutation = r'''
      mutation SendOtp($phone: String!) {
        sendOtp(phone: $phone) {
          success
          message
          phone
        }
      }
    ''';
    final data = await _client.execute(
      query: mutation,
      variables: {'phone': phone},
    );
    final res = data['sendOtp'] as Map<String, dynamic>?;
    return res?['success'] == true;
  }

  /// Verify OTP and obtain JWT token & user if registered
  Future<Map<String, dynamic>> verifyOtp(String phone, String otpCode) async {
    const mutation = r'''
      mutation VerifyOtp($phone: String!, $otpCode: String!) {
        verifyOtp(phone: $phone, otpCode: $otpCode) {
          token
          userExists
          message
          user {
            id
            phone
            name
            role
            location
            profilePhoto
            whatsappNumber
            instagramHandle
            facebookUrl
            tiktokHandle
            createdAt
          }
        }
      }
    ''';
    final data = await _client.execute(
      query: mutation,
      variables: {'phone': phone, 'otpCode': otpCode},
    );

    final res = data['verifyOtp'] as Map<String, dynamic>? ?? {};
    final token = res['token'] as String?;
    if (token != null && token.isNotEmpty) {
      _client.setAuthToken(token);
    }

    UserModel? user;
    if (res['user'] != null) {
      user = _mapUser(res['user'] as Map<String, dynamic>);
    }

    return {
      'token': token,
      'userExists': res['userExists'] == true,
      'user': user,
      'message': res['message'],
    };
  }

  /// Register new user (Customer or Owner)
  Future<UserModel> registerUser({
    required String phone,
    required String name,
    required UserRole role,
    String? location,
    String? whatsapp,
    String? instagram,
    String? facebook,
    String? tiktok,
    String? nidaNumber,
  }) async {
    const mutation = r'''
      mutation RegisterUser(
        $phone: String!
        $name: String!
        $role: String!
        $location: String
        $whatsappNumber: String
        $instagramHandle: String
        $facebookUrl: String
        $tiktokHandle: String
        $nidaNumber: String
      ) {
        registerUser(
          phone: $phone
          name: $name
          role: $role
          location: $location
          whatsappNumber: $whatsappNumber
          instagramHandle: $instagramHandle
          facebookUrl: $facebookUrl
          tiktokHandle: $tiktokHandle
          nidaNumber: $nidaNumber
        ) {
          token
          message
          user {
            id
            phone
            name
            role
            location
            profilePhoto
            whatsappNumber
            instagramHandle
            facebookUrl
            tiktokHandle
            createdAt
          }
        }
      }
    ''';

    final data = await _client.execute(
      query: mutation,
      variables: {
        'phone': phone,
        'name': name,
        'role': role == UserRole.owner ? 'OWNER' : 'RENTER',
        'location': location,
        'whatsappNumber': whatsapp,
        'instagramHandle': instagram,
        'facebookUrl': facebook,
        'tiktokHandle': tiktok,
        'nidaNumber': nidaNumber,
      },
    );

    final res = data['registerUser'] as Map<String, dynamic>;
    final token = res['token'] as String?;
    if (token != null) {
      _client.setAuthToken(token);
    }
    return _mapUser(res['user'] as Map<String, dynamic>);
  }

  // ===========================================================================
  // LISTINGS (FR6 - FR12)
  // ===========================================================================

  /// Fetch listings from GraphQL API with filters
  Future<List<ListingModel>> fetchListings({
    ListingCategory? category,
    String? search,
    ListingType? listingType,
    double? minPrice,
    double? maxPrice,
  }) async {
    const query = r'''
      query GetListings(
        $category: String
        $search: String
        $listingType: String
        $minPrice: Float
        $maxPrice: Float
      ) {
        listings(
          category: $category
          search: $search
          listingType: $listingType
          minPrice: $minPrice
          maxPrice: $maxPrice
        ) {
          id
          title
          description
          category
          listingType
          pricePerDay
          salePrice
          currency
          location
          latitude
          longitude
          isAvailable
          rating
          reviewCount
          createdAt
          owner {
            id
            name
            phone
            whatsappNumber
            instagramHandle
          }
          images {
            id
            url
            isPrimary
          }
        }
      }
    ''';

    String? categoryStr;
    if (category != null) {
      switch (category) {
        case ListingCategory.sherehe:
          categoryStr = 'SHEREHE';
          break;
        case ListingCategory.ujenzi:
          categoryStr = 'UJENZI';
          break;
        case ListingCategory.ukumbi:
          categoryStr = 'UKUMBI';
          break;
      }
    }

    String? typeStr;
    if (listingType != null) {
      switch (listingType) {
        case ListingType.kukodisha:
          typeStr = 'RENT';
          break;
        case ListingType.kuuza:
          typeStr = 'SELL';
          break;
        case ListingType.zote:
          typeStr = 'BOTH';
          break;
      }
    }

    final data = await _client.execute(
      query: query,
      variables: {
        'category': categoryStr,
        'search': search?.isNotEmpty == true ? search : null,
        'listingType': typeStr,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
      },
    );

    final rawList = data['listings'] as List? ?? [];
    return rawList.map((item) => _mapListing(item as Map<String, dynamic>)).toList();
  }

  /// Create a new listing on the backend
  Future<ListingModel> createListing(ListingModel listing) async {
    const mutation = r'''
      mutation CreateListing(
        $title: String!
        $description: String!
        $category: String!
        $listingType: String
        $pricePerDay: Float!
        $location: String!
        $latitude: Float
        $longitude: Float
        $images: [String]
      ) {
        createListing(
          title: $title
          description: $description
          category: $category
          listingType: $listingType
          pricePerDay: $pricePerDay
          location: $location
          latitude: $latitude
          longitude: $longitude
          images: $images
        ) {
          success
          message
          listing {
            id
            title
            description
            category
            listingType
            pricePerDay
            salePrice
            currency
            location
            latitude
            longitude
            isAvailable
            rating
            reviewCount
            createdAt
            owner {
              id
              name
              phone
              whatsappNumber
              instagramHandle
            }
            images {
              id
              url
              isPrimary
            }
          }
        }
      }
    ''';

    String catStr = 'SHEREHE';
    switch (listing.category) {
      case ListingCategory.sherehe:
        catStr = 'SHEREHE';
        break;
      case ListingCategory.ujenzi:
        catStr = 'UJENZI';
        break;
      case ListingCategory.ukumbi:
        catStr = 'UKUMBI';
        break;
    }

    String typeStr = 'RENT';
    switch (listing.type) {
      case ListingType.kukodisha:
        typeStr = 'RENT';
        break;
      case ListingType.kuuza:
        typeStr = 'SELL';
        break;
      case ListingType.zote:
        typeStr = 'BOTH';
        break;
    }

    final data = await _client.execute(
      query: mutation,
      variables: {
        'title': listing.title,
        'description': listing.description,
        'category': catStr,
        'listingType': typeStr,
        'pricePerDay': listing.pricePerDay,
        'location': listing.location,
        'latitude': listing.latitude,
        'longitude': listing.longitude,
        'images': listing.images,
      },
    );

    final res = data['createListing'] as Map<String, dynamic>;
    return _mapListing(res['listing'] as Map<String, dynamic>);
  }

  // ===========================================================================
  // BOOKINGS (FR13 - FR17)
  // ===========================================================================

  /// Fetch user bookings from API
  Future<List<BookingModel>> fetchMyBookings() async {
    const query = r'''
      query GetMyBookings {
        myBookings {
          id
          startDate
          endDate
          totalPrice
          depositAmount
          status
          deliveryAddress
          notes
          createdAt
          listing {
            id
            title
            category
            pricePerDay
            location
            images {
              url
            }
          }
          owner {
            id
            name
            phone
          }
        }
      }
    ''';

    final data = await _client.execute(query: query);
    final rawList = data['myBookings'] as List? ?? [];
    return rawList.map((item) => _mapBooking(item as Map<String, dynamic>)).toList();
  }

  /// Create a new booking
  Future<BookingModel> createBooking({
    required String listingId,
    required DateTime startDate,
    required DateTime endDate,
    String? deliveryAddress,
    String? notes,
  }) async {
    const mutation = r'''
      mutation CreateBooking(
        $listingId: ID!
        $startDate: Date!
        $endDate: Date!
        $deliveryAddress: String
        $notes: String
      ) {
        createBooking(
          listingId: $listingId
          startDate: $startDate
          endDate: $endDate
          deliveryAddress: $deliveryAddress
          notes: $notes
        ) {
          success
          message
          booking {
            id
            startDate
            endDate
            totalPrice
            depositAmount
            status
            deliveryAddress
            notes
            createdAt
            listing {
              id
              title
              category
              pricePerDay
              location
              images {
                url
              }
            }
            owner {
              id
              name
              phone
            }
          }
        }
      }
    ''';

    final formattedStart = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    final formattedEnd = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    final data = await _client.execute(
      query: mutation,
      variables: {
        'listingId': listingId,
        'startDate': formattedStart,
        'endDate': formattedEnd,
        'deliveryAddress': deliveryAddress,
        'notes': notes,
      },
    );

    final res = data['createBooking'] as Map<String, dynamic>;
    return _mapBooking(res['booking'] as Map<String, dynamic>);
  }

  // ===========================================================================
  // PAYMENTS (FR18 - FR20)
  // ===========================================================================

  /// Process Mobile Money payment
  Future<PaymentModel> processPayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
    required PaymentType type,
    required String phoneNumber,
  }) async {
    const mutation = r'''
      mutation ProcessPayment(
        $bookingId: ID!
        $amount: Float!
        $paymentMethod: String!
        $paymentType: String!
        $phoneNumber: String!
      ) {
        processPayment(
          bookingId: $bookingId
          amount: $amount
          paymentMethod: $paymentMethod
          paymentType: $paymentType
          phoneNumber: $phoneNumber
        ) {
          success
          message
          payment {
            id
            referenceCode
            amount
            paymentMethod
            paymentType
            status
            phoneNumber
            createdAt
          }
        }
      }
    ''';

    String methodStr = 'MPESA';
    switch (method) {
      case PaymentMethod.mpesa:
        methodStr = 'MPESA';
        break;
      case PaymentMethod.airtelMoney:
        methodStr = 'AIRTEL_MONEY';
        break;
      case PaymentMethod.tigoPesa:
        methodStr = 'TIGO_PESA';
        break;
      case PaymentMethod.haloPesa:
        methodStr = 'HALOPESA';
        break;
    }

    String typeStr = 'FULL';
    switch (type) {
      case PaymentType.deposit:
        typeStr = 'DEPOSIT';
        break;
      case PaymentType.full:
        typeStr = 'FULL';
        break;
      case PaymentType.remainder:
        typeStr = 'REMAINDER';
        break;
    }

    final data = await _client.execute(
      query: mutation,
      variables: {
        'bookingId': bookingId,
        'amount': amount,
        'paymentMethod': methodStr,
        'paymentType': typeStr,
        'phoneNumber': phoneNumber,
      },
    );

    final res = data['processPayment'] as Map<String, dynamic>;
    final p = res['payment'] as Map<String, dynamic>;

    return PaymentModel(
      id: p['id'].toString(),
      bookingId: bookingId,
      payerId: '',
      recipientId: '',
      amount: (p['amount'] as num).toDouble(),
      method: method,
      type: type,
      status: PaymentStatus.completed,
      transactionRef: p['referenceCode'] ?? '',
      phoneNumber: p['phoneNumber'] ?? phoneNumber,
      createdAt: DateTime.tryParse(p['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // ===========================================================================
  // NOTIFICATIONS (FR23)
  // ===========================================================================

  Future<List<NotificationModel>> fetchNotifications() async {
    const query = r'''
      query GetMyNotifications {
        myNotifications {
          id
          title
          body
          notificationType
          isRead
          relatedId
          createdAt
        }
      }
    ''';
    final data = await _client.execute(query: query);
    final rawList = data['myNotifications'] as List? ?? [];

    return rawList.map((n) {
      final type = NotificationTypeExt.fromApiString(n['notificationType'] as String? ?? '');

      return AppNotificationModel(
        id: n['id'].toString(),
        userId: '',
        title: n['title'] ?? '',
        body: n['body'] ?? '',
        type: type,
        isRead: n['isRead'] == true,
        relatedId: n['relatedId'],
        createdAt: DateTime.tryParse(n['createdAt'] ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  // ===========================================================================
  // FILE UPLOAD (REST Multipart API)
  // ===========================================================================

  /// Upload real local image file directly to Django backend
  Future<String> uploadImageFile(File file) async {
    final uri = Uri.parse(ApiConfig.imageUploadUrl);
    final request = http.MultipartRequest('POST', uri);

    if (_client.authToken != null) {
      request.headers['Authorization'] = 'Bearer ${_client.authToken}';
    }

    final multipartFile = await http.MultipartFile.fromPath('image', file.path);
    request.files.add(multipartFile);

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return json['image_url'] as String? ?? '';
    } else {
      throw ApiException('Imeshindwa kupakia picha (${response.statusCode})');
    }
  }

  // ===========================================================================
  // MAPPERS
  // ===========================================================================

  UserModel _mapUser(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] == 'OWNER' ? UserRole.owner : UserRole.renter,
      location: json['location'],
      photoUrl: json['profilePhoto'] != null ? ApiConfig.resolveMediaUrl(json['profilePhoto']) : null,
      whatsapp: json['whatsappNumber'],
      instagram: json['instagramHandle'],
      facebook: json['facebookUrl'],
      tiktok: json['tiktokHandle'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  ListingModel _mapListing(Map<String, dynamic> json) {
    ListingCategory category = ListingCategory.sherehe;
    final cat = (json['category'] as String? ?? '').toUpperCase();
    if (cat.contains('UJENZI')) {
      category = ListingCategory.ujenzi;
    } else if (cat.contains('UKUMBI')) {
      category = ListingCategory.ukumbi;
    }

    ListingType type = ListingType.kukodisha;
    final t = (json['listingType'] as String? ?? '').toUpperCase();
    if (t.contains('SELL')) {
      type = ListingType.kuuza;
    } else if (t.contains('BOTH')) {
      type = ListingType.zote;
    }

    final imagesList = <String>[];
    if (json['images'] is List) {
      for (final img in json['images']) {
        if (img is Map && img['url'] != null) {
          imagesList.add(ApiConfig.resolveMediaUrl(img['url'].toString()));
        }
      }
    }

    final owner = json['owner'] as Map<String, dynamic>?;

    return ListingModel(
      id: json['id'].toString(),
      ownerId: owner?['id']?.toString() ?? 'owner_1',
      ownerName: owner?['name'] ?? 'Mmiliki wa Kifaa',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: category,
      type: type,
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      images: imagesList.isNotEmpty ? imagesList : ['https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800'],
      location: json['location'] ?? 'Dar es Salaam, Tanzania',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: json['reviewCount'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  BookingModel _mapBooking(Map<String, dynamic> json) {
    BookingStatus status = BookingStatus.pending;
    final st = (json['status'] as String? ?? '').toUpperCase();
    if (st.contains('CONFIRMED')) {
      status = BookingStatus.confirmed;
    } else if (st.contains('COMPLETED')) {
      status = BookingStatus.completed;
    } else if (st.contains('CANCELLED')) {
      status = BookingStatus.cancelled;
    }

    final listing = json['listing'] as Map<String, dynamic>?;
    final owner = json['owner'] as Map<String, dynamic>?;

    String coverImg = 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800';
    if (listing?['images'] is List && (listing!['images'] as List).isNotEmpty) {
      coverImg = ApiConfig.resolveMediaUrl((listing['images'][0] as Map)['url'] ?? coverImg);
    }

    return BookingModel(
      id: json['id'].toString(),
      listingId: listing?['id']?.toString() ?? '',
      listingTitle: listing?['title'] ?? 'Kifaa',
      listingImage: coverImg,
      renterId: '',
      renterName: '',
      ownerId: owner?['id']?.toString() ?? '',
      ownerName: owner?['name'] ?? 'Mmiliki',
      ownerPhone: owner?['phone'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: status,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

