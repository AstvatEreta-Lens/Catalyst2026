# Settlement System Implementation

## Overview
Sistem settlement yang telah diimplementasikan menghitung secara akurat siapa yang berhutang kepada siapa berdasarkan:
- Expense yang telah dibuat dalam grup
- Siapa yang membayar expense tersebut
- Bagaimana expense dibagi (equally, unequally, atau itemized)
- Kontribusi masing-masing member

## Komponen Utama

### 1. SettlementModels.swift
Model data untuk representasi settlement:
- **SettlementTransaction**: Transaksi settlement antara dua member
  - Informasi pembayar (from) dan penerima (to)
  - Jumlah yang harus dibayar
  - Status pembayaran (Paid/Unpaid)
  - Detail expense yang berkontribusi

- **ExpenseBreakdown**: Detail expense yang berkontribusi ke settlement
  - Nama expense dan item (jika itemized)
  - Jumlah
  - Siapa yang membayar
  - Tanggal expense

- **MemberSettlementSummary**: Ringkasan settlement untuk satu member
  - Daftar transaksi yang harus dibayar (needToPay)
  - Daftar transaksi yang menunggu pembayaran (waitingForPayment)
  - Total untuk masing-masing kategori

### 2. SettlementCalculator.swift
Service untuk menghitung settlement dengan logika:

#### Algoritma Perhitungan:
1. **Untuk setiap expense dalam grup:**
   - Hitung share (bagian) dari member yang dipilih
   - Hitung berapa banyak member tersebut membayar
   - Tentukan balance: `myPayment - myShare`

2. **Distribusi Balance:**
   - Jika balance negatif (member berhutang):
     * Distribusikan hutang secara proporsional ke semua payer
     * Catat detail expense yang menyebabkan hutang
   
   - Jika balance positif (member berpiutang):
     * Cari beneficiary lain yang berhutang
     * Hitung berapa banyak mereka berhutang kepada member ini
     * Catat detail expense yang menyebabkan piutang

3. **Konversi ke Transaksi:**
   - Gabungkan semua balance per member lain
   - Buat SettlementTransaction untuk setiap pasangan member
   - Urutkan berdasarkan jumlah (terbesar ke terkecil)

### 3. SettlementView.swift
View yang menampilkan settlement untuk satu member:

#### Fitur:
- **Segmented Control**: Active/Done untuk filter status pembayaran
- **Filter Menu**: All/Need To Pay/Will Receive
- **Dynamic Data**: Menghitung settlement saat view muncul
- **Empty State**: Menampilkan "All settled up!" jika tidak ada transaksi
- **Expandable Cards**: Menampilkan detail expense saat di-tap

#### Props:
```swift
init(
    member: FriendEntity?,        // Member yang dilihat settlementnya
    group: GroupEntity?,           // Grup terkait
    expenses: [ExpenseEntity],     // Semua expense dalam grup
    allMembers: [FriendEntity]     // Semua member dalam grup
)
```

### 4. SettlementRowView.swift
Komponen untuk menampilkan satu transaksi settlement:

#### Fitur:
- Menampilkan SettlementCard dengan informasi transaksi
- Expandable untuk menampilkan breakdown expense
- ExpenseBreakdownCard untuk setiap expense yang berkontribusi

### 5. MemberSummaryCardView.swift
Card di GroupPageView yang dapat diklik untuk melihat detail settlement:

#### Update:
- Menambahkan props: group, expenses, allMembers
- Mengirim data ke SettlementView saat diklik

## Contoh Perhitungan

### Scenario:
**Expense 1: Makan Siang (Rp 60.000)**
- Dibayar oleh: John (Rp 60.000)
- Split equally antara: John, Chikmah, Fida
- Share masing-masing: Rp 20.000

**Hasil untuk John:**
- John membayar: Rp 60.000
- John share: Rp 20.000
- Balance: +Rp 40.000 (John berpiutang)

**Hasil untuk Chikmah:**
- Chikmah membayar: Rp 0
- Chikmah share: Rp 20.000
- Balance: -Rp 20.000 (Chikmah berhutang ke John)

**Hasil untuk Fida:**
- Fida membayar: Rp 0
- Fida share: Rp 20.000
- Balance: -Rp 20.000 (Fida berhutang ke John)

### Settlement View untuk John:
**Waiting For Payment:**
1. From Chikmah: Rp 20.000
   - Makan Siang: Rp 20.000 (Paid by John)
2. From Fida: Rp 20.000
   - Makan Siang: Rp 20.000 (Paid by John)

**Total Waiting: Rp 40.000**

### Settlement View untuk Chikmah:
**Need to Pay:**
1. To John: Rp 20.000
   - Makan Siang: Rp 20.000 (Paid by John)

**Total Need to Pay: Rp 20.000**

## Integrasi dengan Existing Code

### GroupPageViewModel
Sudah memiliki method `memberSummary(for:)` yang menghitung total:
- `youNeedToPay`: Total hutang member
- `waitingForPayment`: Total piutang member

Method ini digunakan untuk menampilkan summary di MemberSummaryCardView.

### Navigation Flow
1. User membuka GroupPageView
2. User melihat Summary tab dengan MemberSummaryCardView untuk setiap member
3. User tap pada MemberSummaryCardView
4. Navigasi ke SettlementView dengan data member, group, expenses, dan allMembers
5. SettlementView menghitung settlement menggunakan SettlementCalculator
6. Menampilkan daftar transaksi yang harus dibayar/diterima
7. User dapat expand untuk melihat detail expense

## Testing Checklist

- [ ] Settlement calculation untuk equally split
- [ ] Settlement calculation untuk unequally split
- [ ] Settlement calculation untuk itemized split
- [ ] Multiple expenses dengan multiple payers
- [ ] Filter: All/Need To Pay/Will Receive
- [ ] Segmented control: Active/Done
- [ ] Expand/collapse expense breakdowns
- [ ] Empty state ketika semua settled
- [ ] Navigation dari MemberSummaryCard ke SettlementView
- [ ] Accuracy of amounts displayed

## Future Enhancements

1. **Mark as Paid**: Kemampuan untuk menandai transaksi sebagai sudah dibayar
2. **Payment History**: Riwayat pembayaran settlement
3. **Notifications**: Notifikasi saat ada settlement baru atau pembayaran diterima
4. **Simplify Debts**: Algoritma untuk menyederhanakan hutang (A owes B, B owes C → A owes C)
5. **Export**: Export settlement summary ke PDF atau image
6. **Reminders**: Pengingat untuk settlement yang belum dibayar
