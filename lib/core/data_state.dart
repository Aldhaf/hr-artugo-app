// Kelas abstrak sebagai dasar untuk semua state.
abstract class DataState<T> {
  const DataState();
}

// State yang merepresentasikan kondisi saat data sedang dimuat.
class DataLoading<T> extends DataState<T> {
  const DataLoading();
}

// State yang merepresentasikan kondisi saat data berhasil didapatkan.
// Berisi data itu sendiri.
class DataSuccess<T> extends DataState<T> {
  final T data;
  const DataSuccess(this.data);
}

// State yang merepresentasikan kondisi saat terjadi error.
// Berisi pesan error.
class DataError<T> extends DataState<T> {
  // Kita sepakat menggunakan 'error'
  final String? error;
  const DataError(this.error);
}