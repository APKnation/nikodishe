import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/network/api_config.dart';
import '../models/user_model.dart';
import '../models/listing_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';
import '../models/notification_model.dart';
import '../models/review_model.dart';
import 'graphql_client.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final GraphQLClient _client = GraphQLClient();

  void setAuthToken(String? token) => _client.setAuthToken(token);
  String? get authToken => _client.authToken;

  // ===========================================================================
  // AUTHENTICATION & USERS (FR1 - FR5)
  // ===========================================================================

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

  Future<UserModel> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    const mutation = r'''
      mutation LoginUser($phone: String!, $password: String!) {
        loginUser(phone: $phone, password: $password) {
          token
          message
          user {
            id
            name
            phone
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
      variables: {'phone': phone, 'password': password},
    );

    final res = data['loginUser'] as Map<String, dynamic>;
    final token = res['token'] as String?;
    if (token != null) {
      _client.setAuthToken(token);
    }
    return _mapUser(res['user'] as Map<String, dynamic>);
  }

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
    if (token != null && token.isNotEmpty) {
      _client.setAuthToken(token);
    }
    return _mapUser(res['user'] as Map<String, dynamic>);
  }

  Future<UserModel?> fetchMe() async {
    const query = r'''
      query Me {
        me {
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
    ''';
    final data = await _client.execute(query: query);
    final me = data['me'] as Map<String, dynamic>?;
    if (me == null) return null;
    return _mapUser(me);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? location,
    String? whatsappNumber,
    String? instagramHandle,
    String? facebookUrl,
    String? tiktokHandle,
    String? nidaNumber,
  }) async {
    const mutation = r'''
      mutation UpdateProfile(
        $name: String
        $location: String
        $whatsappNumber: String
        $instagramHandle: String
        $facebookUrl: String
        $tiktokHandle: String
        $nidaNumber: String
      ) {
        updateProfile(
          name: $name
          location: $location
          whatsappNumber: $whatsappNumber
          instagramHandle: $instagramHandle
          facebookUrl: $facebookUrl
          tiktokHandle: $tiktokHandle
          nidaNumber: $nidaNumber
        ) {
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
        'name': name,
        'location': location,
        'whatsappNumber': whatsappNumber,
        'instagramHandle': instagramHandle,
        'facebookUrl': facebookUrl,
        'tiktokHandle': tiktokHandle,
        'nidaNumber': nidaNumber,
      },
    );
    final res = data['updateProfile'] as Map<String, dynamic>;
    return _mapUser(res['user'] as Map<String, dynamic>);
  }

  // ===========================================================================
  // LISTINGS (FR6 - FR12)
  // ===========================================================================

  Future<List<ListingModel>> fetchListings({
    ListingCategory? category,
    String? search,
    ListingType? listingType,
    double? minPrice,
    double? maxPrice,
    String? ownerId,
  }) async {
    const query = r'''
      query GetListings(
        $category: String
        $search: String
        $listingType: String
        $minPrice: Float
        $maxPrice: Float
        $ownerId: ID
      ) {
        listings(
          category: $category
          search: $search
          listingType: $listingType
          minPrice: $minPrice
          maxPrice: $maxPrice
          ownerId: $ownerId
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

    final data = await _client.execute(
      query: query,
      variables: {
        'category': category != null ? _categoryToApi(category) : null,
        'search': search?.isNotEmpty == true ? search : null,
        'listingType': listingType != null
            ? _listingTypeToApi(listingType)
            : null,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'ownerId': ownerId,
      },
    );

    final rawList = data['listings'] as List? ?? [];
    return rawList
        .map((item) => _mapListing(item as Map<String, dynamic>))
        .toList();
  }

  Future<ListingModel?> fetchListingById(String id) async {
    const query = r'''
      query GetListing($id: ID!) {
        listingById(id: $id) {
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
    final data = await _client.execute(query: query, variables: {'id': id});
    final item = data['listingById'] as Map<String, dynamic>?;
    if (item == null) return null;
    return _mapListing(item);
  }

  Future<List<ListingModel>> fetchMyListings() async {
    const query = r'''
      query MyListings {
        myListings {
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
    final data = await _client.execute(query: query);
    final rawList = data['myListings'] as List? ?? [];
    return rawList
        .map((item) => _mapListing(item as Map<String, dynamic>))
        .toList();
  }

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
        $ownerId: ID
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
          ownerId: $ownerId
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

    final data = await _client.execute(
      query: mutation,
      variables: {
        'title': listing.title,
        'description': listing.description,
        'category': _categoryToApi(listing.category),
        'listingType': _listingTypeToApi(listing.type),
        'pricePerDay': listing.pricePerDay,
        'location': listing.location,
        'latitude': listing.latitude,
        'longitude': listing.longitude,
        'images': listing.images,
        'ownerId':
            (listing.ownerId.isNotEmpty && !listing.ownerId.startsWith('user_'))
            ? listing.ownerId
            : null,
      },
    );

    final res = data['createListing'] as Map<String, dynamic>;
    return _mapListing(res['listing'] as Map<String, dynamic>);
  }

  Future<ListingModel> updateListing({
    required String id,
    String? title,
    String? description,
    ListingCategory? category,
    ListingType? listingType,
    double? pricePerDay,
    String? location,
    bool? isAvailable,
  }) async {
    const mutation = r'''
      mutation UpdateListing(
        $id: ID!
        $title: String
        $description: String
        $category: String
        $listingType: String
        $pricePerDay: Float
        $location: String
        $isAvailable: Boolean
      ) {
        updateListing(
          id: $id
          title: $title
          description: $description
          category: $category
          listingType: $listingType
          pricePerDay: $pricePerDay
          location: $location
          isAvailable: $isAvailable
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
    final data = await _client.execute(
      query: mutation,
      variables: {
        'id': id,
        'title': title,
        'description': description,
        'category': category != null ? _categoryToApi(category) : null,
        'listingType': listingType != null
            ? _listingTypeToApi(listingType)
            : null,
        'pricePerDay': pricePerDay,
        'location': location,
        'isAvailable': isAvailable,
      },
    );
    final res = data['updateListing'] as Map<String, dynamic>;
    return _mapListing(res['listing'] as Map<String, dynamic>);
  }

  Future<bool> deleteListing(String id) async {
    const mutation = r'''
      mutation DeleteListing($id: ID!) {
        deleteListing(id: $id) {
          success
          message
        }
      }
    ''';
    final data = await _client.execute(query: mutation, variables: {'id': id});
    final res = data['deleteListing'] as Map<String, dynamic>?;
    return res?['success'] == true;
  }

  // ===========================================================================
  // BOOKINGS (FR13 - FR17)
  // ===========================================================================

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
          renter {
            id
            name
            phone
          }
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
    return rawList
        .map((item) => _mapBooking(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookingModel>> fetchOwnerBookings() async {
    const query = r'''
      query GetOwnerBookings {
        ownerBookings {
          id
          startDate
          endDate
          totalPrice
          depositAmount
          status
          deliveryAddress
          notes
          createdAt
          renter {
            id
            name
            phone
          }
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
    final rawList = data['ownerBookings'] as List? ?? [];
    return rawList
        .map((item) => _mapBooking(item as Map<String, dynamic>))
        .toList();
  }

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
            renter {
              id
              name
              phone
            }
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

    final data = await _client.execute(
      query: mutation,
      variables: {
        'listingId': listingId,
        'startDate': _formatDate(startDate),
        'endDate': _formatDate(endDate),
        'deliveryAddress': deliveryAddress,
        'notes': notes,
      },
    );

    final res = data['createBooking'] as Map<String, dynamic>;
    return _mapBooking(res['booking'] as Map<String, dynamic>);
  }

  Future<BookingModel> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    const mutation = r'''
      mutation UpdateBookingStatus($bookingId: ID!, $status: String!) {
        updateBookingStatus(bookingId: $bookingId, status: $status) {
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
            renter {
              id
              name
              phone
            }
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
    final data = await _client.execute(
      query: mutation,
      variables: {
        'bookingId': bookingId,
        'status': _bookingStatusToApi(status),
      },
    );
    final res = data['updateBookingStatus'] as Map<String, dynamic>;
    return _mapBooking(res['booking'] as Map<String, dynamic>);
  }

  // ===========================================================================
  // PAYMENTS (FR18 - FR20)
  // ===========================================================================

  Future<List<PaymentModel>> fetchMyPayments() async {
    const query = r'''
      query MyPayments {
        myPayments {
          id
          referenceCode
          amount
          paymentMethod
          paymentType
          status
          phoneNumber
          createdAt
          booking {
            id
            listing {
              id
              title
            }
          }
          renter {
            id
            name
          }
          owner {
            id
            name
          }
        }
      }
    ''';
    final data = await _client.execute(query: query);
    final rawList = data['myPayments'] as List? ?? [];
    return rawList.map((p) => _mapPayment(p as Map<String, dynamic>)).toList();
  }

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
            booking {
              id
              listing {
                id
                title
              }
            }
            renter {
              id
              name
            }
            owner {
              id
              name
            }
          }
        }
      }
    ''';

    final data = await _client.execute(
      query: mutation,
      variables: {
        'bookingId': bookingId,
        'amount': amount,
        'paymentMethod': _paymentMethodToApi(method),
        'paymentType': _paymentTypeToApi(type),
        'phoneNumber': phoneNumber,
      },
    );

    final res = data['processPayment'] as Map<String, dynamic>;
    return _mapPayment(
      res['payment'] as Map<String, dynamic>,
      fallbackBookingId: bookingId,
      fallbackPhone: phoneNumber,
    );
  }

  // ===========================================================================
  // NOTIFICATIONS (FR23)
  // ===========================================================================

  Future<List<AppNotificationModel>> fetchNotifications({
    bool unreadOnly = false,
  }) async {
    const query = r'''
      query GetMyNotifications($unreadOnly: Boolean) {
        myNotifications(unreadOnly: $unreadOnly) {
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
    final data = await _client.execute(
      query: query,
      variables: {'unreadOnly': unreadOnly},
    );
    final rawList = data['myNotifications'] as List? ?? [];

    return rawList.map((n) {
      final m = n as Map<String, dynamic>;
      final type = NotificationTypeExt.fromApiString(
        m['notificationType'] as String? ?? '',
      );
      return AppNotificationModel(
        id: m['id'].toString(),
        userId: '',
        title: m['title'] ?? '',
        body: m['body'] ?? '',
        type: type,
        isRead: m['isRead'] == true,
        relatedId: m['relatedId']?.toString(),
        createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  Future<bool> markNotificationAsRead(String id) async {
    const mutation = r'''
      mutation MarkRead($id: ID!) {
        markNotificationAsRead(id: $id) {
          success
          message
        }
      }
    ''';
    final data = await _client.execute(query: mutation, variables: {'id': id});
    return (data['markNotificationAsRead']
            as Map<String, dynamic>?)?['success'] ==
        true;
  }

  Future<bool> markAllNotificationsAsRead() async {
    const mutation = r'''
      mutation MarkAllRead {
        markAllNotificationsAsRead {
          success
          message
        }
      }
    ''';
    final data = await _client.execute(query: mutation);
    return (data['markAllNotificationsAsRead']
            as Map<String, dynamic>?)?['success'] ==
        true;
  }

  // ===========================================================================
  // REVIEWS (FR21 - FR22)
  // ===========================================================================

  Future<List<ReviewModel>> fetchReviewsByListing(String listingId) async {
    const query = r'''
      query ReviewsByListing($listingId: ID!) {
        reviewsByListing(listingId: $listingId) {
          id
          rating
          comment
          createdAt
          booking { id }
          listing { id }
          renter { id name }
          owner { id name }
        }
      }
    ''';
    final data = await _client.execute(
      query: query,
      variables: {'listingId': listingId},
    );
    final raw = data['reviewsByListing'] as List? ?? [];
    return raw.map((r) => _mapReview(r as Map<String, dynamic>)).toList();
  }

  Future<bool> createReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    const mutation = r'''
      mutation CreateReview($bookingId: ID!, $rating: Int!, $comment: String!) {
        createReview(bookingId: $bookingId, rating: $rating, comment: $comment) {
          success
          message
        }
      }
    ''';
    final data = await _client.execute(
      query: mutation,
      variables: {'bookingId': bookingId, 'rating': rating, 'comment': comment},
    );
    return (data['createReview'] as Map<String, dynamic>?)?['success'] == true;
  }

  // ===========================================================================
  // FILE UPLOAD (REST Multipart API)
  // ===========================================================================

  Future<String> uploadImageFile(File file) async {
    final uri = Uri.parse(ApiConfig.imageUploadUrl);
    final request = http.MultipartRequest('POST', uri);

    if (_client.authToken != null) {
      request.headers['Authorization'] = 'Bearer ${_client.authToken}';
    }

    final multipartFile = await http.MultipartFile.fromPath('image', file.path);
    request.files.add(multipartFile);

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return json['image_url'] as String? ?? '';
    } else {
      throw ApiException('Imeshindwa kupakia picha (${response.statusCode})');
    }
  }

  // ===========================================================================
  // MAPPERS & HELPERS
  // ===========================================================================

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _categoryToApi(ListingCategory c) {
    switch (c) {
      case ListingCategory.sherehe:
        return 'SHEREHE';
      case ListingCategory.ujenzi:
        return 'UJENZI';
      case ListingCategory.ukumbi:
        return 'UKUMBI';
    }
  }

  String _listingTypeToApi(ListingType t) {
    switch (t) {
      case ListingType.kukodisha:
        return 'RENT';
      case ListingType.kuuza:
        return 'SELL';
      case ListingType.zote:
        return 'BOTH';
    }
  }

  String _bookingStatusToApi(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return 'PENDING';
      case BookingStatus.confirmed:
        return 'CONFIRMED';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String _paymentMethodToApi(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.mpesa:
        return 'MPESA';
      case PaymentMethod.airtelMoney:
        return 'AIRTEL_MONEY';
      case PaymentMethod.tigoPesa:
        return 'TIGO_PESA';
      case PaymentMethod.haloPesa:
        return 'HALOPESA';
    }
  }

  String _paymentTypeToApi(PaymentType t) {
    switch (t) {
      case PaymentType.deposit:
        return 'DEPOSIT';
      case PaymentType.full:
        return 'FULL';
      case PaymentType.remainder:
        return 'REMAINDER';
    }
  }

  UserModel _mapUser(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] == 'OWNER' ? UserRole.owner : UserRole.renter,
      location: json['location'],
      photoUrl: json['profilePhoto'] != null
          ? ApiConfig.resolveMediaUrl(json['profilePhoto'].toString())
          : null,
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
          final u = img['url'].toString();
          if (u.isNotEmpty) imagesList.add(ApiConfig.resolveMediaUrl(u));
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
      images: imagesList.isNotEmpty
          ? imagesList
          : [
              'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
            ],
      location: json['location'] ?? 'Dar es Salaam, Tanzania',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
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
    final renter = json['renter'] as Map<String, dynamic>?;

    String coverImg =
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800';
    if (listing?['images'] is List && (listing!['images'] as List).isNotEmpty) {
      final first = listing['images'][0] as Map;
      coverImg = ApiConfig.resolveMediaUrl(
        (first['url'] ?? coverImg).toString(),
      );
    }

    return BookingModel(
      id: json['id'].toString(),
      listingId: listing?['id']?.toString() ?? '',
      listingTitle: listing?['title'] ?? 'Kifaa',
      listingImage: coverImg,
      renterId: renter?['id']?.toString() ?? '',
      renterName: renter?['name'] ?? '',
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

  PaymentModel _mapPayment(
    Map<String, dynamic> p, {
    String? fallbackBookingId,
    String? fallbackPhone,
  }) {
    PaymentMethod method = PaymentMethod.mpesa;
    final m = (p['paymentMethod'] as String? ?? '').toUpperCase();
    if (m.contains('AIRTEL')) {
      method = PaymentMethod.airtelMoney;
    } else if (m.contains('TIGO')) {
      method = PaymentMethod.tigoPesa;
    } else if (m.contains('HALO')) {
      method = PaymentMethod.haloPesa;
    }

    PaymentType type = PaymentType.full;
    final t = (p['paymentType'] as String? ?? '').toUpperCase();
    if (t.contains('DEPOSIT')) {
      type = PaymentType.deposit;
    } else if (t.contains('REMAINDER')) {
      type = PaymentType.remainder;
    }

    PaymentStatus status = PaymentStatus.pending;
    final s = (p['status'] as String? ?? '').toUpperCase();
    if (s.contains('COMPLETED')) {
      status = PaymentStatus.completed;
    } else if (s.contains('FAILED')) {
      status = PaymentStatus.failed;
    }

    final booking = p['booking'] as Map<String, dynamic>?;
    final listing = booking?['listing'] as Map<String, dynamic>?;
    final renter = p['renter'] as Map<String, dynamic>?;
    final owner = p['owner'] as Map<String, dynamic>?;

    return PaymentModel(
      id: p['id'].toString(),
      bookingId: booking?['id']?.toString() ?? fallbackBookingId ?? '',
      listingTitle: listing?['title'] ?? '',
      renterId: renter?['id']?.toString() ?? '',
      renterName: renter?['name'] ?? '',
      ownerId: owner?['id']?.toString() ?? '',
      amount: (p['amount'] as num?)?.toDouble() ?? 0.0,
      method: method,
      type: type,
      status: status,
      transactionRef: p['referenceCode'] ?? '',
      phoneNumber: p['phoneNumber'] ?? fallbackPhone ?? '',
      createdAt: DateTime.tryParse(p['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  ReviewModel _mapReview(Map<String, dynamic> r) {
    final renter = r['renter'] as Map<String, dynamic>?;
    final owner = r['owner'] as Map<String, dynamic>?;
    final listing = r['listing'] as Map<String, dynamic>?;
    final booking = r['booking'] as Map<String, dynamic>?;
    return ReviewModel(
      id: r['id'].toString(),
      bookingId: booking?['id']?.toString() ?? '',
      listingId: listing?['id']?.toString() ?? '',
      renterId: renter?['id']?.toString() ?? '',
      renterName: renter?['name'] ?? '',
      ownerId: owner?['id']?.toString() ?? '',
      rating: (r['rating'] as num?)?.toDouble() ?? 0.0,
      comment: r['comment'] ?? '',
      createdAt: DateTime.tryParse(r['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
