import 'package:breezefood/features/profile/data/repo/addresses_repo.dart';
import 'package:breezefood/features/profile/presentation/cubit/addresses_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:breezefood/core/network/dio_factory.dart';

// ========== AUTH ==========
import 'package:breezefood/features/auth/data/api/auth_api_service.dart';
import 'package:breezefood/features/auth/data/repo/auth_repository.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';

// ========== HOME ==========
import 'package:breezefood/features/home/data/api/home_api_service.dart';
import 'package:breezefood/features/home/data/repo/home_repository.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';

// ========== PROFILE ==========
import 'package:breezefood/features/profile/data/api/profile_api_service.dart';
import 'package:breezefood/features/profile/data/api/addresses_api_service.dart';
import 'package:breezefood/features/profile/data/repo/profile_repository.dart'
    show ProfileRepository;
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';

// ========== CART / ORDERS ==========
import 'package:breezefood/features/orders/data/api/cart_api_service.dart';
import 'package:breezefood/features/orders/data/api/orders_api_service.dart';
import 'package:breezefood/features/orders/data/repo/appetizers_repository.dart';
import 'package:breezefood/features/orders/data/repo/cart_repository.dart';
import 'package:breezefood/features/orders/data/repo/orders_repository.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_tracking_state.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders_details_cubit.dart';

import 'package:breezefood/features/stores/data/api/stores_api_service.dart';
import 'package:breezefood/features/stores/data/repo/stores_repo.dart';
import 'package:breezefood/features/stores/presentation/cubit/stores_cubit.dart';

import 'package:breezefood/features/stores/data/api/restaurant_details_api_service.dart';
import 'package:breezefood/features/stores/data/repo/restaurant_details_repo.dart';
import 'package:breezefood/features/stores/presentation/cubit/restaurant_details_cubit.dart';

import 'package:breezefood/features/stores/data/api/most_popular_api_service.dart';
import 'package:breezefood/features/stores/data/repo/most_popular_repo.dart';

import 'package:breezefood/features/stores/data/api/super_market_api_service.dart';
import 'package:breezefood/features/stores/data/repo/super_market_repo.dart';
import 'package:breezefood/features/stores/presentation/cubit/super_markets_list_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/markets_cubit.dart';

// ========== FAVORITES ==========
import 'package:breezefood/features/favorite_page/data/api/favorites_api_service.dart';
import 'package:breezefood/features/favorite_page/data/repo/favorites_repository.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';

// ========== REVIEWS ==========
import 'package:breezefood/features/ratings/data/api/reviews_api_service.dart';
import 'package:breezefood/features/ratings/data/repo/reviews_repo.dart';
import 'package:breezefood/features/ratings/presentation/cubit/rating_submit_cubit.dart';

// ========== SEARCH ==========
import 'package:breezefood/features/search/data/api/search_api_service.dart';
import 'package:breezefood/features/search/data/repo/search_repo.dart';
import 'package:breezefood/features/search/presentation/cubit/search_cubit.dart';

// ========== HELP / TERMS ==========
import 'package:breezefood/features/help_center/data/api/help_center_api_service.dart';
import 'package:breezefood/features/help_center/data/repo/help_center_repo.dart';
import 'package:breezefood/features/help_center/presentation/cubit/help_center_cubit.dart';

import 'package:breezefood/features/terms/data/api/terms_api_service.dart';
import 'package:breezefood/features/terms/data/repo/terms_repository.dart';
import 'package:breezefood/features/terms/presentation/cubit/terms_cubit.dart';

// ========== NOTIFICATIONS ==========
import 'package:breezefood/features/notifications/data/api/notification_api_service.dart';
import 'package:breezefood/features/notifications/data/repo/notifications_repo.dart';
import 'package:breezefood/features/notifications/presentation/cubit/notification_cubit.dart';

import 'package:breezefood/features/assistant/data/repo/assistant_repository.dart';
import 'package:breezefood/features/assistant/presentation/cubit/assistant_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDi() async {
  // =========================
  // Local storage
  // =========================
  await Hive.initFlutter();
  await Hive.openBox("settings");
  await Hive.openBox<String>("token");

  // =========================
  // Dio (ONE instance فقط ✅)
  // =========================
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() => DioFactory.getDio());
  }

  // =========================
  // APPETIZERS
  // =========================
  getIt.registerLazySingleton<AppetizersRepository>(
    () => AppetizersRepository(getIt<Dio>()),
  );

  // =========================
  // ASSISTANT
  // =========================
  getIt.registerLazySingleton<AssistantRepository>(
    () => AssistantRepository(getIt<Dio>()),
  );
  getIt.registerFactory<AssistantCubit>(
    () => AssistantCubit(getIt<AssistantRepository>()),
  );

  // =========================
  // AUTH
  // =========================
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthApiService>()),
  );
  getIt.registerFactory<AuthFlowCubit>(
    () => AuthFlowCubit(getIt<AuthRepository>()),
  );

  // =========================
  // HOME
  // =========================
  getIt.registerLazySingleton<HomeApiService>(
    () => HomeApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepository(getIt<HomeApiService>()),
  );

  /// ✅ مهم جداً للـ Splash preload
  getIt.registerLazySingleton<HomeCubit>(
    () => HomeCubit(getIt<HomeRepository>(), getIt<AuthRepository>()),
  );

  // =========================
  // STORES
  // =========================
  getIt.registerLazySingleton<StoresApiService>(
    () => StoresApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<StoresRepository>(
    () => StoresRepository(getIt<StoresApiService>()),
  );
  getIt.registerFactory<StoresCubit>(
    () => StoresCubit(getIt<StoresRepository>()),
  );

  // Most Popular (عادة شاشة/تاب → Factory)
  getIt.registerFactory<MostPopularApiService>(
    () => MostPopularApiService(getIt<Dio>()),
  );
  getIt.registerFactory<MostPopularRepository>(
    () => MostPopularRepository(getIt<MostPopularApiService>()),
  );

  // Restaurant Details
  getIt.registerLazySingleton<RestaurantDetailsApiService>(
    () => RestaurantDetailsApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<RestaurantDetailsRepository>(
    () => RestaurantDetailsRepository(getIt<RestaurantDetailsApiService>()),
  );
  getIt.registerFactory<RestaurantDetailsCubit>(
    () => RestaurantDetailsCubit(getIt<RestaurantDetailsRepository>()),
  );

  // Super Markets
  getIt.registerLazySingleton<SuperMarketApiService>(
    () => SuperMarketApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<SuperMarketRepo>(
    () => SuperMarketRepo(getIt<SuperMarketApiService>()),
  );
  getIt.registerFactory<SuperMarketsListCubit>(
    () => SuperMarketsListCubit(getIt<SuperMarketRepo>()),
  );
  getIt.registerFactory<MarketsCubit>(
    () => MarketsCubit(getIt<SuperMarketRepo>()),
  );

  // =========================
  // REVIEWS
  // =========================
  getIt.registerLazySingleton<ReviewsApiService>(
    () => ReviewsApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepository(getIt<ReviewsApiService>()),
  );
  getIt.registerFactory<RatingSubmitCubit>(
    () => RatingSubmitCubit(getIt<ReviewsRepository>()),
  );

  // =========================
  // FAVORITES
  // =========================
  getIt.registerLazySingleton<FavoritesApiService>(
    () => FavoritesApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepository(getIt<FavoritesApiService>()),
  );

  /// Favorites عادة مرتبط بتاب → Factory أفضل
  getIt.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(getIt<FavoritesRepository>()),
  );

  // =========================
  // HELP CENTER
  // =========================
  getIt.registerLazySingleton<HelpCenterApiService>(
    () => HelpCenterApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<HelpCenterRepo>(
    () => HelpCenterRepo(getIt<HelpCenterApiService>()),
  );
  getIt.registerFactory<HelpCenterCubit>(
    () => HelpCenterCubit(getIt<HelpCenterRepo>()),
  );

  // =========================
  // TERMS
  // =========================
  getIt.registerLazySingleton<TermsApiService>(
    () => TermsApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<TermsRepository>(
    () => TermsRepository(getIt<TermsApiService>()),
  );
  getIt.registerFactory<TermsCubit>(() => TermsCubit(getIt<TermsRepository>()));

  // =========================
  // PROFILE
  // =========================

  getIt.registerLazySingleton<ProfileApiService>(
    () => ProfileApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AddressesApiService>(
    () => AddressesApiService(getIt<Dio>()), // ✅ بدون baseUrl
  );

  getIt.registerLazySingleton<AddressesRepository>(
    () => AddressesRepository(getIt<AddressesApiService>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(getIt<ProfileApiService>()),
  );

  getIt.registerFactory<AddressesCubit>(
    () => AddressesCubit(getIt<AddressesRepository>()),
  );

  /// ✅ مهم جداً للـ Splash preload
  getIt.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(getIt<ProfileRepository>()),
  );

  // =========================
  // CART
  // =========================
  getIt.registerLazySingleton<CartApiService>(
    () => CartApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepository(getIt<CartApiService>()),
  );

  /// ✅ مهم جداً للـ Splash preload
  getIt.registerLazySingleton<CartCubit>(
    () => CartCubit(getIt<CartRepository>()),
  );

  // =========================
  // ORDERS
  // =========================
  getIt.registerLazySingleton<OrdersApiService>(
    () => OrdersApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<OrdersRepository>(
    () => OrdersRepository(getIt<OrdersApiService>()),
  );

  getIt.registerFactory<OrderFlowCubit>(
    () => OrderFlowCubit(getIt<OrdersRepository>()),
  );
  getIt.registerFactory<OrdersTrackingCubit>(
    () => OrdersTrackingCubit(getIt<OrdersRepository>()),
  );
  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(getIt<OrdersRepository>()),
  );
  getIt.registerFactory<OrdersDetailsCubit>(
    () => OrdersDetailsCubit(getIt<OrdersRepository>()),
  );

  // =========================
  // SEARCH
  // =========================
  getIt.registerLazySingleton<SearchApiService>(
    () => SearchApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<SearchRepo>(
    () => SearchRepo(getIt<SearchApiService>()),
  );
  getIt.registerFactory<SearchCubit>(() => SearchCubit(getIt<SearchRepo>()));

  // =========================
  // NOTIFICATIONS
  // =========================
  getIt.registerLazySingleton<NotificationApiService>(
    () => NotificationApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(getIt<NotificationApiService>()),
  );
  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(getIt<NotificationRepository>()),
  );
}
