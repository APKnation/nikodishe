# Kodisha Backend (Django + GraphQL API)

Backend rasmi ya mfumo wa **Kodisha** (Tanzania Rental & Sales Marketplace) iliyojengwa kwa kutumia **Python 3.10+**, **Django 4.2+**, na **Graphene-Django (GraphQL)**.

---

## 🚀 Muundo wa Mfumo (Architecture)

Mfumo umeundwa kimfumo wa kisasa wa moduli (Modular Apps):

| Moduli | Jukumu |
| :--- | :--- |
| `apps.accounts` | Usajili wa Watumiaji (Customer & Owner), Uthibitishaji wa OTP (FR1-FR5), Wasifu, Mitandao ya Kijamii (WhatsApp, IG, FB, TikTok) na NIDA |
| `apps.listings` | Usimamizi wa Vifaa vya Ujenzi, Sherehe, na Kumbi (FR6-FR12), Utafutaji na Vichujio |
| `apps.bookings` | Usimamizi wa Maombi ya Ukodishaji, Tarehe, Hesabu ya Gharama (FR13-FR17) |
| `apps.payments` | Muamala wa Malipo ya Simu (M-Pesa, Airtel Money, Tigo Pesa, HaloPesa) & Amana ya 40% (FR18-FR20) |
| `apps.reviews` | Mfumo wa Tathmini ya Nyota (1-5★) na Maoni kwa Vifaa na Wamiliki (FR21-FR22) |
| `apps.notifications` | Arifa za Mfumo, Maombi Mapya ya Booking, na Malipo (FR23) |

---

## 🛠️ Jinsi ya Kuanza (Setup Instructions)

### 1. Ingia kwenye folda ya backend na uwashe Virtual Environment:
```bash
cd /home/apknation/AndroidStudioProjects/kodisha/backend
source venv/bin/activate
```

### 2. Sakinisha vifurushi vinavyohitajika (Run with Internet Access):
```bash
pip install -r requirements.txt
```

### 3. Fanya Migrations za Database:
```bash
python manage.py makemigrations accounts listings bookings payments reviews notifications
python manage.py migrate
```

### 4. Pakia Data za Majaribio (Seed Sample Data):
```bash
python manage.py seed_data
```
*(Hii itaweka mara moja listings za Sherehe, Ujenzi, na Kumbi zenye picha za ubora wa juu na watumiaji wa majaribio)*

### 5. Tengeneza Akaunti ya Admin (Superuser):
```bash
python manage.py createsuperuser
```
*(Weka namba ya simu mfano `0712345678`, jina, na nenosiri)*

### 6. Washa Server ya Maendeleo:
```bash
python manage.py runserver 0.0.0.0:8000
```

- **GraphiQL Interactive Explorer**: [http://127.0.0.1:8000/graphql/](http://127.0.0.1:8000/graphql/)
- **Django Admin Dashboard**: [http://127.0.0.1:8000/admin/](http://127.0.0.1:8000/admin/)

---

## 📡 Mifano ya GraphQL Queries & Mutations

### 1. Tuma OTP (Send OTP)
```graphql
mutation {
  sendOtp(phone: "0712345678") {
    success
    message
    phone
  }
}
```

### 2. Thibitisha OTP (Verify OTP)
*(Msimbo wa majaribio ni `123456`)*
```graphql
mutation {
  verifyOtp(phone: "0712345678", otpCode: "123456") {
    token
    userExists
    message
    user {
      id
      name
      role
      phone
    }
  }
}
```

### 3. Jisajili kama Mmiliki au Mteja (Register User)
```graphql
mutation {
  registerUser(
    phone: "0712345678"
    name: "Juma Said"
    role: "OWNER" # au "RENTER"
    location: "Kariakoo, Dar es Salaam"
    whatsappNumber: "0712345678"
    instagramHandle: "@jumarentals"
  ) {
    token
    user {
      id
      name
      role
      location
    }
    message
  }
}
```

### 4. Pata Orodha ya Vifaa na Kumbi (Listings Query)
```graphql
query {
  listings(category: "SHEREHE", search: "Tenti") {
    id
    title
    category
    listingType
    pricePerDay
    location
    rating
    reviewCount
    owner {
      name
      phone
      whatsappNumber
    }
  }
}
```

### 5. Omba Kukodi Kifaa (Create Booking)
*(Header: `Authorization: Bearer <JWT_TOKEN>`)*
```graphql
mutation {
  createBooking(
    listingId: "1"
    startDate: "2025-06-01"
    endDate: "2025-06-03"
    deliveryAddress: "Mikocheni B, Dar es Salaam"
    notes: "Tafadhali fika mapema saa 2 asubuhi"
  ) {
    success
    message
    booking {
      id
      totalPrice
      depositAmount
      status
    }
  }
}
```

### 6. Fanya Malipo ya Simu (Process Mobile Payment)
*(Header: `Authorization: Bearer <JWT_TOKEN>`)*
```graphql
mutation {
  processPayment(
    bookingId: "1"
    amount: 120000.0
    paymentMethod: "MPESA" # MPESA, AIRTEL_MONEY, TIGO_PESA, HALOPESA
    paymentType: "DEPOSIT" # DEPOSIT, FULL, REMAINDER
    phoneNumber: "0754123456"
  ) {
    success
    message
    payment {
      referenceCode
      status
      amount
      paymentMethod
    }
  }
}
```

---

## 🔒 Usalama na Uzingatiaji wa NFRs
- **JWT Authentication**: Token ya usalama inatolewa wakati wa kuingia au kujisajili.
- **Data Protection**: Wateja wanaona data na bookings zinazowahusu pekee.
- **CORS Configured**: Imetayarishwa kuwasiliana bila vizuizi na Flutter Android/iOS App.
- **Media Uploads**: Picha za vifaa na wasifu zimepangwa vizuri kwenye folda ya `media/`.

