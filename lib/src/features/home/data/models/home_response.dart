import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Response model for Home API:
/// GET /api/v1/web/home?offset=1&limit=10&lat=...&lng=...
class HomeResponse extends Equatable {
  final int status;
  final String message;
  final HomeDataModel? data;

  const HomeResponse({
    this.status = 0,
    this.message = '',
    this.data,
  });

  factory HomeResponse.fromRawJson(String str) =>
      HomeResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory HomeResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HomeResponse();
    return HomeResponse(
      status: (json['status'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? HomeDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };

  @override
  List<Object?> get props => [status, message, data];
}

class HomeDataModel extends Equatable {
  final MainCategoriesWrapper? mainCategories;
  final HomeSectionsWrapper? homeSections;

  const HomeDataModel({
    this.mainCategories,
    this.homeSections,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HomeDataModel();
    return HomeDataModel(
      mainCategories: json['main_categories'] != null &&
              json['main_categories'] is Map<String, dynamic>
          ? MainCategoriesWrapper.fromJson(
              json['main_categories'] as Map<String, dynamic>)
          : null,
      homeSections: json['home_sections'] != null &&
              json['home_sections'] is Map<String, dynamic>
          ? HomeSectionsWrapper.fromJson(
              json['home_sections'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'main_categories': mainCategories?.toJson(),
        'home_sections': homeSections?.toJson(),
      };

  @override
  List<Object?> get props => [mainCategories, homeSections];
}

class MainCategoriesWrapper extends Equatable {
  final int totalRecords;
  final List<MainCategoryModel> items;

  const MainCategoriesWrapper({
    this.totalRecords = 0,
    this.items = const [],
  });

  factory MainCategoriesWrapper.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MainCategoriesWrapper();
    return MainCategoriesWrapper(
      totalRecords: (json['total_records'] as num?)?.toInt() ?? 0,
      items: json['items'] != null && json['items'] is List
          ? (json['items'] as List)
              .map((e) => MainCategoryModel.fromJson(e as Map<String, dynamic>?))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_records': totalRecords,
        'items': items.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [totalRecords, items];
}

class MainCategoryModel extends Equatable {
  final int id;
  final String publicId;
  final String mainCategoryName;
  final String? mainCategoryImage;
  final String slug;
  final String shortDescription;
  final bool isActive;
  final bool isUpdate;
  final String? createdAt;
  final String? updatedAt;

  const MainCategoryModel({
    this.id = 0,
    this.publicId = '',
    this.mainCategoryName = '',
    this.mainCategoryImage,
    this.slug = '',
    this.shortDescription = '',
    this.isActive = true,
    this.isUpdate = false,
    this.createdAt,
    this.updatedAt,
  });

  factory MainCategoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MainCategoryModel();
    return MainCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      publicId: json['public_id']?.toString() ?? '',
      mainCategoryName: json['main_category_name']?.toString() ?? '',
      mainCategoryImage: json['main_category_image']?.toString(),
      slug: json['slug']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      isUpdate: json['is_update'] as bool? ?? false,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'public_id': publicId,
        'main_category_name': mainCategoryName,
        'main_category_image': mainCategoryImage,
        'slug': slug,
        'short_description': shortDescription,
        'is_active': isActive,
        'is_update': isUpdate,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  @override
  List<Object?> get props => [
        id,
        publicId,
        mainCategoryName,
        mainCategoryImage,
        slug,
        shortDescription,
        isActive,
        isUpdate,
      ];
}

class HomeSectionsWrapper extends Equatable {
  final int totalRecords;
  final List<HomeSectionModel> items;

  const HomeSectionsWrapper({
    this.totalRecords = 0,
    this.items = const [],
  });

  factory HomeSectionsWrapper.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HomeSectionsWrapper();
    return HomeSectionsWrapper(
      totalRecords: (json['total_records'] as num?)?.toInt() ?? 0,
      items: json['items'] != null && json['items'] is List
          ? (json['items'] as List)
              .map((e) => HomeSectionModel.fromJson(e as Map<String, dynamic>?))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_records': totalRecords,
        'items': items.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [totalRecords, items];
}

class HomeSectionModel extends Equatable {
  final int id;
  final String publicId;
  final String slug;
  final String title;
  final String sectionType;
  final String? description;
  final int priority;
  final List<HomeCategoryItemModel> categories;
  final List<HomeProductItemModel> products;
  final List<HomeBannerItemModel> banners;

  const HomeSectionModel({
    this.id = 0,
    this.publicId = '',
    this.slug = '',
    this.title = '',
    this.sectionType = '',
    this.description,
    this.priority = 999,
    this.categories = const [],
    this.products = const [],
    this.banners = const [],
  });

  factory HomeSectionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HomeSectionModel();

    // Parse categories safely
    List<HomeCategoryItemModel> cats = [];
    if (json['categories'] != null && json['categories'] is List) {
      cats = (json['categories'] as List)
          .map((e) => HomeCategoryItemModel.fromJson(e as Map<String, dynamic>?))
          .toList();
    }

    // Parse products safely
    List<HomeProductItemModel> prods = [];
    if (json['products'] != null && json['products'] is List) {
      prods = (json['products'] as List)
          .map((e) => HomeProductItemModel.fromJson(e as Map<String, dynamic>?))
          .toList();
    }

    // Parse banners or banner items safely
    List<HomeBannerItemModel> bans = [];
    if (json['banners'] != null && json['banners'] is List) {
      bans = (json['banners'] as List)
          .map((e) => HomeBannerItemModel.fromJson(e as Map<String, dynamic>?))
          .toList();
    } else if (json['items'] != null && json['items'] is List) {
      bans = (json['items'] as List)
          .map((e) => HomeBannerItemModel.fromJson(e as Map<String, dynamic>?))
          .toList();
    }

    return HomeSectionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      publicId: json['public_id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      sectionType: json['section_type']?.toString().toLowerCase().trim() ?? '',
      description: json['description']?.toString(),
      priority: (json['priority'] as num?)?.toInt() ?? 999,
      categories: cats,
      products: prods,
      banners: bans,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'public_id': publicId,
        'slug': slug,
        'title': title,
        'section_type': sectionType,
        'description': description,
        'priority': priority,
        'categories': categories.map((e) => e.toJson()).toList(),
        'products': products.map((e) => e.toJson()).toList(),
        'banners': banners.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        id,
        publicId,
        slug,
        title,
        sectionType,
        description,
        priority,
        categories,
        products,
        banners,
      ];
}

class HomeCategoryItemModel extends Equatable {
  final int id;
  final String publicId;
  final String categoryName;
  final String slug;
  final String? categoryImage;
  final bool isActive;

  const HomeCategoryItemModel({
    this.id = 0,
    this.publicId = '',
    this.categoryName = '',
    this.slug = '',
    this.categoryImage,
    this.isActive = true,
  });

  factory HomeCategoryItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HomeCategoryItemModel();
    return HomeCategoryItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      publicId: json['public_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      categoryImage: json['category_image']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'public_id': publicId,
        'category_name': categoryName,
        'slug': slug,
        'category_image': categoryImage,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [
        id,
        publicId,
        categoryName,
        slug,
        categoryImage,
        isActive,
      ];
}

class HomeProductItemModel extends Equatable {
  final int id;
  final String publicId;
  final String productName;
  final String productShortName;
  final String slug;
  final String shortDescription;
  final String? productImage;
  final bool isActive;
  final List<ProductVariantModel> variants;
  final List<String> images;
  final List<dynamic> tags;

  const HomeProductItemModel({
    this.id = 0,
    this.publicId = '',
    this.productName = '',
    this.productShortName = '',
    this.slug = '',
    this.shortDescription = '',
    this.productImage,
    this.isActive = true,
    this.variants = const [],
    this.images = const [],
    this.tags = const [],
  });

  ProductVariantModel? get firstVariant =>
      variants.isNotEmpty ? variants.first : null;

  factory HomeProductItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HomeProductItemModel();

    List<ProductVariantModel> vars = [];
    if (json['variants'] != null && json['variants'] is List) {
      vars = (json['variants'] as List)
          .map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>?))
          .toList();
    }

    List<String> imgs = [];
    if (json['images'] != null && json['images'] is List) {
      imgs = (json['images'] as List).map((e) => e.toString()).toList();
    }

    return HomeProductItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      publicId: json['public_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productShortName: json['product_short_name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      productImage: json['product_image']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      variants: vars,
      images: imgs,
      tags: json['tags'] != null && json['tags'] is List ? json['tags'] as List : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'public_id': publicId,
        'product_name': productName,
        'product_short_name': productShortName,
        'slug': slug,
        'short_description': shortDescription,
        'product_image': productImage,
        'is_active': isActive,
        'variants': variants.map((e) => e.toJson()).toList(),
        'images': images,
        'tags': tags,
      };

  @override
  List<Object?> get props => [
        id,
        publicId,
        productName,
        productShortName,
        slug,
        shortDescription,
        productImage,
        isActive,
        variants,
        images,
        tags,
      ];
}

class ProductVariantModel extends Equatable {
  final int id;
  final String publicId;
  final num actualPrice;
  final num sellingPrice;
  final num quantity;
  final String zoneName;
  final String subUomName;
  final String subUomShortName;
  final num conversionFactor;
  final String uomName;
  final String uomShortName;
  final bool isDeliverable;
  final bool isActive;

  const ProductVariantModel({
    this.id = 0,
    this.publicId = '',
    this.actualPrice = 0,
    this.sellingPrice = 0,
    this.quantity = 0,
    this.zoneName = '',
    this.subUomName = '',
    this.subUomShortName = '',
    this.conversionFactor = 1,
    this.uomName = '',
    this.uomShortName = '',
    this.isDeliverable = true,
    this.isActive = true,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProductVariantModel();
    return ProductVariantModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      publicId: json['public_id']?.toString() ?? '',
      actualPrice: (json['actual_price'] as num?) ?? 0,
      sellingPrice: (json['selling_price'] as num?) ?? 0,
      quantity: (json['quantity'] as num?) ?? 0,
      zoneName: json['zone_name']?.toString() ?? '',
      subUomName: json['sub_uom_name']?.toString() ?? '',
      subUomShortName: json['sub_uom_short_name']?.toString() ?? '',
      conversionFactor: (json['conversion_factor'] as num?) ?? 1,
      uomName: json['uom_name']?.toString() ?? '',
      uomShortName: json['uom_short_name']?.toString() ?? '',
      isDeliverable: json['is_deliverable'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'public_id': publicId,
        'actual_price': actualPrice,
        'selling_price': sellingPrice,
        'quantity': quantity,
        'zone_name': zoneName,
        'sub_uom_name': subUomName,
        'sub_uom_short_name': subUomShortName,
        'conversion_factor': conversionFactor,
        'uom_name': uomName,
        'uom_short_name': uomShortName,
        'is_deliverable': isDeliverable,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [
        id,
        publicId,
        actualPrice,
        sellingPrice,
        quantity,
        zoneName,
        subUomName,
        subUomShortName,
        conversionFactor,
        uomName,
        uomShortName,
        isDeliverable,
        isActive,
      ];
}

class HomeBannerItemModel extends Equatable {
  final int id;
  final String publicId;
  final String? image;
  final String? title;
  final String? link;

  const HomeBannerItemModel({
    this.id = 0,
    this.publicId = '',
    this.image,
    this.title,
    this.link,
  });

  factory HomeBannerItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HomeBannerItemModel();
    final img = json['image']?.toString() ??
        json['banner_image']?.toString() ??
        json['url']?.toString() ??
        json['media_url']?.toString();

    return HomeBannerItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      publicId: json['public_id']?.toString() ?? '',
      image: img,
      title: json['title']?.toString(),
      link: json['link']?.toString() ?? json['url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'public_id': publicId,
        'image': image,
        'title': title,
        'link': link,
      };

  @override
  List<Object?> get props => [id, publicId, image, title, link];
}
