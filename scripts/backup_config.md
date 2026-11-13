# Mkakati wa Backup ya Data (NFR15: Regular Data Backup Strategy)

Ili kuhakikisha data zote za wateja, listings, bookings, na miamala ya malipo hazipotei kamwe:

---

## 1. Cloud Firestore Automated Daily Backups
Kwenye Google Cloud Platform (GCP) / Firebase:
Tunatumia **Cloud Scheduler** pamoja na **Cloud Function** au **Cloud Firestore Export API** kufanya backup moja kwa moja kila usiku saa 08:00 Usiku (EAT).

### Amri ya Kuwasha Point-in-Time Recovery (PITR):
Hii inaruhusu kurudisha data ya dakika yoyote ndani ya siku 7 zilizopita endapo itatokea hitilafu ya kibinadamu:
```bash
gcloud firestore databases update \
    --project=kodisha-app \
    --database='(default)' \
    --enable-pitr
```

### Amri ya Backup ya Kila Siku (Daily Export to Cloud Storage):
```bash
gcloud firestore export gs://kodisha-backups-bucket/$(date +%Y-%m-%d) \
    --project=kodisha-app \
    --collection-ids='users','listings','bookings','payments','reviews','notifications'
```

---

## 2. Cloud Scheduler Cron Job (Otomatiki)
- **Schedule**: `0 2 * * *` (Kila siku saa nane usiku)
- **Target**: HTTP Cloud Function inayoita `firestore.databases.exportDocuments`
- **Destination**: `gs://kodisha-daily-backups/`
- **Retention Policy**: Backups huhifadhiwa kwa siku 30 (Lifecycle rule).

---

## 3. Local Offline Caching & Fallback kwenye App (NFR13 & NFR14)
- **Faili**: `lib/core/services/offline_storage_service.dart`
- Kila booking mpya inapoundwa au kubadilishwa hali yake, nakala inahifadhiwa kwenye kumbukumbu ya simu papo hapo.
- Mtumiaji akifunga app ghafla au mtandao ukikatika, data haipotei na inarudishwa pindi app inapofunguliwa tena.

