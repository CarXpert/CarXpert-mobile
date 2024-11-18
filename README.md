# Car-Xpertmobile
> 

> Proyek ini dibuat untuk memenuhi tugas Proyek Akhir Semester (PAS) pada mata kuliah Pemrograman Berbasis Platform yang diselenggarakan oleh Fakultas Ilmu Komputer, Universitas Indonesia Tahun Ajaran 2024/2025 Semester Gasal.

<p align="center">
  <img src="static/images/logoreadme.png" alt="Logo" width="300" />
</p>

## 👥 Anggota Kelompok
Kami dari kelompok C-03 yang beranggotakan:
| Nama | NPM | 
| -- | -- | 
| Argya Farel Kasyara | 2306152424 | 
| Cleo Excellen Iskandar | 2306244886 | 
| Khoirul Azmi| 2306245812 | 
| Samuel Sebastian Sibarani | 2306245503 | 
| Adinda Maharani Wardhana | 2306165856 | 

## 📜 Deskripsi Aplikasi
CarXpert lahir dari kebutuhan masyarakat Jakarta akan akses informasi yang lebih baik dalam mencari mobil bekas. Di tengah meningkatnya mobilitas dan tuntutan ekonomi, banyak orang yang beralih ke opsi mobil bekas sebagai solusi kendaraan pribadi yang lebih terjangkau. Namun, dengan banyaknya pilihan yang tersedia, mencari mobil bekas yang sesuai dengan kebutuhan dan anggaran bisa menjadi tantangan tersendiri.

Website ini bertujuan untuk menjadi sumber informasi terpercaya bagi pengguna yang ingin membeli mobil bekas. Dengan menyediakan data yang lengkap dan transparan tentang berbagai produk mobil bekas, CarXpert membantu pengguna membuat keputusan yang lebih baik. Melalui CarXpert, pengguna tidak hanya dapat menemukan mobil bekas dengan mudah, tetapi juga mendapatkan wawasan tentang tren pasar otomotif terkini. Dengan demikian, website ini tidak hanya bermanfaat bagi mereka yang mencari mobil, tetapi juga membantu penjual dalam menjangkau calon pembeli yang lebih luas. CarXpert berkomitmen untuk memberikan pengalaman pencarian mobil bekas yang lebih baik bagi masyarakat Jakarta.

## 📚 Daftar Modul
### 1) Fitur Booking Jadwal dengan Showroom📝 (Argya Farel Kasyara)
Fitur ini memungkinkan pengguna untuk memesan jadwal kunjungan ke showroom yang menjual mobil bekas yang mereka minati. Dengan adanya fitur ini, pengguna dapat lebih mudah mengatur waktu untuk mengunjungi showroom dan melihat mobil secara langsung sebelum memutuskan untuk membeli. Fitur ini akan membantu showroom dalam mengelola jadwal kunjungan dan memastikan bahwa waktu kunjungan pengguna terorganisir dengan baik.
### 2) Tombol Detail Mobil🔘 (Khoirul Azmi)
Fitur ini memberikan informasi mendetail tentang mobil tertentu, seperti spesifikasi, kondisi, harga, dan fitur tambahan lainnya. Ketika pengguna mengklik tombol ini, mereka akan diarahkan ke halaman detail yang memuat semua informasi penting mengenai mobil yang mereka pilih.
### 3) Wishlist/favorite⭐ (Adinda Maharani Wardhana)
Fitur ini memungkinkan pengguna menyimpan mobil-mobil yang mereka minati ke dalam daftar favorit. Dengan demikian, pengguna dapat dengan mudah mengakses kembali mobil-mobil yang mereka sukai tanpa perlu melakukan pencarian ulang.
### 4) News seputar otomotif📰 (Samuel Sebastian Sibarani)
Modul ini menyediakan berita terkini dan artikel informatif seputar dunia otomotif. Pengguna bisa mendapatkan informasi terbaru mengenai tren mobil, tips perawatan, berita industri otomotif, dan hal-hal menarik lainnya yang dapat membantu mereka dalam mengambil keputusan pembelian.
### 5) Compare Cars📲 (Cleo Excellen Iskandar)
Membandingkan beberapa mobil bekas secara berdampingan. Fitur ini membantu calon pembeli membuat keputusan yang lebih cerdas dan terinformasi dengan menampilkan informasi detail dari mobil-mobil yang dipilih, sehingga mereka dapat dengan mudah melihat perbedaan antara berbagai pilihan.


## 🕵️ *Role* atau Peran Pengguna 
### 1. 👤 Guest (Pengguna yang tidak login)
- Guest adalah pengunjung website yang belum mendaftar atau login. Mereka dapat menelusuri daftar mobil bekas yang tersedia, menggunakan fitur pencarian, serta menyaring mobil berdasarkan kategori seperti harga, jarak tempuh, dan tahun pembuatan. Guest juga bisa membandingkan produk mobil bekas. Selain itu, mereka bisa melihat detail mobil dan membaca berita otomotif . Namun, Guest tidak dapat menambahkan mobil ke daftar favorit, membooking jadwal untuk pergi ke showroom dan menyimpan perbandingan produk mobil bekas. Untuk mengakses fitur tersebut, mereka perlu mendaftar atau login ke dalam akun pengguna.

### 2. 👨‍💻 User (Pengguna yang login)
- User ini mencari mobil bekas di Jakarta sesuai dengan kebutuhan mereka. User dapat menggunakan fitur pencarian untuk menemukan mobil berdasarkan kategori seperti harga, jarak tempuh, dan tahun pembuatan. Mereka dapat melihat detail mobil, menambahkan mobil ke daftar favorit, dapat membooking jadwal untuk ke showroom serta menggunakan fitur membandingkan produk mobil. Selain itu, pengguna juga dapat tetap mendapatkan berita terbaru mengenai dunia otomotif.

### 3. 👩‍💻 Admin
- Admin bertanggung jawab dalam mengelola dan memastikan kelancaran operasional aplikasi. Mereka dapat menambahkan produk mobil serta memastikan bahwa informasi dan berita otomotif yang ditampilkan selalu terbaru.
  
##  *Dataset* yang Digunakan
*Dataset* yang kami gunakan bersumber dari https://www.kaggle.com/datasets/adhiwirahardi/used-car-data-in-dki-jakarta  

## Alur Pengintegrasian dengan Web Service untuk Terhubung dengan Aplikasi Web yang Sudah dibuat saat Proyek Tengah Semester
1. Menambahkan depedensi `http` dengan menjalankan perintah `flutter pub add http` pada terminal proyek agar dapat digunakan untuk bertukar HTTP Request.
2. Membuat model yang sesuai dengan respons JSON dari *web service*, kami menggunakan QuickType untuk membantu pembuatan model-model *app* kami (tercantum pada direktori models).
3. Untuk menyesuaikan *return* yang dibutuhkan *app* yang dibuat, kami memodifikasi beberapa *views code web service* kami (proyek PTS Django).
4. Data yang didapat kemudian diolah atau dipetakan ke dalam suatu struktur data, baik `Map` maupun `List`. Kemudian, data yang sudah dikonversi ke aplimasi ditampilkan melalui `FutureBuilder`.

