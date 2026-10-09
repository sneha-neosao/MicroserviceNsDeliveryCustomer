class ApiUrl {
  const ApiUrl._();

  static const baseUrl = "http://192.168.1.8:8000/api/v1"; // LOCAL
  // static const baseUrl = "https://mahachargerapis.neosao.co.in/api/v1"; // TEST
  // static const baseUrl = "https://chargeeatapis.neosao.co.in/api/v1"; // TEST

  static const refreshToken = "/auth/refresh/";

  static const sendOtp = "/web/send-otp";

  static const verifyOtp = "/web/verify-otp";

  static const register = "/web/register";

  static const addressList = "/web/address/list";

  static const addAddress = "/web/address/add";

  static const updateAddress = "/web/address/update";

  static const deleteAddress = "/web/address/delete";

  static const walletSummary = "/web/summary";

  static const profile = "/web/profile";

  static const home = "/web/home";
}


