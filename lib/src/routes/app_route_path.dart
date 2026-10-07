enum AppRoute {
  splash(path: "/splash_screen"),
  login(path: "/login"),
  otp(path: "/otp"),
  register(path: "/register"),
  home(path: "/home"),
  search(path: "/search"),
  cart(path: "/cart"),
  stations(path: "/stations"),
  myCharge(path: "/my_charge"),
  history(path: "/history"),
  historyDetails(path: "/history_details"),
  profile(path: "/profile"),
  myVehicles(path: "/my_vehicles"),
  stationDetails(path: "/station_details"),
  setYourCharge(path: "/set_your_charge"),
  charging(path: "/charging"),
  walletHistory(path: "/wallet_history"),
  editProfile(path: "/edit_profile"),
  selectLocation(path: "/select_location"),
  address(path: "/address");

  final String path;

  const AppRoute({required this.path});
}
