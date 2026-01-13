// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:last/main.dart';

// // import 'package:intl/intl.dart';
// // import 'package:intl/date_symbol_data_local.dart'; // استيراد تهيئة الـ locale

// // class Splash extends StatefulWidget {
// //   const Splash({super.key});

// //   @override
// //   State<Splash> createState() => _SplashScreenState();
// // }

// // class _SplashScreenState extends State<Splash>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _fadeController;
// //   late Animation<double> _fadeAnimation;
// //   late Timer _timer;
// //   String _formattedTime = '';
// //   String _formattedDate = '';
// //   String _greeting = '';
// //   @override
// //   void initState() {
// //     super.initState();

// //     // انيميشن الظهور
// //     _fadeController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(seconds: 2),
// //     );
// //     _fadeAnimation = CurvedAnimation(
// //       parent: _fadeController,
// //       curve: Curves.easeIn,
// //     );
// //     _fadeController.forward();

// //     // تهيئة اللغة العربية قبل استخدام DateFormat
// //     initializeDateFormatting('ar', null).then((_) {
// //       _updateDateTime();

// //       // التايمر لتغيير الصفحة
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         Future.delayed(const Duration(seconds: 3), () {
// //           Navigator.pushReplacement(
// //             context,
// //             // MaterialPageRoute(builder: (_) => MainDashboard()),
// //             MaterialPageRoute(builder: (_) => CheckAccessPage()),
// //           );
// //         });
// //       });

// //       // تحديث الوقت باستمرار
// //       _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //         _updateDateTime();
// //       });
// //     });
// //   }

// //   void _updateDateTime() {
// //     final now = DateTime.now();
// //     final formatterTime = DateFormat('hh:mm a', 'ar');
// //     final formatterDate = DateFormat('EEEE، d MMMM yyyy', 'ar');
// //     final hour = now.hour;

// //     setState(() {
// //       _formattedTime = formatterTime.format(now);
// //       _formattedDate = formatterDate.format(now);
// //       _greeting = hour < 12 ? 'صباح الخير' : 'مساء النور';
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _fadeController.dispose();
// //     _timer.cancel();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xfff2f7fc),
// //       body: FadeTransition(
// //         opacity: _fadeAnimation,
// //         child: Stack(
// //           children: [
// //             Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   // أيقونة شاحنة
// //                   const Icon(
// //                     Icons.local_shipping,
// //                     size: 100,
// //                     color: Color.fromARGB(255, 1, 47, 107),
// //                   ),
// //                   const SizedBox(height: 20),

// //                   // اسم الشركة
// //                   const Text(
// //                     'نيو جراند ',
// //                     style: TextStyle(
// //                       fontSize: 34,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xff1877F2),
// //                       fontFamily: 'Amiri',
// //                     ),
// //                   ),
// //                   const SizedBox(height: 6),
// //                   const Text(
// //                     'نظام إدارة السيارات و السائقين',
// //                     style: TextStyle(
// //                       fontSize: 25,
// //                       fontWeight: FontWeight.w500,
// //                       color: Colors.black,
// //                       fontFamily: 'Amiri',
// //                     ),
// //                   ),

// //                   const SizedBox(height: 30),

// //                   // تحية حسب الوقت
// //                   Text(
// //                     _greeting,
// //                     style: TextStyle(
// //                       fontSize: 20,
// //                       color: Colors.grey[700],
// //                       fontFamily: 'Amiri',
// //                     ),
// //                   ),

// //                   const SizedBox(height: 8),

// //                   // الوقت والتاريخ
// //                   Text(
// //                     _formattedTime,
// //                     style: const TextStyle(
// //                       fontSize: 26,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.black,
// //                       fontFamily: 'Amiri',
// //                     ),
// //                   ),
// //                   Text(
// //                     _formattedDate,
// //                     style: const TextStyle(
// //                       fontSize: 18,
// //                       color: Colors.black87,
// //                       fontFamily: 'Amiri',
// //                     ),
// //                   ),

// //                   const SizedBox(height: 30),

// //                   // دائرة التحميل
// //                   const CircularProgressIndicator(
// //                     valueColor: AlwaysStoppedAnimation<Color>(
// //                       Color(0xff1877F2),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             // التوقيع في الأسفل
// //             Positioned(
// //               bottom: 15,
// //               left: 0,
// //               right: 0,
// //               child: Column(
// //                 children: [
// //                   Text(
// //                     'CodeCrafter21',
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.w900,
// //                       color: Color(0xff1877F2),
// //                       fontFamily: 'Amiri',
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     '+201557069620',
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.indigo[900],
// //                       fontFamily: 'Amiri',
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class CheckAccessPage extends StatefulWidget {
// //   const CheckAccessPage({Key? key}) : super(key: key);

// //   @override
// //   State<CheckAccessPage> createState() => _CheckAccessPageState();
// // }

// // class _CheckAccessPageState extends State<CheckAccessPage>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _fadeController;
// //   late Animation<double> _fadeAnimation;
// //   bool _showError = false; // لو المستحقات مش مدفوعة

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fadeController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(seconds: 2),
// //     );
// //     _fadeAnimation = CurvedAnimation(
// //       parent: _fadeController,
// //       curve: Curves.easeIn,
// //     );
// //     _fadeController.forward();

// //     checkValue();
// //   }

// //   Future<void> checkValue() async {
// //     try {
// //       final query = await FirebaseFirestore.instance
// //           .collection('grand')
// //           .limit(1)
// //           .get();

// //       if (query.docs.isEmpty) throw 'No documents found in grand collection';

// //       int value = (query.docs.first.get('value') as num).toInt();

// //       if (value == 1) {
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (_) => MainDashboard()),
// //         );
// //       } else {
// //         // لو المستحقات مش مدفوعة
// //         setState(() {
// //           _showError = true;
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _showError = true;
// //       });
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _fadeController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xfff2f7fc),
// //       body: FadeTransition(
// //         opacity: _fadeAnimation,
// //         child: Stack(
// //           children: [
// //             Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   const Icon(
// //                     Icons.local_shipping,
// //                     size: 100,
// //                     color: Color.fromARGB(255, 1, 47, 107),
// //                   ),
// //                   const SizedBox(height: 20),
// //                   const Text(
// //                     'نيو جراند',
// //                     style: TextStyle(
// //                       fontSize: 34,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xff1877F2),
// //                       fontFamily: 'Amiri',
// //                     ),
// //                   ),
// //                   const SizedBox(height: 6),
// //                   const Text(
// //                     'نظام إدارة السيارات و السائقين',
// //                     style: TextStyle(
// //                       fontSize: 25,
// //                       fontWeight: FontWeight.w500,
// //                       color: Colors.black,
// //                       fontFamily: 'Amiri',
// //                     ),
// //                   ),
// //                   const SizedBox(height: 30),

// //                   // لو فيه خطأ أو المستحقات غير مدفوعة
// //                   _showError
// //                       ? Container(
// //                           padding: const EdgeInsets.all(20),
// //                           decoration: BoxDecoration(
// //                             color: Colors.red[50],
// //                             borderRadius: BorderRadius.circular(15),
// //                           ),
// //                           child: const Text(
// //                             'يرجى دفع المستحقات',
// //                             style: TextStyle(
// //                               fontSize: 22,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.red,
// //                               fontFamily: 'Amiri',
// //                             ),
// //                             textAlign: TextAlign.center,
// //                           ),
// //                         )
// //                       : const CircularProgressIndicator(
// //                           valueColor: AlwaysStoppedAnimation<Color>(
// //                             Color(0xff1877F2),
// //                           ),
// //                         ),
// //                 ],
// //               ),
// //             ),
// //             Positioned(
// //               bottom: 15,
// //               left: 0,
// //               right: 0,
// //               child: Column(
// //                 children: const [
// //                   Text(
// //                     'CodeCrafter21',
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.w900,
// //                       color: Color(0xff1877F2),
// //                       fontFamily: 'Amiri',
// //                     ),
// //                   ),
// //                   SizedBox(height: 4),
// //                   Text(
// //                     '+201557069620',
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.indigo,
// //                       fontFamily: 'Amiri',
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:last/main.dart';
// import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart';

// class Splash extends StatefulWidget {
//   const Splash({super.key});

//   @override
//   State<Splash> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<Splash>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   late Timer _timer;
//   String _formattedTime = '';
//   String _formattedDate = '';
//   String _greeting = '';
//   late Animation<double> _scaleAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // تهيئة الانيميشنات
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOutCubic,
//     );

//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _fadeController,
//         curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
//       ),
//     );

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//           CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
//         );

//     // تهيئة اللغة العربية قبل استخدام DateFormat
//     initializeDateFormatting('ar', null).then((_) {
//       _updateDateTime();
//       _fadeController.forward();

//       // التايمر لتغيير الصفحة
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Future.delayed(const Duration(seconds: 3), () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => CheckAccessPage()),
//           );
//         });
//       });

//       // تحديث الوقت باستمرار
//       _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         _updateDateTime();
//       });
//     });
//   }

//   void _updateDateTime() {
//     final now = DateTime.now();
//     final formatterTime = DateFormat('hh:mm a', 'ar');
//     final formatterDate = DateFormat('EEEE، d MMMM yyyy', 'ar');
//     final hour = now.hour;

//     String greeting;
//     if (hour < 12) {
//       greeting = '🌅 صباح الخير 🌅';
//     } else if (hour < 17) {
//       greeting = '☀️ مساء الخير ☀️';
//     } else {
//       greeting = '🌙 مساء النور 🌙';
//     }

//     setState(() {
//       _formattedTime = formatterTime.format(now);
//       _formattedDate = formatterDate.format(now);
//       _greeting = greeting;
//     });
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A),
//       body: Stack(
//         children: [
//           // خلفية متدرجة
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   const Color(0xFF0F172A),
//                   const Color(0xFF1E293B),
//                   const Color(0xFF334155),
//                 ],
//                 stops: const [0.0, 0.6, 1.0],
//               ),
//             ),
//           ),

//           // نماذج هندسية خلفية
//           Positioned(
//             top: -100,
//             right: -100,
//             child: Container(
//               width: 300,
//               height: 300,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: RadialGradient(
//                   colors: [
//                     const Color(0xFF3B82F6).withOpacity(0.1),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // انيميشن FadeTransition للمحتوى
//           FadeTransition(
//             opacity: _fadeAnimation,
//             child: Center(
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: ScaleTransition(
//                   scale: _scaleAnimation,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // أيقونة مع تأثير
//                       Container(
//                         width: 140,
//                         height: 140,
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color(0xFF3B82F6).withOpacity(0.5),
//                               blurRadius: 30,
//                               spreadRadius: 5,
//                             ),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.local_shipping_outlined,
//                           size: 70,
//                           color: Colors.white,
//                         ),
//                       ),

//                       const SizedBox(height: 30),

//                       // اسم الشركة مع تأثير
//                       ShaderMask(
//                         shaderCallback: (bounds) => const LinearGradient(
//                           colors: [Color(0xFF60A5FA), Color(0xFF8B5CF6)],
//                         ).createShader(bounds),
//                         child: const Text(
//                           'نيو جراند',
//                           style: TextStyle(
//                             fontSize: 48,
//                             fontWeight: FontWeight.w900,
//                             fontFamily: 'Cairo',
//                             shadows: [
//                               Shadow(
//                                 blurRadius: 10,
//                                 color: Colors.black26,
//                                 offset: Offset(2, 2),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       // وصف النظام
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 32,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.05),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.1),
//                           ),
//                         ),
//                         child: const Text(
//                           'نظام إدارة السيارات و السائقين',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.white70,
//                             fontFamily: 'Cairo',
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 40),

//                       // تحية مع تأثيرات
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               const Color(0xFF3B82F6).withOpacity(0.2),
//                               const Color(0xFF8B5CF6).withOpacity(0.2),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         child: Text(
//                           _greeting,
//                           style: const TextStyle(
//                             fontSize: 22,
//                             color: Colors.white,
//                             fontFamily: 'Cairo',
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 25),

//                       // الوقت مع تصميم عصري
//                       Container(
//                         width: 200,
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.05),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.1),
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.2),
//                               blurRadius: 15,
//                               offset: const Offset(0, 5),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.access_time_filled,
//                                   color: Color(0xFF60A5FA),
//                                   size: 24,
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Text(
//                                   _formattedTime,
//                                   style: const TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                     fontFamily: 'Cairo',
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               _formattedDate,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.white.withOpacity(0.8),
//                                 fontFamily: 'Cairo',
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 40),

//                       // دائرة التحميل مع تدرج
//                       SizedBox(
//                         width: 60,
//                         height: 60,
//                         child: Stack(
//                           children: [
//                             // خلفية الدائرة
//                             Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: const LinearGradient(
//                                   colors: [
//                                     Color(0xFF3B82F6),
//                                     Color(0xFF8B5CF6),
//                                   ],
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: const Color(
//                                       0xFF3B82F6,
//                                     ).withOpacity(0.3),
//                                     blurRadius: 10,
//                                     spreadRadius: 2,
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // مؤشر التحميل
//                             const Center(
//                               child: SizedBox(
//                                 width: 25,
//                                 height: 25,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 3,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // التوقيع في الأسفل
//           Positioned(
//             bottom: 30,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 // خط فاصل
//                 Container(
//                   width: 150,
//                   height: 2,
//                   margin: const EdgeInsets.only(bottom: 20),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Colors.transparent,
//                         Color(0xFF60A5FA),
//                         Colors.transparent,
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),

//                 // معلومات المطور
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 30,
//                     vertical: 15,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: Colors.white.withOpacity(0.1)),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.code_rounded,
//                             color: const Color(0xFF60A5FA),
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           ShaderMask(
//                             shaderCallback: (bounds) => const LinearGradient(
//                               colors: [Color(0xFF60A5FA), Color(0xFF8B5CF6)],
//                             ).createShader(bounds),
//                             child: const Text(
//                               'CodeCrafter21',
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w800,
//                                 fontFamily: 'Cairo',
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.phone_android_rounded,
//                             color: const Color(0xFF10B981),
//                             size: 18,
//                           ),
//                           const SizedBox(width: 8),
//                           const Text(
//                             '+201557069620',
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.white70,
//                               fontFamily: 'Cairo',
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CheckAccessPage extends StatefulWidget {
//   const CheckAccessPage({Key? key}) : super(key: key);

//   @override
//   State<CheckAccessPage> createState() => _CheckAccessPageState();
// }

// class _CheckAccessPageState extends State<CheckAccessPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _pulseAnimation;
//   bool _showError = false;
//   bool _isLoading = true;
//   late Timer _loadingTimer;

//   @override
//   void initState() {
//     super.initState();

//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOutCubic,
//     );

//     _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );

//     _fadeController.forward();

//     // محاكاة وقت التحميل
//     _loadingTimer = Timer(const Duration(milliseconds: 1200), () {
//       checkValue();
//     });
//   }

//   Future<void> checkValue() async {
//     try {
//       final query = await FirebaseFirestore.instance
//           .collection('grand')
//           .limit(1)
//           .get();

//       if (query.docs.isEmpty) throw 'لم يتم العثور على مستندات في المجموعة';

//       int value = (query.docs.first.get('value') as num).toInt();

//       if (value == 1) {
//         Navigator.pushReplacement(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (_, __, ___) => MainDashboard(),
//             transitionDuration: const Duration(milliseconds: 1000),
//             transitionsBuilder: (_, animation, __, child) {
//               return FadeTransition(opacity: animation, child: child);
//             },
//           ),
//         );
//       } else {
//         setState(() {
//           _isLoading = false;
//           _showError = true;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _showError = true;
//       });

//       // إشعار خطأ أنيق
//       Future.delayed(const Duration(milliseconds: 300), () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'خطأ في الاتصال: ${e.toString()}',
//                     style: const TextStyle(
//                       fontFamily: 'Cairo',
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: const Color(0xFFEF4444),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//         );
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _loadingTimer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A),
//       body: Stack(
//         children: [
//           // خلفية متدرجة
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   const Color(0xFF0F172A),
//                   const Color(0xFF1E293B),
//                   const Color(0xFF334155),
//                 ],
//                 stops: const [0.0, 0.6, 1.0],
//               ),
//             ),
//           ),

//           // نماذج هندسية خلفية
//           Positioned(
//             top: -50,
//             left: -50,
//             child: Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: RadialGradient(
//                   colors: [
//                     const Color(0xFF10B981).withOpacity(0.1),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           FadeTransition(
//             opacity: _fadeAnimation,
//             child: Center(
//               child: ScaleTransition(
//                 scale: _pulseAnimation,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // أيقونة التحقق
//                     Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: _showError
//                               ? [
//                                   const Color(0xFFEF4444),
//                                   const Color(0xFFDC2626),
//                                 ]
//                               : [
//                                   const Color(0xFF60A5FA),
//                                   const Color(0xFF3B82F6),
//                                 ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color:
//                                 (_showError
//                                         ? const Color(0xFFEF4444)
//                                         : const Color(0xFF3B82F6))
//                                     .withOpacity(0.4),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         _showError ? Icons.error_outline : Icons.verified_user,
//                         size: 60,
//                         color: Colors.white,
//                       ),
//                     ),

//                     const SizedBox(height: 30),

//                     // عنوان الصفحة
//                     ShaderMask(
//                       shaderCallback: (bounds) => const LinearGradient(
//                         colors: [Color(0xFF60A5FA), Color(0xFF8B5CF6)],
//                       ).createShader(bounds),
//                       child: Text(
//                         'نيو جراند',
//                         style: TextStyle(
//                           fontSize: 44,
//                           fontWeight: FontWeight.w900,
//                           fontFamily: 'Cairo',
//                           shadows: [
//                             Shadow(
//                               blurRadius: 8,
//                               color: Colors.black26,
//                               offset: Offset(2, 2),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     // وصف النظام
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 28,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.1),
//                         ),
//                       ),
//                       child: const Text(
//                         'فحص صلاحية الوصول',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white70,
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // حالة التحميل أو الخطأ
//                     if (_isLoading) ...[
//                       // حالة التحميل
//                       Column(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.05),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.1),
//                               ),
//                             ),
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'جارٍ التحقق من الصلاحية...',
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                     color: Colors.white,
//                                     fontFamily: 'Cairo',
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 15),
//                                 SizedBox(
//                                   width: 40,
//                                   height: 40,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 3,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                       const Color(0xFF60A5FA).withOpacity(0.8),
//                                     ),
//                                     backgroundColor: Colors.white.withOpacity(
//                                       0.1,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ] else if (_showError) ...[
//                       // رسالة الخطأ
//                       Container(
//                         width: MediaQuery.of(context).size.width * 0.8,
//                         padding: const EdgeInsets.all(25),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               const Color(0xFFEF4444).withOpacity(0.1),
//                               const Color(0xFFDC2626).withOpacity(0.1),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: const Color(0xFFEF4444).withOpacity(0.3),
//                             width: 2,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.2),
//                               blurRadius: 15,
//                               offset: const Offset(0, 5),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             const Icon(
//                               Icons.warning_amber_rounded,
//                               size: 50,
//                               color: Color(0xFFEF4444),
//                             ),
//                             const SizedBox(height: 15),
//                             const Text(
//                               'مستحقات غير مدفوعة',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 26,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 fontFamily: 'Cairo',
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Text(
//                               'يرجى التواصل مع الدعم الفني لدفع المستحقات',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.white.withOpacity(0.8),
//                                 fontFamily: 'Cairo',
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             // زر التواصل
//                             ElevatedButton.icon(
//                               onPressed: () {
//                                 // يمكنك إضافة وظيفة الاتصال هنا
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFFEF4444),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 30,
//                                   vertical: 15,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 elevation: 5,
//                                 shadowColor: const Color(
//                                   0xFFEF4444,
//                                 ).withOpacity(0.5),
//                               ),
//                               icon: const Icon(Icons.phone_in_talk),
//                               label: const Text(
//                                 'التواصل مع الدعم',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontFamily: 'Cairo',
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],

//                     const SizedBox(height: 40),

//                     // معلومات الاتصال
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 15,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(15),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.1),
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           const Text(
//                             'الدعم الفني',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white70,
//                               fontFamily: 'Cairo',
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: const [
//                               Icon(
//                                 Icons.code_rounded,
//                                 color: Color(0xFF60A5FA),
//                                 size: 20,
//                               ),
//                               SizedBox(width: 8),
//                               Text(
//                                 'CodeCrafter21',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                   fontFamily: 'Cairo',
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: const [
//                               Icon(
//                                 Icons.phone_android_rounded,
//                                 color: Color(0xFF10B981),
//                                 size: 18,
//                               ),
//                               SizedBox(width: 8),
//                               Text(
//                                 '+201557069620',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white70,
//                                   fontFamily: 'Cairo',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:last/main.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splash>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Timer _timer;
  String _formattedTime = '';
  String _formattedDate = '';
  String _greeting = '';
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isTablet = false;
  bool _isDesktop = false;

  @override
  void initState() {
    super.initState();

    // الكشف عن نوع الجهاز
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      setState(() {
        _isTablet = screenWidth >= 600 && screenWidth < 1024;
        _isDesktop = screenWidth >= 1024;
      });
    });

    // تهيئة الانيميشنات
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
        );

    // تهيئة اللغة العربية قبل استخدام DateFormat
    initializeDateFormatting('ar', null).then((_) {
      _updateDateTime();
      _fadeController.forward();

      // التايمر لتغيير الصفحة
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CheckAccessPage()),
        );
      });

      // تحديث الوقت باستمرار
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateDateTime();
      });
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final formatterTime = DateFormat('hh:mm a', 'ar');
    final formatterDate = DateFormat('EEEE، d MMMM yyyy', 'ar');
    final hour = now.hour;

    String greeting;
    if (hour < 12) {
      greeting = '🌅 صباح الخير 🌅';
    } else if (hour < 17) {
      greeting = '☀️ مساء الخير ☀️';
    } else {
      greeting = '🌙 مساء النور 🌙';
    }

    setState(() {
      _formattedTime = formatterTime.format(now);
      _formattedDate = formatterDate.format(now);
      _greeting = greeting;
    });
  }

  double _getIconSize() {
    if (_isDesktop) return 100;
    if (_isTablet) return 85;
    return 70;
  }

  double _getCompanyNameSize() {
    if (_isDesktop) return 56;
    if (_isTablet) return 42;
    return 38;
  }

  double _getGreetingSize() {
    if (_isDesktop) return 26;
    if (_isTablet) return 24;
    return 20;
  }

  double _getTimeSize() {
    if (_isDesktop) return 32;
    if (_isTablet) return 28;
    return 24;
  }

  double _getDateSize() {
    if (_isDesktop) return 18;
    if (_isTablet) return 16;
    return 14;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait = constraints.maxHeight > constraints.maxWidth;

          return Stack(
            children: [
              // خلفية متدرجة
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                      const Color(0xFF334155),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),

              // نماذج هندسية خلفية
              Positioned(
                top: -screenWidth * 0.2,
                right: -screenWidth * 0.2,
                child: Container(
                  width: screenWidth * 0.6,
                  height: screenWidth * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // انيميشن FadeTransition للمحتوى
              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: SingleChildScrollView(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // أيقونة مع تأثير
                              Container(
                                width: _isDesktop
                                    ? 180
                                    : _isTablet
                                    ? 160
                                    : 140,
                                height: _isDesktop
                                    ? 180
                                    : _isTablet
                                    ? 120
                                    : 140,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF60A5FA),
                                      Color(0xFF3B82F6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF3B82F6,
                                      ).withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/image/app_icon.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              // وصف النظام
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenHeight * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Text(
                                  'نظام إدارة السيارات و السائقين',
                                  style: TextStyle(
                                    fontSize: _isDesktop
                                        ? 22
                                        : _isTablet
                                        ? 20
                                        : 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                    fontFamily: 'Cairo',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.03),

                              // تحية مع تأثيرات
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenHeight * 0.015,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF3B82F6).withOpacity(0.2),
                                      const Color(0xFF8B5CF6).withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  _greeting,
                                  style: TextStyle(
                                    fontSize: _getGreetingSize(),
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              // الوقت مع تصميم عصري
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: _isDesktop
                                      ? 350
                                      : _isTablet
                                      ? 300
                                      : 250,
                                ),
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.access_time_filled,
                                          color: const Color(0xFF60A5FA),
                                          size: _isDesktop ? 28 : 24,
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Text(
                                          _formattedTime,
                                          style: TextStyle(
                                            fontSize: _getTimeSize(),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(
                                      _formattedDate,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: _getDateSize(),
                                        color: Colors.white.withOpacity(0.8),
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.03),

                              // دائرة التحميل مع تدرج
                              SizedBox(
                                width: _isDesktop
                                    ? 70
                                    : _isTablet
                                    ? 65
                                    : 60,
                                height: _isDesktop
                                    ? 70
                                    : _isTablet
                                    ? 65
                                    : 60,
                                child: Stack(
                                  children: [
                                    // خلفية الدائرة
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF3B82F6),
                                            Color(0xFF8B5CF6),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF3B82F6,
                                            ).withOpacity(0.3),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // مؤشر التحميل
                                    const Center(
                                      child: SizedBox(
                                        width: 25,
                                        height: 25,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                width: screenWidth * 0.4,
                                height: 2,
                                margin: EdgeInsets.only(
                                  bottom: screenHeight * 0.02,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF60A5FA),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              // معلومات المطور
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.06,
                                  vertical: screenHeight * 0.015,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: _isDesktop
                                      ? 500
                                      : _isTablet
                                      ? 400
                                      : 350,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.code_rounded,
                                          color: const Color(0xFF60A5FA),
                                          size: _isDesktop ? 24 : 20,
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        ShaderMask(
                                          shaderCallback: (bounds) =>
                                              const LinearGradient(
                                                colors: [
                                                  Color(0xFF60A5FA),
                                                  Color(0xFF8B5CF6),
                                                ],
                                              ).createShader(bounds),
                                          child: Text(
                                            'CodeCrafter21',
                                            style: TextStyle(
                                              fontSize: _isDesktop
                                                  ? 24
                                                  : _isTablet
                                                  ? 22
                                                  : 20,
                                              fontWeight: FontWeight.w800,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.008),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.phone_android_rounded,
                                          color: const Color(0xFF10B981),
                                          size: _isDesktop ? 22 : 18,
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Text(
                                          '+201557069620',
                                          style: TextStyle(
                                            fontSize: _isDesktop
                                                ? 20
                                                : _isTablet
                                                ? 18
                                                : 16,
                                            color: Colors.white70,
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // التوقيع في الأسفل
              // Positioned(
              //   bottom: screenHeight * 0.02,
              //   left: 0,
              //   right: 0,
              //   child: Column(
              //     children: [
              //       // خط فاصل
              //       Container(
              //         width: screenWidth * 0.4,
              //         height: 2,
              //         margin: EdgeInsets.only(bottom: screenHeight * 0.02),
              //         decoration: BoxDecoration(
              //           gradient: const LinearGradient(
              //             colors: [
              //               Colors.transparent,
              //               Color(0xFF60A5FA),
              //               Colors.transparent,
              //             ],
              //           ),
              //           borderRadius: BorderRadius.circular(2),
              //         ),
              //       ),

              //       // معلومات المطور
              //       Container(
              //         padding: EdgeInsets.symmetric(
              //           horizontal: screenWidth * 0.06,
              //           vertical: screenHeight * 0.015,
              //         ),
              //         constraints: BoxConstraints(
              //           maxWidth: _isDesktop
              //               ? 500
              //               : _isTablet
              //               ? 400
              //               : 350,
              //         ),
              //         decoration: BoxDecoration(
              //           color: Colors.white.withOpacity(0.05),
              //           borderRadius: BorderRadius.circular(20),
              //           border: Border.all(
              //             color: Colors.white.withOpacity(0.1),
              //           ),
              //         ),
              //         child: Column(
              //           children: [
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Icon(
              //                   Icons.code_rounded,
              //                   color: const Color(0xFF60A5FA),
              //                   size: _isDesktop ? 24 : 20,
              //                 ),
              //                 SizedBox(width: screenWidth * 0.02),
              //                 ShaderMask(
              //                   shaderCallback: (bounds) =>
              //                       const LinearGradient(
              //                         colors: [
              //                           Color(0xFF60A5FA),
              //                           Color(0xFF8B5CF6),
              //                         ],
              //                       ).createShader(bounds),
              //                   child: Text(
              //                     'CodeCrafter21',
              //                     style: TextStyle(
              //                       fontSize: _isDesktop
              //                           ? 24
              //                           : _isTablet
              //                           ? 22
              //                           : 20,
              //                       fontWeight: FontWeight.w800,
              //                       fontFamily: 'Cairo',
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //             SizedBox(height: screenHeight * 0.008),
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Icon(
              //                   Icons.phone_android_rounded,
              //                   color: const Color(0xFF10B981),
              //                   size: _isDesktop ? 22 : 18,
              //                 ),
              //                 SizedBox(width: screenWidth * 0.02),
              //                 Text(
              //                   '+201557069620',
              //                   style: TextStyle(
              //                     fontSize: _isDesktop
              //                         ? 20
              //                         : _isTablet
              //                         ? 18
              //                         : 16,
              //                     color: Colors.white70,
              //                     fontFamily: 'Cairo',
              //                     fontWeight: FontWeight.w500,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}

class CheckAccessPage extends StatefulWidget {
  const CheckAccessPage({Key? key}) : super(key: key);

  @override
  State<CheckAccessPage> createState() => _CheckAccessPageState();
}

class _CheckAccessPageState extends State<CheckAccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  bool _showError = false;
  bool _isLoading = true;
  late Timer _loadingTimer;
  bool _isTablet = false;
  bool _isDesktop = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      setState(() {
        _isTablet = screenWidth >= 600 && screenWidth < 1024;
        _isDesktop = screenWidth >= 1024;
      });
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubic,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    // محاكاة وقت التحميل
    _loadingTimer = Timer(const Duration(milliseconds: 1200), () {
      checkValue();
    });
  }

  double _getIconSize() {
    if (_isDesktop) return 80;
    if (_isTablet) return 70;
    return 60;
  }

  double _getTitleSize() {
    if (_isDesktop) return 48;
    if (_isTablet) return 38;
    return 32;
  }

  double _getErrorTitleSize() {
    if (_isDesktop) return 28;
    if (_isTablet) return 24;
    return 20;
  }

  double _getErrorTextSize() {
    if (_isDesktop) return 20;
    if (_isTablet) return 18;
    return 16;
  }

  Future<void> checkValue() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('grand')
          .limit(1)
          .get();

      if (query.docs.isEmpty) throw 'لم يتم العثور على مستندات في المجموعة';

      int value = (query.docs.first.get('value') as num).toInt();

      if (value == 1) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => MainDashboard(),
            transitionDuration: const Duration(milliseconds: 1000),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _showError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showError = true;
      });

      // إشعار خطأ أنيق
      Future.delayed(const Duration(milliseconds: 300), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'خطأ في الاتصال: ${e.toString()}',
                    style: TextStyle(
                      fontSize: _isDesktop ? 16 : 14,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _loadingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // خلفية متدرجة
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                      const Color(0xFF334155),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),

              // نماذج هندسية خلفية
              Positioned(
                top: -screenWidth * 0.15,
                left: -screenWidth * 0.15,
                child: Container(
                  width: screenWidth * 0.4,
                  height: screenWidth * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF10B981).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: SingleChildScrollView(
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // أيقونة التحقق
                            Container(
                              width: _isDesktop
                                  ? 140
                                  : _isTablet
                                  ? 130
                                  : 120,
                              height: _isDesktop
                                  ? 140
                                  : _isTablet
                                  ? 130
                                  : 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _showError
                                      ? [
                                          const Color(0xFFEF4444),
                                          const Color(0xFFDC2626),
                                        ]
                                      : [
                                          const Color(0xFF60A5FA),
                                          const Color(0xFF3B82F6),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_showError
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF3B82F6))
                                            .withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _showError
                                    ? Icons.error_outline
                                    : Icons.verified_user,
                                size: _getIconSize(),
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            // عنوان الصفحة
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF60A5FA), Color(0xFF8B5CF6)],
                              ).createShader(bounds),
                              child: Text(
                                'نيو جراند',
                                style: TextStyle(
                                  fontSize: _getTitleSize(),
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Cairo',
                                  shadows: [
                                    const Shadow(
                                      blurRadius: 8,
                                      color: Colors.black26,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.015),

                            // وصف النظام
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: screenHeight * 0.01,
                              ),
                              constraints: BoxConstraints(
                                maxWidth: _isDesktop
                                    ? 500
                                    : _isTablet
                                    ? 400
                                    : 350,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                'فحص صلاحية الوصول',
                                style: TextStyle(
                                  fontSize: _isDesktop
                                      ? 22
                                      : _isTablet
                                      ? 20
                                      : 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                  fontFamily: 'Cairo',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.04),

                            // حالة التحميل أو الخطأ
                            if (_isLoading) ...[
                              // حالة التحميل
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: _isDesktop
                                      ? 500
                                      : _isTablet
                                      ? 400
                                      : 350,
                                ),
                                padding: EdgeInsets.all(screenWidth * 0.05),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'جارٍ التحقق من الصلاحية...',
                                      style: TextStyle(
                                        fontSize: _isDesktop
                                            ? 22
                                            : _isTablet
                                            ? 20
                                            : 18,
                                        color: Colors.white,
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    SizedBox(
                                      width: _isDesktop
                                          ? 50
                                          : _isTablet
                                          ? 45
                                          : 40,
                                      height: _isDesktop
                                          ? 50
                                          : _isTablet
                                          ? 45
                                          : 40,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              const Color(
                                                0xFF60A5FA,
                                              ).withOpacity(0.8),
                                            ),
                                        backgroundColor: Colors.white
                                            .withOpacity(0.1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (_showError) ...[
                              // رسالة الخطأ
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: _isDesktop
                                      ? 600
                                      : _isTablet
                                      ? 500
                                      : 400,
                                ),
                                padding: EdgeInsets.all(screenWidth * 0.05),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFEF4444).withOpacity(0.1),
                                      const Color(0xFFDC2626).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFEF4444,
                                    ).withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: _isDesktop
                                          ? 60
                                          : _isTablet
                                          ? 55
                                          : 50,
                                      color: const Color(0xFFEF4444),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    Text(
                                      'مستحقات غير مدفوعة',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: _getErrorTitleSize(),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.015),
                                    Text(
                                      'يرجى التواصل مع الدعم الفني لدفع المستحقات',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: _getErrorTextSize(),
                                        color: Colors.white.withOpacity(0.8),
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.025),
                                    // زر التواصل
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // يمكنك إضافة وظيفة الاتصال هنا
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFEF4444,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.06,
                                          vertical: screenHeight * 0.018,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        elevation: 5,
                                        shadowColor: const Color(
                                          0xFFEF4444,
                                        ).withOpacity(0.5),
                                      ),
                                      icon: Icon(
                                        Icons.phone_in_talk,
                                        size: _isDesktop ? 24 : 22,
                                      ),
                                      label: Text(
                                        'التواصل مع الدعم',
                                        style: TextStyle(
                                          fontSize: _isDesktop
                                              ? 20
                                              : _isTablet
                                              ? 18
                                              : 16,
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: screenHeight * 0.04),

                            // معلومات الاتصال
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: _isDesktop
                                    ? 500
                                    : _isTablet
                                    ? 400
                                    : 350,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: screenHeight * 0.02,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'الدعم الفني',
                                    style: TextStyle(
                                      fontSize: _isDesktop
                                          ? 18
                                          : _isTablet
                                          ? 16
                                          : 14,
                                      color: Colors.white70,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.code_rounded,
                                        color: const Color(0xFF60A5FA),
                                        size: _isDesktop ? 24 : 20,
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        'CodeCrafter21',
                                        style: TextStyle(
                                          fontSize: _isDesktop
                                              ? 20
                                              : _isTablet
                                              ? 18
                                              : 16,
                                          color: Colors.white,
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.008),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.phone_android_rounded,
                                        color: const Color(0xFF10B981),
                                        size: _isDesktop ? 22 : 18,
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        '+201557069620',
                                        style: TextStyle(
                                          fontSize: _isDesktop
                                              ? 18
                                              : _isTablet
                                              ? 16
                                              : 14,
                                          color: Colors.white70,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
