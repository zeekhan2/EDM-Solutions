class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final dynamic error;

  /// ✅ Added to support APIs like:
  /// { success: true, date: "2025-12-17", data: [] }
  final String? date;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.date,
  });

  factory ApiResponse.success(
    T data, {
    String? message,
    String? date,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      date: date,
    );
  }

  factory ApiResponse.error(
    dynamic error, {
    String? message,
  }) {
    return ApiResponse(
      success: false,
      error: error,
      message: message,
    );
  }
}
