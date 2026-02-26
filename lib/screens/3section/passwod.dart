// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ChangePasswordPage extends StatefulWidget {
//   const ChangePasswordPage({super.key});

//   @override
//   State<ChangePasswordPage> createState() => _ChangePasswordPageState();
// }

// class _ChangePasswordPageState extends State<ChangePasswordPage> {
//   final TextEditingController _currentPasswordController =
//       TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   bool _isLoading = false;
//   bool _obscureCurrent = true;
//   bool _obscureNew = true;
//   bool _obscureConfirm = true;
//   String? _message;
//   bool _isSuccess = false;

//   Future<void> _changePassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _message = null;
//       _isSuccess = false;
//     });

//     try {
//       // التحقق من كلمة السر الحالية
//       final docSnapshot = await FirebaseFirestore.instance
//           .collection('app_settings')
//           .doc('password')
//           .get();

//       if (docSnapshot.exists) {
//         final currentStoredPassword = docSnapshot.data()?['value'] ?? '';

//         if (_currentPasswordController.text != currentStoredPassword) {
//           setState(() {
//             _message = 'كلمة السر الحالية غير صحيحة';
//             _isSuccess = false;
//           });
//           return;
//         }

//         // تحديث كلمة السر
//         await FirebaseFirestore.instance
//             .collection('app_settings')
//             .doc('password')
//             .update({'value': _newPasswordController.text});

//         setState(() {
//           _message = 'تم تغيير كلمة السر بنجاح';
//           _isSuccess = true;
//           _currentPasswordController.clear();
//           _newPasswordController.clear();
//           _confirmPasswordController.clear();
//         });

//         // العودة بعد 2 ثانية
//         Future.delayed(const Duration(seconds: 2), () {
//           if (mounted) {
//             Navigator.pop(context);
//           }
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _message = 'حدث خطأ: ${e.toString()}';
//         _isSuccess = false;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('تغيير كلمة السر'),
//         backgroundColor: Color(0xFF2C3E50),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF2C3E50), Colors.white],
//             stops: [0.0, 0.3],
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Container(
//               constraints: BoxConstraints(maxWidth: 500),
//               child: Card(
//                 elevation: 8,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(32.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // عنوان الصفحة
//                         Center(
//                           child: Column(
//                             children: [
//                               Icon(
//                                 Icons.password,
//                                 size: 60,
//                                 color: Color(0xFF2C3E50),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'تغيير كلمة السر',
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF2C3E50),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 30),

//                         // كلمة السر الحالية
//                         Directionality(
//                           textDirection: TextDirection.rtl,
//                           child: TextFormField(
//                             controller: _currentPasswordController,
//                             obscureText: _obscureCurrent,
//                             decoration: InputDecoration(
//                               labelText: 'كلمة السر الحالية',
//                               prefixIcon: Icon(Icons.lock_outline),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _obscureCurrent
//                                       ? Icons.visibility
//                                       : Icons.visibility_off,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _obscureCurrent = !_obscureCurrent;
//                                   });
//                                 },
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               filled: true,
//                               fillColor: Colors.grey[50],
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'الرجاء إدخال كلمة السر الحالية';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         // كلمة السر الجديدة
//                         Directionality(
//                           textDirection: TextDirection.rtl,
//                           child: TextFormField(
//                             controller: _newPasswordController,
//                             obscureText: _obscureNew,
//                             decoration: InputDecoration(
//                               labelText: 'كلمة السر الجديدة',
//                               prefixIcon: Icon(Icons.lock),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _obscureNew
//                                       ? Icons.visibility
//                                       : Icons.visibility_off,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _obscureNew = !_obscureNew;
//                                   });
//                                 },
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               filled: true,
//                               fillColor: Colors.grey[50],
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'الرجاء إدخال كلمة السر الجديدة';
//                               }
//                               if (value.length < 4) {
//                                 return 'كلمة السر يجب أن تكون 4 أحرف على الأقل';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         // تأكيد كلمة السر
//                         Directionality(
//                           textDirection: TextDirection.rtl,
//                           child: TextFormField(
//                             controller: _confirmPasswordController,
//                             obscureText: _obscureConfirm,
//                             decoration: InputDecoration(
//                               labelText: 'تأكيد كلمة السر الجديدة',
//                               prefixIcon: Icon(Icons.lock_outline),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _obscureConfirm
//                                       ? Icons.visibility
//                                       : Icons.visibility_off,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _obscureConfirm = !_obscureConfirm;
//                                   });
//                                 },
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               filled: true,
//                               fillColor: Colors.grey[50],
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'الرجاء تأكيد كلمة السر الجديدة';
//                               }
//                               if (value != _newPasswordController.text) {
//                                 return 'كلمة السر غير متطابقة';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),

//                         if (_message != null) ...[
//                           const SizedBox(height: 16),
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: _isSuccess
//                                   ? Colors.green[50]
//                                   : Colors.red[50],
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(
//                                 color: _isSuccess
//                                     ? Colors.green[200]!
//                                     : Colors.red[200]!,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   _isSuccess ? Icons.check_circle : Icons.error,
//                                   color: _isSuccess
//                                       ? Colors.green[700]
//                                       : Colors.red[700],
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     _message!,
//                                     style: TextStyle(
//                                       color: _isSuccess
//                                           ? Colors.green[700]
//                                           : Colors.red[700],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],

//                         const SizedBox(height: 24),

//                         // أزرار التحكم
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: _isLoading ? null : _changePassword,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Color(0xFF2C3E50),
//                                   foregroundColor: Colors.white,
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 15,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: _isLoading
//                                     ? const SizedBox(
//                                         width: 24,
//                                         height: 24,
//                                         child: CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2,
//                                         ),
//                                       )
//                                     : const Text('حفظ التغييرات'),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                                 style: OutlinedButton.styleFrom(
//                                   foregroundColor: Color(0xFF2C3E50),
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 15,
//                                   ),
//                                   side: BorderSide(color: Color(0xFF2C3E50)),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: const Text('إلغاء'),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _currentPasswordController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _message;
  bool _isSuccess = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
      _isSuccess = false;
    });

    try {
      // التحقق من كلمة السر الحالية
      final docSnapshot = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('password')
          .get();

      if (docSnapshot.exists) {
        final currentStoredPassword = docSnapshot.data()?['value'] ?? '';

        if (_currentPasswordController.text != currentStoredPassword) {
          setState(() {
            _message = 'كلمة السر الحالية غير صحيحة';
            _isSuccess = false;
            _isLoading = false;
          });
          return;
        }

        // تحديث كلمة السر
        await FirebaseFirestore.instance
            .collection('app_settings')
            .doc('password')
            .update({'value': _newPasswordController.text});

        setState(() {
          _message = 'تم تغيير كلمة السر بنجاح';
          _isSuccess = true;
          _isLoading = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });

        // إظهار رسالة نجاح ثم العودة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تغيير كلمة السر بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // العودة بعد 2 ثانية
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      setState(() {
        _message = 'حدث خطأ: ${e.toString()}';
        _isSuccess = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تغيير كلمة السر'),
        backgroundColor: Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C3E50), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // عنوان الصفحة
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2C3E50).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.password,
                                  size: 40,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'تغيير كلمة السر',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'قم بتغيير كلمة السر الخاصة بك',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // كلمة السر الحالية
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextFormField(
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrent,
                            decoration: InputDecoration(
                              labelText: 'كلمة السر الحالية',
                              hintText: 'أدخل كلمة السر الحالية',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Color(0xFF2C3E50),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureCurrent
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureCurrent = !_obscureCurrent;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF2C3E50),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال كلمة السر الحالية';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // كلمة السر الجديدة
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            decoration: InputDecoration(
                              labelText: 'كلمة السر الجديدة',
                              hintText: 'أدخل كلمة السر الجديدة',
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Color(0xFF2C3E50),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNew
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNew = !_obscureNew;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF2C3E50),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال كلمة السر الجديدة';
                              }
                              if (value.length < 4) {
                                return 'كلمة السر يجب أن تكون 4 أحرف على الأقل';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // تأكيد كلمة السر
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              labelText: 'تأكيد كلمة السر الجديدة',
                              hintText: 'أعد إدخال كلمة السر الجديدة',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Color(0xFF2C3E50),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirm = !_obscureConfirm;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF2C3E50),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء تأكيد كلمة السر الجديدة';
                              }
                              if (value != _newPasswordController.text) {
                                return 'كلمة السر غير متطابقة';
                              }
                              return null;
                            },
                          ),
                        ),

                        if (_message != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isSuccess
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isSuccess
                                    ? Colors.green[200]!
                                    : Colors.red[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isSuccess ? Icons.check_circle : Icons.error,
                                  color: _isSuccess
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _message!,
                                    style: TextStyle(
                                      color: _isSuccess
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // أزرار التحكم
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2C3E50),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'حفظ التغييرات',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            // const SizedBox(width: 12),
                            // Expanded(
                            //   child: OutlinedButton(
                            //     onPressed: () {
                            //       // Navigator.pop(context);
                            //     },
                            //     style: OutlinedButton.styleFrom(
                            //       foregroundColor: Color(0xFF2C3E50),
                            //       padding: const EdgeInsets.symmetric(
                            //         vertical: 15,
                            //       ),
                            //       side: BorderSide(
                            //         color: Color(0xFF2C3E50),
                            //         width: 1.5,
                            //       ),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(12),
                            //       ),
                            //     ),
                            //     child: const Text(
                            //       'إلغاء',
                            //       style: TextStyle(
                            //         fontSize: 16,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
