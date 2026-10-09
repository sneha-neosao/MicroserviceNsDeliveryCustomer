class ApiUrl {
  const ApiUrl._();

  static const baseUrl = "http://192.168.1.18:8000/api/v1"; // LOCAL
  // static const baseUrl = "https://mahachargerapis.neosao.co.in/api/v1"; // TEST
  // static const baseUrl = "https://chargeeatapis.neosao.co.in/api/v1"; // TEST

  static const refreshToken = "/auth/refresh/";

  static const sendOtp = "/web/send-otp";

  static const verifyOtp = "/web/verify-otp";

  static const register = "/web/register";

  static const addressList = "/web/address/list";

  static const addAddress = "/web/address/add";

  static String updateAddress(String publicId) =>
      "/web/address/update?public_id=$publicId";

  static String deleteAddress(String publicId) =>
      "/web/address/delete?public_id=$publicId";

  static const walletSummary = "/web/summary";

  static String homeData({
    int offset = 1,
    int limit = 10,
    double? lat,
    double? lng,
  }) {
    String url = "/web/home?offset=$offset&limit=$limit";
    if (lat != null && lng != null) {
      url += "&lat=$lat&lng=$lng";
    }
    return url;
  }
}


