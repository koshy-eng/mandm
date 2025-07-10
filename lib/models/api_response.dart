class ApiResponse<T> {
  final int statusCode;
  final T message;

  ApiResponse({required this.statusCode, required this.message});

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    return ApiResponse(
      statusCode: json['status_code'],
      message: fromJsonT(json['message']),
    );
  }
}
