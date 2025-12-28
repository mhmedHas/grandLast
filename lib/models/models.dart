// في ملف models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PriceOffer {
  String? id;
  String companyId;
  String companyName;
  List<Transportation> transportations;
  DateTime createdAt;
  DateTime updatedAt;

  PriceOffer({
    this.id,
    required this.companyId,
    required this.companyName,
    required this.transportations,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'transportations': transportations.map((t) => t.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static PriceOffer fromMap(Map<String, dynamic> map, String id) {
    // معالجة البيانات بشكل آمن
    final companyId = map['companyId']?.toString() ?? '';
    final companyName = map['companyName']?.toString() ?? '';

    List<Transportation> transports = [];
    final transportsData = map['transportations'];
    if (transportsData is List) {
      transports = List<Transportation>.from(
        transportsData.map(
          (t) => Transportation.fromMap(t is Map<String, dynamic> ? t : {}),
        ),
      );
    }

    // معالجة التواريخ بشكل آمن
    DateTime createdAt;
    DateTime updatedAt;

    try {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } catch (e) {
      createdAt = DateTime.now();
    }

    try {
      updatedAt = (map['updatedAt'] as Timestamp).toDate();
    } catch (e) {
      updatedAt = DateTime.now();
    }

    return PriceOffer(
      id: id,
      companyId: companyId,
      companyName: companyName,
      transportations: transports,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class Transportation {
  String loadingLocation;
  String unloadingLocation;
  String vehicleType;
  double nolon;
  double companyOvernight; // المبيت للشركات
  double companyHoliday; // العطلة للشركات
  double wheelNolon; // النولون للعجل
  double wheelOvernight; // المبيت للعجل
  double wheelHoliday; // العطلة للعجل
  String? notes;

  Transportation({
    required this.loadingLocation,
    required this.unloadingLocation,
    required this.vehicleType,
    required this.nolon,
    required this.companyOvernight,
    required this.companyHoliday,
    required this.wheelNolon,
    required this.wheelOvernight,
    required this.wheelHoliday,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'loadingLocation': loadingLocation,
      'unloadingLocation': unloadingLocation,
      'vehicleType': vehicleType,
      'nolon': nolon,
      'companyOvernight': companyOvernight,
      'companyHoliday': companyHoliday,
      'wheelNolon': wheelNolon,
      'wheelOvernight': wheelOvernight,
      'wheelHoliday': wheelHoliday,
      'notes': notes,
    };
  }

  static Transportation fromMap(Map<String, dynamic> map) {
    return Transportation(
      loadingLocation: map['loadingLocation']?.toString() ?? '',
      unloadingLocation: map['unloadingLocation']?.toString() ?? '',
      vehicleType: map['vehicleType']?.toString() ?? '',
      nolon: _parseDouble(map['nolon']),
      companyOvernight: _parseDouble(map['companyOvernight']),
      companyHoliday: _parseDouble(map['companyHoliday']),
      wheelNolon: _parseDouble(map['wheelNolon']),
      wheelOvernight: _parseDouble(map['wheelOvernight']),
      wheelHoliday: _parseDouble(map['wheelHoliday']),
      notes: map['notes']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// class DailyWork {
//   String? id;

//   String companyId;
//   String companyName;
//   DateTime date;
//   String contractor; // المقاول (حقل جديد)
//   String tr; // TR (حقل جديد)
//   String driverName;
//   String loadingLocation;
//   String unloadingLocation;
//   String ohda;

//   String karta;
//   String selectedRoute;
//   double selectedPrice;
//   double wheelNolon; // نولون العجل
//   double wheelOvernight; // المبيت للعجل
//   double wheelHoliday; // العطلة للعجل
//   // إضافة الحقول الجديدة للشركة
//   double companyOvernight; // مبيت الشركة
//   double companyHoliday; // عطلة الشركة
//   double nolon; // نولون الشركة
//   String selectedVehicleType;
//   String selectedNotes;
//   String priceOfferId;
//   DateTime createdAt;
//   DateTime updatedAt;

//   DailyWork({
//     this.id,
//     required this.companyId,
//     required this.companyName,
//     required this.date,
//     required this.contractor, // المقاول (إضافة)
//     required this.tr, // TR (إضافة)
//     required this.driverName,
//     required this.loadingLocation,
//     required this.unloadingLocation,
//     required this.ohda,
//     required this.karta,
//     required this.selectedRoute,
//     required this.selectedPrice,
//     required this.wheelNolon,
//     this.wheelOvernight = 0.0,
//     this.wheelHoliday = 0.0,
//     // إضافة الحقول الجديدة مع قيم افتراضية
//     this.companyOvernight = 0.0, // مبيت الشركة
//     this.companyHoliday = 0.0, // عطلة الشركة
//     this.nolon = 0.0, // نولون الشركة
//     required this.selectedVehicleType,
//     required this.selectedNotes,
//     required this.priceOfferId,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'companyId': companyId,
//       'companyName': companyName,
//       'date': Timestamp.fromDate(date),
//       'contractor': contractor, // إضافة
//       'tr': tr, // إضافة
//       'driverName': driverName,
//       'loadingLocation': loadingLocation,
//       'unloadingLocation': unloadingLocation,
//       'ohda': ohda,
//       'karta': karta,
//       'selectedRoute': selectedRoute,
//       'selectedPrice': selectedPrice,
//       'wheelNolon': wheelNolon,
//       'wheelOvernight': wheelOvernight,
//       'wheelHoliday': wheelHoliday,
//       // إضافة الحقول الجديدة
//       'companyOvernight': companyOvernight, // مبيت الشركة
//       'companyHoliday': companyHoliday, // عطلة الشركة
//       'nolon': nolon, // نولون الشركة
//       'selectedVehicleType': selectedVehicleType,
//       'selectedNotes': selectedNotes,
//       'priceOfferId': priceOfferId,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'updatedAt': Timestamp.fromDate(updatedAt),
//     };
//   }

//   static DailyWork fromMap(Map<String, dynamic> map, String id) {
//     return DailyWork(
//       id: id,
//       companyId: map['companyId']?.toString() ?? '',
//       companyName: map['companyName']?.toString() ?? '',
//       date: (map['date'] as Timestamp).toDate(),
//       contractor: map['contractor']?.toString() ?? '', // إضافة
//       tr: map['tr']?.toString() ?? '', // إضافة
//       driverName: map['driverName']?.toString() ?? '',
//       loadingLocation: map['loadingLocation']?.toString() ?? '',
//       unloadingLocation: map['unloadingLocation']?.toString() ?? '',
//       ohda: map['ohda']?.toString() ?? '',
//       karta: map['karta']?.toString() ?? '',
//       selectedRoute: map['selectedRoute']?.toString() ?? '',
//       selectedPrice: (map['selectedPrice'] ?? 0).toDouble(),
//       wheelNolon: (map['wheelNolon'] ?? 0).toDouble(),
//       wheelOvernight: (map['wheelOvernight'] ?? 0).toDouble(),
//       wheelHoliday: (map['wheelHoliday'] ?? 0).toDouble(),
//       // قراءة الحقول الجديدة
//       companyOvernight: (map['companyOvernight'] ?? 0)
//           .toDouble(), // مبيت الشركة
//       companyHoliday: (map['companyHoliday'] ?? 0).toDouble(), // عطلة الشركة
//       nolon: (map['nolon'] ?? 0).toDouble(), // نولون الشركة
//       selectedVehicleType: map['selectedVehicleType']?.toString() ?? '',
//       selectedNotes: map['selectedNotes']?.toString() ?? '',
//       priceOfferId: map['priceOfferId']?.toString() ?? '',
//       createdAt: (map['createdAt'] as Timestamp).toDate(),
//       updatedAt: (map['updatedAt'] as Timestamp).toDate(),
//     );
//   }
// }

class DailyWork {
  String? id;

  String companyId;
  String companyName;
  DateTime date;
  String contractor; // المقاول (حقل جديد)
  String tr; // TR (حقل جديد)
  String driverName;
  String loadingLocation;
  String unloadingLocation;
  String ohda;
  String karta;
  String selectedRoute;
  double selectedPrice;
  double wheelNolon; // نولون العجل
  double wheelOvernight; // المبيت للعجل
  double wheelHoliday; // العطلة للعجل
  // إضافة الحقول الجديدة للشركة
  double companyOvernight; // مبيت الشركة
  double companyHoliday; // عطلة الشركة
  double nolon; // نولون الشركة
  String selectedVehicleType;
  String selectedNotes;
  String priceOfferId;
  DateTime createdAt;
  DateTime updatedAt;

  // الحقول الجديدة لموقع الشركة
  String? companyLocationId; // معرف موقع الشركة
  String companyLocationName; // اسم موقع الشركة
  String companyLocationAddress; // عنوان موقع الشركة
  String? companyLocationPhone; // هاتف موقع الشركة
  String? companyLocationManager; // مدير موقع الشركة

  DailyWork({
    this.id,
    required this.companyId,
    required this.companyName,
    required this.date,
    required this.contractor, // المقاول (إضافة)
    required this.tr, // TR (إضافة)
    required this.driverName,
    required this.loadingLocation,
    required this.unloadingLocation,
    required this.ohda,
    required this.karta,
    required this.selectedRoute,
    required this.selectedPrice,
    required this.wheelNolon,
    this.wheelOvernight = 0.0,
    this.wheelHoliday = 0.0,
    // إضافة الحقول الجديدة مع قيم افتراضية
    this.companyOvernight = 0.0, // مبيت الشركة
    this.companyHoliday = 0.0, // عطلة الشركة
    this.nolon = 0.0, // نولون الشركة
    required this.selectedVehicleType,
    required this.selectedNotes,
    required this.priceOfferId,
    required this.createdAt,
    required this.updatedAt,

    // الحقول الجديدة لموقع الشركة مع قيم افتراضية
    this.companyLocationId,
    this.companyLocationName = '',
    this.companyLocationAddress = '',
    this.companyLocationPhone,
    this.companyLocationManager,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'date': Timestamp.fromDate(date),
      'contractor': contractor, // إضافة
      'tr': tr, // إضافة
      'driverName': driverName,
      'loadingLocation': loadingLocation,
      'unloadingLocation': unloadingLocation,
      'ohda': ohda,
      'karta': karta,
      'selectedRoute': selectedRoute,
      'selectedPrice': selectedPrice,
      'wheelNolon': wheelNolon,
      'wheelOvernight': wheelOvernight,
      'wheelHoliday': wheelHoliday,
      // إضافة الحقول الجديدة
      'companyOvernight': companyOvernight, // مبيت الشركة
      'companyHoliday': companyHoliday, // عطلة الشركة
      'nolon': nolon, // نولون الشركة
      'selectedVehicleType': selectedVehicleType,
      'selectedNotes': selectedNotes,
      'priceOfferId': priceOfferId,

      // الحقول الجديدة لموقع الشركة
      'companyLocationId': companyLocationId,
      'companyLocationName': companyLocationName,
      'companyLocationAddress': companyLocationAddress,
      'companyLocationPhone': companyLocationPhone,
      'companyLocationManager': companyLocationManager,

      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DailyWork fromMap(Map<String, dynamic> map, String id) {
    return DailyWork(
      id: id,
      companyId: map['companyId']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
      date: (map['date'] as Timestamp).toDate(),
      contractor: map['contractor']?.toString() ?? '', // إضافة
      tr: map['tr']?.toString() ?? '', // إضافة
      driverName: map['driverName']?.toString() ?? '',
      loadingLocation: map['loadingLocation']?.toString() ?? '',
      unloadingLocation: map['unloadingLocation']?.toString() ?? '',
      ohda: map['ohda']?.toString() ?? '',
      karta: map['karta']?.toString() ?? '',
      selectedRoute: map['selectedRoute']?.toString() ?? '',
      selectedPrice: (map['selectedPrice'] ?? 0).toDouble(),
      wheelNolon: (map['wheelNolon'] ?? 0).toDouble(),
      wheelOvernight: (map['wheelOvernight'] ?? 0).toDouble(),
      wheelHoliday: (map['wheelHoliday'] ?? 0).toDouble(),
      // قراءة الحقول الجديدة
      companyOvernight: (map['companyOvernight'] ?? 0)
          .toDouble(), // مبيت الشركة
      companyHoliday: (map['companyHoliday'] ?? 0).toDouble(), // عطلة الشركة
      nolon: (map['nolon'] ?? 0).toDouble(), // نولون الشركة
      selectedVehicleType: map['selectedVehicleType']?.toString() ?? '',
      selectedNotes: map['selectedNotes']?.toString() ?? '',
      priceOfferId: map['priceOfferId']?.toString() ?? '',

      // قراءة الحقول الجديدة لموقع الشركة
      companyLocationId: map['companyLocationId']?.toString(),
      companyLocationName: map['companyLocationName']?.toString() ?? '',
      companyLocationAddress: map['companyLocationAddress']?.toString() ?? '',
      companyLocationPhone: map['companyLocationPhone']?.toString(),
      companyLocationManager: map['companyLocationManager']?.toString(),

      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // // دالة مساعدة لعرض معلومات موقع الشركة
  // String get companyLocationInfo {
  //   if (companyLocationName.isEmpty) return '';

  //   String info = companyLocationName;
  //   if (companyLocationAddress.isNotEmpty) {
  //     info += '\nالعنوان: $companyLocationAddress';
  //   }
  //   if (companyLocationManager != null && companyLocationManager!.isNotEmpty) {
  //     info += '\nالمدير: $companyLocationManager';
  //   }
  //   if (companyLocationPhone != null && companyLocationPhone!.isNotEmpty) {
  //     info += '\nالهاتف: $companyLocationPhone';
  //   }
  //   return info;
  // }

  // // دالة للتحقق إذا كان هناك موقع شركة محدد
  // bool get hasCompanyLocation {
  //   return companyLocationName.isNotEmpty && companyLocationId != null;
  // }
}

// في ملف models.dart أضف هذا
class DateFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String companyId;

  DateFilter({this.startDate, this.endDate, this.companyId = ''});
}

// models/employee_model.dart
class Employee {
  String id;
  String name;
  String phone;
  String position;
  double salary;
  double totalPenalties;
  DateTime joinDate;

  Employee({
    required this.id,
    required this.name,
    required this.phone,
    required this.position,
    required this.salary,
    this.totalPenalties = 0.0,
    required this.joinDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'position': position,
      'salary': salary,
      'totalPenalties': totalPenalties,
      'joinDate': joinDate.toIso8601String(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map, String id) {
    return Employee(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      position: map['position'] ?? '',
      salary: (map['salary'] ?? 0).toDouble(),
      totalPenalties: (map['totalPenalties'] ?? 0).toDouble(),
      joinDate: DateTime.parse(
        map['joinDate'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class Penalty {
  String id;
  String employeeId;
  String employeeName;
  double amount;
  String reason;
  DateTime date;

  Penalty({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.amount,
    required this.reason,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'amount': amount,
      'reason': reason,
      'date': date.toIso8601String(),
    };
  }

  factory Penalty.fromMap(Map<String, dynamic> map, String id) {
    return Penalty(
      id: id,
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      reason: map['reason'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
