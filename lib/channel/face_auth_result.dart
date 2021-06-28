class FaceAuthResult {
  final String reason;
  final bool isSuccess;
  final String resultCode;
  final String base64Image;

  FaceAuthResult({
    this.resultCode,
    this.reason,
    this.isSuccess,
    this.base64Image,
  });
}
