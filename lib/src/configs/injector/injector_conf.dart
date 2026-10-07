import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:nsdelivery_customer_app/src/configs/injector/injector.dart';

final getIt = GetIt.I;

void configureDepedencies() {
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        validateStatus: (status) => status != null && status < 400,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(ApiInterceptor(dio));
    return dio;
  });

  /// App Essentials
  getIt.registerLazySingleton(() => ThemeBloc());

  getIt.registerLazySingleton(() => TranslateBloc());

  getIt.registerLazySingleton(() => AppRouteConf());

  getIt.registerFactory(() => SplashBloc());

  /// Login & OTP
  getIt.registerLazySingleton<SendOtpUseCase>(() => SendOtpUseCase(getIt<Repository>()));
  getIt.registerFactory<SendOtpBloc>(() => SendOtpBloc(getIt<SendOtpUseCase>()));
  getIt.registerFactory<SendOtpFormBloc>(() => SendOtpFormBloc());

  getIt.registerLazySingleton<VerifyOtpUseCase>(() => VerifyOtpUseCase(getIt<Repository>()));
  getIt.registerFactory<VerifyOtpBloc>(
    () => VerifyOtpBloc(
      getIt<VerifyOtpUseCase>(),
      getIt<SendOtpUseCase>(),
    ),
  );
  getIt.registerFactory<VerifyOtpFormBloc>(() => VerifyOtpFormBloc());

  /// Register
  getIt.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(getIt<Repository>()));
  getIt.registerFactory<RegisterBloc>(() => RegisterBloc(getIt<RegisterUseCase>()));
  getIt.registerFactory<RegisterFormBloc>(() => RegisterFormBloc());

  /// Address
  getIt.registerLazySingleton<AddressListUseCase>(() => AddressListUseCase(getIt<Repository>()));
  getIt.registerFactory<AddressListBloc>(() => AddressListBloc(getIt<AddressListUseCase>()));

  /// API Helper

  getIt.registerLazySingleton(() => NetworkInfo());

  getIt.registerLazySingleton<Repository>(() => AuthRepositoryImpl(getIt<RemoteDataSourceImpl>(), getIt<NetworkInfo>()));
  getIt.registerLazySingleton(() => AuthRepositoryImpl(getIt<RemoteDataSourceImpl>(), getIt<NetworkInfo>()),);

  getIt.registerLazySingleton(() => RemoteDataSourceImpl(getIt<ApiHelper>()));

  getIt.registerLazySingleton(() => ApiHelper(getIt<Dio>()));
}
