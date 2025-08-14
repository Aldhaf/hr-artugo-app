class Profile {
  final String userName;
  final String jobTitle;
  final String? imageUrl; // Bisa null

  Profile({
    required this.userName,
    required this.jobTitle,
    this.imageUrl,
  });

  // 1. Konversi dari Map (JSON) menjadi objek Profile
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userName: json['userName'] as String,
      jobTitle: json['jobTitle'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  // 2. Konversi dari objek Profile menjadi Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'jobTitle': jobTitle,
      'imageUrl': imageUrl,
    };
  }

  // Helper getter untuk menampilkan inisial
  String get initials {
    if (userName.isEmpty) return 'U';
    return userName.split(' ').map((l) => l[0]).take(2).join().toUpperCase();
  }

  // Helper getter untuk mengecek validitas gambar base64
  bool get hasValidImage {
    final img = imageUrl;
    if (img == null || img.isEmpty) return false;
    // Pengecekan sederhana, bisa disesuaikan
    return !img.contains(" ") && img.length % 4 == 0;
  }
}
