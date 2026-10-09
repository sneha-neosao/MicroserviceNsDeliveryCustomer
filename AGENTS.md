# Project Architecture & Development Rules

> **MANDATORY RULE — Strict Structural Adherence with Feature-Specific Naming**:
> The architectural patterns, class structures, file separations (`part` / `part of`), dual-BLoC architecture, `sealed class` state/event hierarchies, modular widget breakdowns, and error-handling patterns specified in these rules MUST ALWAYS be strictly followed across ALL features and implementations without deviation.
> Only the **names** (class names, file names, event/state names, UseCases, repository methods, and UI widget names) must be adapted dynamically to reflect the specific feature, entity, or domain operation being developed (e.g., `OrderDetailsBloc`, `MenuManagementFormBloc`, `ProfileUpdateState`, `CategoryListWidget`).

## 1. Feature Folder Structure & Screen Creation
- **Feature Subfolder Architecture**: Every feature directory under `lib/src/features/<feature>/` must strictly contain the following top-level folders:
  - `bloc/`: Contains dedicated subfolders for each BLoC, state, and event (`bloc/<specific_bloc_name>/`).
  - `domain/`: Contains `usecases/` holding all UseCase files for that feature (`domain/usecases/`).
  - `presentation/`: Contains `pages/` holding all screen/page files (`presentation/pages/`).
  - `widgets/`: Contains all reusable UI component widgets for that feature (`widgets/`).
- **Always Stateful**: Every screen must always be created as a `StatefulWidget`.
- **File Location**: Always create screens inside the `presentation/pages/` folder of the specified feature (e.g., `lib/src/features/<feature>/presentation/pages/<name>_page.dart` or `<name>_screen.dart`).
- **Lean Screen Files**: The main screen file must not contain bulky UI code.
- **Separate UI Components**: Break the screen UI into separate modular components, save each component in the feature's `widgets/` folder, and call those widgets on the screen.

## 2. Route Configuration (`app_route_conf`)
- Always add route definitions using `AppRoute.<routeName>.path` and `AppRoute.<routeName>.name`.
- Use `pageBuilder` with `_fadePage(...)` and safely type-cast `state.extra`:
  ```dart
  GoRoute(
    path: AppRoute.bulkOrder.path,
    name: AppRoute.bulkOrder.name,
    pageBuilder: (context, state) {
      final assignment = state.extra as AssignmentBatch?;
      return _fadePage(BulkOrderScreen(assignment: assignment));
    },
  ),
  ```

## 3. API Implementation Order & Naming Rules
When adding an API, implement in this strict sequence:
1. **API URL**: Add static constant URL endpoint paths in `lib/src/core/api/api_url.dart`.
  - **MANDATORY**: `ApiUrl` must contain ONLY pure static constant strings (`static const profile = "/web/profile";`, `static const home = "/web/home";`, `static const updateAddress = "/web/address/update";`).
  - **NEVER** write functions or interpolate query strings / route parameters inside `ApiUrl`.
2. **UseCase**: Create the use case in `domain/usecases/`.
3. **Repository**: Create repository & implementation in `data/repository/`.
  - **Naming Convention**: Function names in repository MUST be **lower_case with underscores** (e.g., `profile_details`, `category_products`, `search_products`).
4. **Remote DataSource**: Create in `data/datasources/`.
  - **Naming Convention**: Function names in Remote DataSource MUST have the **1st letter Capital / PascalCase** (e.g., `ProfileDetails`, `CategoryProducts`, `SearchProducts`).
  - **Query & Payload Binding in Remote DataSource**: All query strings, query parameters, route parameters, and data payloads (`data = ...`, `String param = "?public_id=$publicId"`, `final url = "${ApiUrl.xyz}?..."`) MUST strictly be constructed and bound directly inside the **Remote DataSource** implementation methods, NOT in `ApiUrl`.
  - **Direct Parameter Binding (No Empty/Null Checks)**: When binding parameters into payload maps or query strings in the Remote DataSource, bind parameters directly (e.g., `"email": params.email`, `"?offset=${params.offset}&limit=${params.limit}&lat=${params.lat}&lng=${params.lng}"`) without checking whether fields are null or empty.

## 4. BLoC Creation & Dependency Injection Order
Always create state management in this exact sequence:
1. **Dedicated Subfolder**: For each BLoC, create a dedicated subfolder under `bloc/<specific_bloc_name>/` (e.g., `features/<feature>/bloc/otp_request/` or `features/<feature>/bloc/otp_request_form/`).
2. **State First**: Create `<feature>_state.dart` (or `<feature>_form_state.dart`).
3. **Event Second**: Create `<feature>_event.dart` (or `<feature>_form_event.dart`).
4. **BLoC Third**: Create `<feature>_bloc.dart` (or `<feature>_form_bloc.dart`) linking the UseCase and handling events.
5. **Injector Configuration**:
  - Add the BLoC/UseCase export imports in `lib/src/configs/injector/injector.dart`.
  - Register UseCases as `registerLazySingleton` and BLoCs as `registerFactory` (or `registerLazySingleton` if global) in `lib/src/configs/injector/injector_conf.dart`.

### 4.1. Standard API Execution BLoC Structure (`part` / `part of` pattern)

- **State File (`<feature>_state.dart`)**:
  ```dart
  part of 'auth_login_bloc.dart';

  sealed class AuthLoginState extends Equatable {
    const AuthLoginState();
    @override
    List<Object?> get props => [];
  }

  class AuthLoginInitialState extends AuthLoginState {}

  /// States representing login operation
  class AuthLoginLoadingState extends AuthLoginState {}

  class AuthLoginSuccessState extends AuthLoginState {
    final LoginResponse data;

    const AuthLoginSuccessState(this.data);

    @override
    List<Object?> get props => [data];
  }

  class AuthLoginFailureState extends AuthLoginState {
    final String message;

    const AuthLoginFailureState(this.message);

    @override
    List<Object?> get props => [message];
  }

  /// States representing login status check
  class AuthCheckSignInStatusLoadingState extends AuthLoginState {}

  class AuthCheckSignInStatusSuccessState extends AuthLoginState {
    final LoginResponse data;
    const AuthCheckSignInStatusSuccessState(this.data);

    @override
    List<Object?> get props => [data];
  }

  class AuthCheckSignInStatusFailureState extends AuthLoginState {
    final String message;

    const AuthCheckSignInStatusFailureState(this.message);

    @override
    List<Object?> get props => [message];
  }

  /// States representing logout operation
  class AuthLogoutLoadingState extends AuthLoginState {}

  class AuthLogoutSuccessState extends AuthLoginState {
    final CommonResponse data;

    const AuthLogoutSuccessState(this.data);

    @override
    List<Object?> get props => [data];
  }

  class AuthLogoutFailureState extends AuthLoginState {
    final String message;

    const AuthLogoutFailureState(this.message);

    @override
    List<Object?> get props => [message];
  }
  ```

- **Event File (`<feature>_event.dart`)**:
  ```dart
  part of 'auth_login_bloc.dart';

  /// Base event for authentication
  sealed class AuthEvent extends Equatable {
    const AuthEvent();

    @override
    List<Object?> get props => [];
  }

  /// Event for login
  class AuthLoginEvent extends AuthEvent {
    final String email;
    final String password;

    const AuthLoginEvent(this.email, this.password);

    @override
    List<Object?> get props => [email, password];
  }

  /// Event for logout
  class AuthLogoutEvent extends AuthEvent {}

  /// Event to check login status
  class AuthCheckSignInStatusEvent extends AuthEvent {}

  /// Event for forgot password
  class AuthForgotPasswordEvent extends AuthEvent {
    final String company_code;
    final String email;

    const AuthForgotPasswordEvent(this.company_code, this.email);

    @override
    List<Object?> get props => [company_code, email];
  }

  /// Event to delete user account
  class AccountDeleteGetEvent extends AuthEvent {
    final int id;

    const AccountDeleteGetEvent(this.id);

    @override
    List<Object?> get props => [id];
  }
  ```

- **BLoC File (`<feature>_bloc.dart`)**:
  ```dart
  import 'package:equatable/equatable.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:fpdart/fpdart.dart';
  import '../../../../core/errors/exceptions.dart';
  import '../../../../core/errors/failures.dart';
  import '../../../../core/session/session_manager.dart';
  import '../../../../core/usecases/usecase.dart';
  import '../../../../core/utils/failure_converter.dart';
  import '../../../../core/utils/logger.dart';
  import '../../domain/login_usecase.dart';
  import '../../domain/logout_usecase.dart';
  import '../../../../remote/models/auth_model/Login_response.dart';
  import '../../../../remote/models/common_response.dart';

  part 'auth_login_event.dart';
  part 'auth_login_state.dart';

  /// Handles state management for **Auth Login** and its related operations.
  class AuthLoginBloc extends Bloc<AuthEvent, AuthLoginState> {
    final AuthLoginUseCase _loginUseCase;
    final LogoutUseCase _logoutUseCase;

    AuthLoginBloc(
      this._loginUseCase,
      this._logoutUseCase,
    ) : super(AuthLoginInitialState()) {
      on<AuthLoginEvent>(_login);
      on<AuthCheckSignInStatusEvent>(_checkSignInStatus);
      on<AuthLogoutEvent>(_logout);
    }

    /// - **Login:** Handles [AuthLoginEvent] → calls [AuthLoginUseCase]
    Future _login(AuthLoginEvent event, Emitter emit) async {
      emit(AuthLoginLoadingState());

      final result = await _loginUseCase.call(
        LoginParams(
          email: event.email,
          password: event.password,
        ),
      );

      result.fold(
        (l) => emit(AuthLoginFailureState(l.message)),
        (r) => emit(AuthLoginSuccessState(r)),
      );
    }

    /// - **Check Sign-In Status:** Handles [AuthCheckSignInStatusEvent] → checks [SessionManager]
    Future<Either<Failure, LoginResponse>> checkSignInStatus() async {
      try {
        final result = await SessionManager.isLoggedIn();

        if (result == true) {
          final resultData = await SessionManager.getUserSession();
          return Right(resultData!);
        }
        return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
      } on CacheException {
        return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
      }
    }

    Future _checkSignInStatus(AuthCheckSignInStatusEvent event, Emitter emit) async {
      emit(AuthCheckSignInStatusLoadingState());

      final result = await checkSignInStatus();
      result.fold(
        (l) => emit(AuthCheckSignInStatusFailureState(mapFailureToMessage(l))),
        (r) => emit(AuthCheckSignInStatusSuccessState(r)),
      );
    }

    /// - **Logout:** Handles [AuthLogoutEvent] → clears [SessionManager]
    Future _logout(AuthLogoutEvent event, Emitter emit) async {
      emit(AuthLogoutLoadingState());

      final result = await _logoutUseCase.call(NoParams());

      result.fold(
        (l) => emit(AuthLogoutFailureState(l.message)),
        (r) => emit(AuthLogoutSuccessState(r)),
      );
    }

    @override
    Future<void> close() {
      logger.i("===== CLOSE AuthLoginBloc =====");
      return super.close();
    }
  }
  ```

### 4.2. Standard Form Validation BLoC Structure (`part` / `part of` pattern)

- **Form State File (`<feature>_form_state.dart`)**:
  ```dart
  part of 'auth_login_form_bloc.dart';

  /// Base state for Form Validation BLoC.
  sealed class LoginFormState extends Equatable {
    final String email;
    final String password;
    final bool isValid;

    const LoginFormState({
      required this.email,
      required this.password,
      required this.isValid,
    });

    @override
    List<Object?> get props => [
          email,
          password,
          isValid,
        ];
  }

  /// Initial empty form state
  class LoginFormInitialState extends LoginFormState {
    const LoginFormInitialState()
        : super(
            email: "",
            password: "",
            isValid: false,
          );
  }

  /// Validated form data state representing the current input snapshot
  class LoginFormDataState extends LoginFormState {
    final String inputEmail;
    final String inputPassword;
    final bool inputIsValid;

    const LoginFormDataState({
      required this.inputEmail,
      required this.inputPassword,
      required this.inputIsValid,
    }) : super(
            email: inputEmail,
            password: inputPassword,
            isValid: inputIsValid,
          );

    @override
    List<Object?> get props => [
          inputEmail,
          inputPassword,
          inputIsValid,
        ];
  }
  ```

- **Form Event File (`<feature>_form_event.dart`)**:
  ```dart
  part of 'auth_login_form_bloc.dart';

  /// Base class for all form input events
  sealed class LoginFormEvent extends Equatable {
    const LoginFormEvent();

    @override
    List<Object?> get props => [];
  }

  /// Listens for changes in email input
  class LoginFormEmailChangedEvent extends LoginFormEvent {
    final String email;

    const LoginFormEmailChangedEvent(this.email);

    @override
    List<Object?> get props => [email];
  }

  /// Listens for changes in password input
  class LoginFormPasswordChangedEvent extends LoginFormEvent {
    final String password;

    const LoginFormPasswordChangedEvent(this.password);

    @override
    List<Object?> get props => [password];
  }
  ```

- **Form BLoC File (`<feature>_form_bloc.dart`)**:
  ```dart
  import 'package:equatable/equatable.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import '../../../../core/utils/logger.dart';

  part 'auth_login_form_event.dart';
  part 'auth_login_form_state.dart';

  /// Handles validation logic for **Login Form Inputs**.
  class AuthLoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
    AuthLoginFormBloc() : super(const LoginFormInitialState()) {
      on<LoginFormEmailChangedEvent>(_emailChanged);
      on<LoginFormPasswordChangedEvent>(_passwordChanged);
    }

    /// - Listens to changes in login email input
    Future _emailChanged(LoginFormEmailChangedEvent event, Emitter emit) async {
      emit(
        LoginFormDataState(
          inputEmail: event.email,
          inputPassword: state.password,
          inputIsValid: inputValidator(
            event.email,
            state.password,
          ),
        ),
      );
    }

    /// - Listens to changes in login password input
    Future _passwordChanged(
        LoginFormPasswordChangedEvent event, Emitter emit) async {
      emit(
        LoginFormDataState(
          inputEmail: state.email,
          inputPassword: event.password,
          inputIsValid: inputValidator(
            state.email,
            event.password,
          ),
        ),
      );
    }

    bool inputValidator(String email, String password) {
      if (email.isNotEmpty && password.isNotEmpty && password.length >= 6) {
        return true;
      }
      return false;
    }

    @override
    Future<void> close() {
      logger.i("===== CLOSE AuthLoginFormBloc =====");
      return super.close();
    }
  }
  ```

## 5. BLoC Usage in Screens
- **Always MultiBlocProvider**: Always wrap the screen with `MultiBlocProvider` and inject BLoC instances from injector (`getIt<FeatureBloc>()`), even if only a single BLoC is being called.

## 6. Colors & Theming
- **AppColor Only**: Always use `AppColor` (e.g., `AppColor.primary`, `AppColor.white`). **NEVER** use raw `Colors.` or `Color(...)`.
- **Theme-Only Text Styling (Strictly No Direct `GoogleFonts` in UI)**: **NEVER** import `package:google_fonts/google_fonts.dart` or call `GoogleFonts.<font>(...)` directly inside screens, pages, or reusable UI widgets. The font family (`Poppins`) and all typography scales are already centrally configured in `AppTheme` and `AppFont`.
  - **Always** use the app's theme text styling: `Theme.of(context).textTheme.<style>?.copyWith(...)` (e.g., `Theme.of(context).textTheme.bodyMedium?.copyWith(...)`, `Theme.of(context).textTheme.headlineMedium?.copyWith(...)`, `Theme.of(context).textTheme.displayMedium?.copyWith(...)`).
  - If central font helpers are needed outside or within widgets, reference `AppFont` definitions (`AppFont.normal`, `AppFont.semiBold`, `AppFont.bold`), but **never** instantiate `GoogleFonts.<font>(...)` directly in UI components.
- **Dynamic Multi-line Text Safety**: For text fetched from API or any text that can be long, always add multiline wrapping logic (using `Expanded`/`Flexible` and `softWrap: true`) so if space is insufficient, text moves to the next line without causing overflow errors.

## 7. Spacing & Responsive Units
- Always use `.hS` for vertical sizing/padding and `.wS` for horizontal sizing/padding (e.g., `16.hS`, `16.wS`).

## 8. Screen Layout & System UI Safety
- **No System UI Overlap**: UI must never get overlapped by bottom system buttons/navigation bar or top status bar.
- **Full-Screen Top with Safe Scrolling**: At the top, render full screen under the status bar (no hard safe area box), but when scrollable content is scrolled up, it must scroll cleanly with safe area padding so nothing is obscured or cut off.

## 9. Snackbars & Dialogs
- **AppSnackBar**: Always use `AppSnackBar` whenever showing a toast or snackbar message at any point.
- **Custom Dialogs**: When showing an alert dialog, always use the custom dialog widget created in the feature's `widgets/` folder.

## 10. Empty States & Pagination
- **No Data Message**: Always display a dedicated "No Data" / empty state message when an API returns empty or no data.
- **Pagination**: For any list/grid views displaying API data, always implement pagination (`page`, `limit`, and scroll listener loading).

## 11. App Permissions & Play Store Policy Safety
- When adding permissions in `AndroidManifest.xml`, always ensure they are fully compliant with Google Play Store policies. Only add a permission if it is strictly mandatory and the feature cannot function without it.

## 12. Models & Response Classes Null Safety
- **Strict Null Handling**: When creating any model or response class, all fields and parsed JSON values MUST be null-handled safely.
- **Safe JSON Parsing**: Never assume non-null values from API responses. Use nullable types (`Type?`) or safe default fallbacks (e.g., `json['name'] ?? ''`, `json['count'] ?? 0, `json['items'] != null ? ... : []`) so that JSON parsing never throws null-pointer exceptions or crashes on missing/null keys.

## 13. Reusable Form TextFields & Dual-BLoC Input Architecture
- **Generic Reusable TextField Component**: Whenever adding form text fields, create and use a generic reusable widget (e.g., `LoginTextField<T>`) parameterized with the form BLoC `<T>` to handle validation, input formatting, error styles, and secure text toggling:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:easy_localization/easy_localization.dart';
  import '../../../../core/extensions/integer_sizedbox_extension.dart';
  import '../../../../core/extensions/string_validator_extension.dart';
  import '../../../../core/theme/app_color.dart';

  class LoginTextField<T> extends StatefulWidget {
    final String label;
    final String hintText;
    final IconData prefixIcon;
    final TextEditingController? controller;
    final bool isSecure;
    final TextInputType keyboardType;
    final List<TextInputFormatter>? inputFormatters;
    final ValueChanged<String>? onChanged;
    final String? Function(String?)? validator;
    final String? initialValue;
    final bool? readOnly;
    final TextCapitalization? textCapitalization;

    const LoginTextField({
      super.key,
      required this.label,
      required this.hintText,
      required this.prefixIcon,
      this.controller,
      this.isSecure = false,
      this.keyboardType = TextInputType.text,
      this.inputFormatters,
      this.onChanged,
      this.validator,
      this.initialValue,
      this.readOnly,
      this.textCapitalization,
    });

    @override
    State<LoginTextField<T>> createState() => _LoginTextFieldState<T>();
  }

  class _LoginTextFieldState<T> extends State<LoginTextField<T>> {
    bool _isVisible = true;

    void _toggleVisibility() {
      setState(() {
        _isVisible = !_isVisible;
      });
    }

    @override
    Widget build(BuildContext context) {
      final formBloc = context.read<T>();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColor.charcoal,
            ),
          ),
          4.hS,
          TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            obscureText: widget.isSecure ? _isVisible : false,
            onChanged: widget.onChanged,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
            inputFormatters: widget.inputFormatters,
            keyboardType: widget.keyboardType,
            readOnly: widget.readOnly ?? false,
            validator: (val) {
              if (formBloc is AuthLoginFormBloc) {
                if (widget.label == "email".tr() && (val == null || val.isEmpty)) {
                  return "please_enter_email".tr();
                } else if (widget.label == "email".tr() && !formBloc.state.email.isEmailValid) {
                  return "please_enter_valid_email".tr();
                } else if (widget.label == "login_password_label".tr() && (val == null || val.isEmpty)) {
                  return "please_enter_password".tr();
                } else if (widget.label == "login_password_label".tr() && !formBloc.state.password.isPasswordValid) {
                  return "please_enter_valid_password".tr();
                }
              }

              return widget.validator?.call(val);
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: Icon(widget.prefixIcon, color: AppColor.icon),
              suffixIcon: widget.isSecure
                  ? IconButton(
                      onPressed: _toggleVisibility,
                      icon: Icon(
                        _isVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF7A869A),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppColor.white.withValues(alpha: 0.9),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              errorStyle: const TextStyle(
                fontSize: 11,
                color: AppColor.bright_red,
                height: 1.2,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      );
    }
  }
  ```

- **Encapsulated Form Input Widget**: Always create a single dedicated input container widget in `widgets/` (e.g., `LoginInputWidget`) that groups all the textfields for that feature/form and dispatches change events to the form BLoC:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:easy_localization/easy_localization.dart';
  import '../../../../core/extensions/integer_sizedbox_extension.dart';
  import '../../../../configs/injector/injector.dart';
  import 'login_textfield.dart';

  class LoginInputWidget extends StatelessWidget {
    const LoginInputWidget({super.key});

    @override
    Widget build(BuildContext context) {
      final formBloc = context.read<AuthLoginFormBloc>();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile / Email Input
          LoginTextField<AuthLoginFormBloc>(
            label: 'email'.tr(),
            hintText: 'enter_your_email'.tr(),
            prefixIcon: Icons.phone_iphone_rounded,
            onChanged: (val) {
              final trimmed = val.trim();
              formBloc.add(LoginFormEmailChangedEvent(trimmed));
            },
            keyboardType: TextInputType.emailAddress,
          ),
          12.hS,

          // Password Input
          LoginTextField<AuthLoginFormBloc>(
            label: 'login_password_label'.tr(),
            hintText: 'login_password_hint'.tr(),
            prefixIcon: Icons.lock_outline_rounded,
            onChanged: (val) {
              final trimmed = val.trim();
              formBloc.add(LoginFormPasswordChangedEvent(trimmed));
            },
            isSecure: true,
          ),
        ],
      );
    }
  }
  ```

- **Dual-BLoC Architecture & API Submission**:
  - Always separate the **Form State BLoC** (e.g. `AuthLoginFormBloc` for capturing and validating user inputs) from the **API Execution BLoC** (e.g. `AuthLoginBloc` for triggering the remote API call and handling loading/success/error responses).
  - In the screen, provide both BLoCs with `MultiBlocProvider`.
  - When triggering the API call, unfocus inputs, read the state from the Form BLoC, and dispatch the event to the API BLoC:
  ```dart
  void _login(BuildContext context) {
    primaryFocus?.unfocus();
    final authForm = context.read<AuthLoginFormBloc>().state;

    context.read<AuthLoginBloc>().add(
      AuthLoginEvent(authForm.email.trim(), authForm.password.trim()),
    );
  }
  ```
  - Listen for API results (e.g., token management, sockets, navigation, and snackbars) using `BlocConsumer<AuthLoginBloc, AuthLoginState>`.

## 14. Static Strings & Localization (`easy_localization`)
- **No Hardcoded Strings**: Never hardcode user-facing static strings directly in UI widgets, form labels, hint texts, validation messages, toast alerts, dialogs, or button labels.
- **Add to Translation File First**: Always define all static text strings first in the English translation file (`assets/translations/en-US.json`) using descriptive `lower_case_with_underscores` keys:
  ```json
  {
    "enter_your_email": "Enter Your Email",
    "please_enter_email": "Please enter email",
    "please_enter_valid_email": "Please enter a valid email",
    "login_password_label": "Password",
    "login_password_hint": "Enter your password",
    "login_button": "Login"
  }
  ```
- **Consume via `.tr()`**: Always consume the strings across all widgets and validation logic using EasyLocalization's `.tr()` extension method:
  ```dart
  label: 'login_password_label'.tr(),
  hintText: 'enter_your_email'.tr(),
  ```

## 15. Session Management & Splash Screen Check Sign-In Pattern
- **Session Storage**:
  - Upon successful login, store both the login flag (`SessionManager.saveLoginStatus(true)`) and full session object (`SessionManager.saveUserSession(respData)`).
- **Check Sign-In in BLoC**:
  - The API execution BLoC (e.g. `AuthLoginBloc`) handles `AuthCheckSignInStatusEvent` by checking `SessionManager.isLoggedIn()`.
  - If `true`, fetch `SessionManager.getUserSession()` and emit `AuthCheckSignInStatusSuccessState(resultData)`. Otherwise emit `AuthCheckSignInStatusFailureState(...)`.
  ```dart
  Future<Either<Failure, LoginResponse>> checkSignInStatus() async {
    try {
      final result = await SessionManager.isLoggedIn();
      if (result == true) {
        final resultData = await SessionManager.getUserSession();
        return Right(resultData!);
      }
      return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
    } on CacheException {
      return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
    }
  }

  Future _checkSignInStatus(AuthCheckSignInStatusEvent event, Emitter emit) async {
    emit(AuthCheckSignInStatusLoadingState());
    final result = await checkSignInStatus();
    result.fold(
      (l) => emit(AuthCheckSignInStatusFailureState(mapFailureToMessage(l))),
      (r) => emit(AuthCheckSignInStatusSuccessState(r)),
    );
  }
  ```
- **Splash Screen Orchestration**:
  - Provide `AuthLoginBloc` in `SplashScreen` and trigger `AuthCheckSignInStatusEvent()` on creation:
    ```dart
    BlocProvider(
      create: (_) => getIt<AuthLoginBloc>()..add(AuthCheckSignInStatusEvent()),
    ),
    ```
  - Listen with `BlocListener<AuthLoginBloc, AuthLoginState>` filtering for `AuthCheckSignInStatusSuccessState` or `AuthCheckSignInStatusFailureState`.
  - Combine the splash visual duration (timer or gif controller) and auth check with `_navigateIfReady()`.
  - Navigate to `AppRoute.dashboard.name` if authenticated, or `AppRoute.login.name` if not.



