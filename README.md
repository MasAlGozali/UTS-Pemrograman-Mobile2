# Aplikasi Kasir Warung (Flutter)

Deskripsi singkat
-----------------

Proyek ini adalah aplikasi kasir sederhana untuk warung, dibangun dengan Flutter. Aplikasi menampilkan daftar menu terbagi per kategori (Makanan, Minuman, Camilan), memungkinkan pengguna menambahkan/mengurangi item ke keranjang, dan menampilkan ringkasan pesanan dengan perhitungan subtotal, diskon per-item, serta diskon transaksi (bonus 10% bila total > Rp 100.000).

Tujuan proyek
-------------

- Demonstrasi penggunaan `flutter_bloc` (Cubit) untuk manajemen state pada aplikasi kasir sederhana.
- Menyediakan contoh struktur kode yang mudah dimodifikasi untuk keperluan pembelajaran atau tugas UTS Pemrograman Mobile.

Fitur utama
-----------

- Pemilihan kategori menu (Makanan, Minuman, Camilan).
- Menambah item ke pesanan dari kartu menu.
- Menambah/mengurangi kuantitas langsung dari halaman ringkasan pesanan.
- Perhitungan subtotal tiap item memperhitungkan diskon individual (jika ada).
- Diskon transaksi 10% otomatis diterapkan jika total belanja melebihi Rp 100.000.

Struktur proyek (file & folder penting)
-------------------------------------

- `lib/main.dart`
	- Entrypoint aplikasi. Men-setup `BlocProvider` untuk `OrderCubit` dan `MaterialApp`.
- `lib/blocs/order_cubit.dart`
	- Logika aplikasi dan state untuk keranjang/pesanan. Berisi data dummy menu, fungsi penambah/pengurang item, perhitungan total dan final amount (setelah diskon bonus).
- `lib/models/menu_model.dart`
	- Model `MenuModel` (id, name, price, category, discount) dan `OrderItem` (menu + quantity, totalPrice getter).
- `lib/pages/order_home_page.dart`
	- Halaman utama. Menampilkan AppBar dengan ikon keranjang dan meload `CategoryStackPage`.
- `lib/pages/category_stack_page.dart`
	- Menampilkan bar kategori dan daftar menu sesuai kategori.
- `lib/pages/order_summary_page.dart`
	- Halaman ringkasan pesanan: list item, kontrol kuantitas, subtotal, diskon, total akhir, dan tombol 'Selesaikan Pesanan'.
- `lib/widgets/menu_card.dart`
	- Widget untuk menampilkan kartu menu beserta tombol 'Tambah'.
- `pubspec.yaml`
	- Menyertakan dependensi: `flutter_bloc`, `equatable`, `cupertino_icons`.

Alur kerja (data flow)
---------------------

1. `main.dart` membuat `OrderCubit` di root dengan `BlocProvider`.
2. `CategoryStackPage` menampilkan kategori; perubahan kategori memanggil `OrderCubit.changeCategory`.
3. `menusByCategory` (getter di `OrderCubit`) memfilter daftar menu (_allMenus) berdasarkan `state.activeCategory`.
4. Tombol 'Tambah' pada `MenuCard` memanggil `OrderCubit.addToOrder(menu)` — Cubit memperbarui `state.items` dan menghitung `totalAmount` & `finalAmount`.
5. Ikon keranjang di AppBar menunjukkan jumlah item saat ini dan menavigasi ke `OrderSummaryPage`.
6. Di `OrderSummaryPage` pengguna dapat menambah/kurangi kuantitas (memanggil `addToOrder`/`removeFromOrder`) atau menyelesaikan pesanan (`clearOrder`).

Penjelasan teknis inti
---------------------

- MenuModel.getDiscountedPrice(): menghitung harga setelah diskon per-item dengan formula (price - price * discount). Hasil di-convert ke `int` via `toInt()`.
- OrderItem.totalPrice: `menu.getDiscountedPrice() * quantity`.
- OrderCubit._updateOrderState(): menghitung `totalAmount` (sum semua item totalPrice) dan `finalAmount` (menerapkan diskon 10% bila `totalAmount > 100000`). Emit `OrderState` baru.

Kontrak data (shapes)
---------------------

- MenuModel (misal JSON):
	- id: String
	- name: String
	- price: int
	- category: String
	- discount: double (0..1)
- OrderItem:
	- menu: MenuModel
	- quantity: int
- OrderState:
	- items: List<OrderItem>
	- totalAmount: int
	- finalAmount: int
	- activeCategory: String

Edge cases & perhatian (bugs potensial)
-------------------------------------

1. Pembulatan/rounding: `toInt()` memotong desimal. Untuk pembulatan yang benar gunakan `round()` atau gunakan representasi integer penuh (sen/Rp) dan `NumberFormat` untuk display.
2. Validasi `discount`: tidak ada pengecekan range [0,1]. Bisa menyebabkan harga negatif jika nilai error. Tambahkan assert di konstruktor `MenuModel`.
3. Duplikasi `id` pada menu: `OrderCubit` mencari item berdasarkan `menu.id`. Pastikan id unik.
4. Tidak ada persistence: keranjang hilang saat restart aplikasi. Gunakan Hive/SharedPreferences jika perlu.
5. Format tampilan mata uang: saat ini string interpolation sederhana (`Rp ${value}`) tanpa pemisah ribuan.
6. Input kuantitas negatif: `updateQuantity` menerima nilai qty—pastikan tidak menerima negatif.

Rekomendasi pengujian
---------------------

- Unit tests untuk `OrderCubit`:
	- Menambah item baru (quantity 1), menambah item sama dua kali (quantity 2).
	- Mengurangi item dan menghapus item saat quantity mencapai 0.
	- Memastikan `finalAmount` menerapkan diskon 10% saat total > 100000.

Contoh perintah untuk menjalankan aplikasi
-----------------------------------------

Pastikan Flutter terpasang dan device/emulator tersedia. Di PowerShell jalankan:

```powershell
flutter pub get
flutter run
```

Untuk menjalankan test (jika ditambahkan):

```powershell
flutter test
```

1. Bagaimana state management dengan Cubit dapat membantu dalam pengelolaan transaksi yang memiliki logika diskon dinamis?
Jawaban (dalam konteks implementasi): Cubit akan menjadi pusat logika transaksi. Ketika pengguna menambahkan/menghapus item atau mengubah kuantitas, Cubit akan menerima event tersebut. Di dalam Cubit, kita akan memiliki state yang berisi daftar item pesanan. Setiap kali state ini berubah, kita bisa secara otomatis menghitung ulang total harga dan menerapkan logika diskon dinamis.

Misalnya, kita punya properti discount di MenuModel. Ketika item ditambahkan ke pesanan, Cubit akan menggunakan nilai discount dari MenuModel tersebut untuk menghitung harga setelah diskon. Jika ada bonus diskon total transaksi, Cubit juga yang akan memegang logika tersebut dan memperbarui state total harga yang akan ditampilkan. Ini membuat UI hanya perlu mendengarkan perubahan state dan tidak perlu tahu detail perhitungan diskon.

2. Apa perbedaan antara diskon per item dan diskon total transaksi? Berikan contoh penerapannya dalam aplikasi kasir.
Jawaban:

Diskon per Item: Diskon yang diterapkan pada harga satuan setiap produk.

Contoh: Nasi Goreng (Rp 20.000) diskon 10% menjadi Rp 18.000. Diskon ini dihitung dan mengurangi harga item tersebut secara individual. Dalam kode kita, ini diimplementasikan melalui getDiscountedPrice() di MenuModel.

Diskon Total Transaksi: Diskon yang diterapkan pada keseluruhan jumlah belanja setelah semua item dihitung.

Contoh: Total belanja Rp 120.000, ada diskon total 10% karena belanja lebih dari Rp 100.000, sehingga total bayar menjadi Rp 108.000. Ini biasanya merupakan fitur bonus yang diterapkan pada subtotal akhir. Dalam aplikasi kita, ini akan ditambahkan di dalam OrderCubit pada fungsi getTotalPrice() jika memenuhi kriteria tertentu.

3. Jelaskan manfaat penggunaan widget Stack pada tampilan kategori menu di aplikasi Flutter.
Jawaban: Widget Stack memungkinkan kita menumpuk beberapa widget di atas satu sama lain. Untuk tampilan kategori menu, Stack sangat bermanfaat karena:

Fleksibilitas Desain: Kita bisa menempatkan elemen background (misalnya gambar kategori), teks kategori, atau bahkan indikator selected di atas satu sama lain dengan mudah.

Efek Visual Interaktif: Memungkinkan kita untuk membuat efek visual yang menarik, seperti overlay atau elemen yang muncul/hilang di atas kategori lain. Misalnya, ketika satu kategori dipilih, kita bisa menempatkan overlay visual di atas kategori yang tidak aktif, atau menyorot kategori yang dipilih dengan menambahkan border atau shadow di atasnya.

Pengelolaan Lapisan UI: Memudahkan dalam mengatur lapisan-lapisan UI secara visual, memberikan kontrol presisi terhadap posisi setiap widget yang ditumpuk. Ini sangat berguna jika kita ingin menempatkan tombol atau ikon tertentu yang "melayang" di atas gambar latar belakang kategori.



