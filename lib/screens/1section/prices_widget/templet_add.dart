// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:last/models/models.dart';

// class AddPriceOfferForm extends StatefulWidget {
//   final String companyId;
//   final String companyName;

//   const AddPriceOfferForm({
//     super.key,
//     required this.companyId,
//     required this.companyName,
//   });

//   @override
//   State<AddPriceOfferForm> createState() => _AddPriceOfferFormState();
// }

// class _AddPriceOfferFormState extends State<AddPriceOfferForm> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   List<Transportation> transportations = [
//     Transportation(
//       loadingLocation: '',
//       unloadingLocation: '',
//       vehicleType: '',
//       nolon: 0.0,
//     ),
//   ];

//   bool isSaving = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           bool isMobile = constraints.maxWidth < 600;
//           bool isTablet = constraints.maxWidth < 1000;

//           return Column(
//             children: [
//               _buildCustomAppBar(isMobile),
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(isMobile ? 16 : 24),
//                   child: Center(
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(maxWidth: 900),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           children: [
//                             Card(
//                               elevation: 8,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(
//                                   isMobile ? 16 : 22,
//                                 ),
//                               ),
//                               child: Padding(
//                                 padding: EdgeInsets.all(isMobile ? 16 : 32),
//                                 child: Column(
//                                   children: [
//                                     SizedBox(height: isMobile ? 16 : 32),
//                                     _buildHeaderSection(isMobile),
//                                     SizedBox(height: isMobile ? 16 : 32),
//                                     _buildTransportationsSection(isMobile),
//                                     SizedBox(height: isMobile ? 20 : 40),
//                                     _buildActionButtons(isMobile),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCustomAppBar(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16 : 24,
//         vertical: isMobile ? 12 : 20,
//       ),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.centerRight,
//           end: Alignment.centerLeft,
//           colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
//         ),
//         boxShadow: [
//           BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             IconButton(
//               icon: Icon(
//                 Icons.arrow_back,
//                 color: Colors.white,
//                 size: isMobile ? 20 : 24,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//             SizedBox(width: isMobile ? 8 : 12),
//             Icon(
//               Icons.price_change,
//               color: Colors.white,
//               size: isMobile ? 24 : 32,
//             ),
//             SizedBox(width: isMobile ? 8 : 12),
//             Expanded(
//               child: Text(
//                 'إضافة عرض سعر - ${widget.companyName}',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: isMobile ? 16 : 20,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Cairo',
//                 ),
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection(bool isMobile) {
//     return Column(
//       children: [
//         Text(
//           'إضافة عرض سعر لشركة ${widget.companyName}',
//           style: TextStyle(
//             fontSize: isMobile ? 18 : 20,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(height: isMobile ? 8 : 12),
//         Text(
//           'أضف تفاصيل النقل لكل رحلة - يمكنك إضافة أكثر من رحلة',
//           style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.grey),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildTransportationsSection(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (!isMobile) // نخفي العنوان في الشاشات الصغيرة لتوفير المساحة
//           const Text(
//             'تفاصيل الرحلات',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//         if (!isMobile) SizedBox(height: 16),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: transportations.length,
//           itemBuilder: (context, index) =>
//               _buildTransportationCard(index, isMobile),
//         ),
//       ],
//     );
//   }

//   Widget _buildTransportationCard(int index, bool isMobile) {
//     return Card(
//       margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isMobile ? 12 : 20),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'رحلة ${index + 1}',
//                   style: TextStyle(
//                     fontSize: isMobile ? 16 : 18,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFF2C3E50),
//                   ),
//                 ),
//                 const Spacer(),
//                 if (transportations.length > 1)
//                   IconButton(
//                     onPressed: () => _removeTransportation(index),
//                     icon: Icon(
//                       Icons.delete,
//                       color: Colors.red,
//                       size: isMobile ? 18 : 24,
//                     ),
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//               ],
//             ),
//             SizedBox(height: isMobile ? 12 : 16),
//             _buildTransportationFields(index, isMobile),
//             SizedBox(height: isMobile ? 12 : 16),
//             if (index == transportations.length - 1)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _addTransportation,
//                   icon: Icon(
//                     Icons.add,
//                     color: Colors.white,
//                     size: isMobile ? 16 : 20,
//                   ),
//                   label: Text(
//                     'إضافة رحلة أخرى',
//                     style: TextStyle(
//                       fontSize: isMobile ? 14 : 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isMobile ? 12 : 16,
//                       vertical: isMobile ? 10 : 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransportationFields(int index, bool isMobile) {
//     return Column(
//       children: [
//         // في الشاشات الصغيرة نضع الحقول تحت بعض
//         isMobile
//             ? Column(
//                 children: [
//                   _buildField(
//                     'مكان التحميل',
//                     Icons.location_on,
//                     (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'هذا الحقل مطلوب';
//                       }
//                       return null;
//                     },
//                     onChanged: (value) {
//                       transportations[index].loadingLocation = value;
//                     },
//                     isMobile: isMobile,
//                   ),
//                   SizedBox(height: isMobile ? 12 : 16),
//                   _buildField(
//                     'مكان التعتيق',
//                     Icons.location_on,
//                     (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'هذا الحقل مطلوب';
//                       }
//                       return null;
//                     },
//                     onChanged: (value) {
//                       transportations[index].unloadingLocation = value;
//                     },
//                     isMobile: isMobile,
//                   ),
//                 ],
//               )
//             : Row(
//                 children: [
//                   Expanded(
//                     child: _buildField(
//                       'مكان التحميل',
//                       Icons.location_on,
//                       (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'هذا الحقل مطلوب';
//                         }
//                         return null;
//                       },
//                       onChanged: (value) {
//                         transportations[index].loadingLocation = value;
//                       },
//                       isMobile: isMobile,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: _buildField(
//                       'مكان التعتيق',
//                       Icons.location_on,
//                       (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'هذا الحقل مطلوب';
//                         }
//                         return null;
//                       },
//                       onChanged: (value) {
//                         transportations[index].unloadingLocation = value;
//                       },
//                       isMobile: isMobile,
//                     ),
//                   ),
//                 ],
//               ),
//         SizedBox(height: isMobile ? 12 : 16),
//         // نوع العربيه والنولون
//         isMobile
//             ? Column(
//                 children: [
//                   _buildField(
//                     'نوع العربيه',
//                     Icons.directions_car,
//                     (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'هذا الحقل مطلوب';
//                       }
//                       return null;
//                     },
//                     onChanged: (value) {
//                       transportations[index].vehicleType = value;
//                     },
//                     isMobile: isMobile,
//                   ),
//                   SizedBox(height: isMobile ? 12 : 16),
//                   _buildNolonField(index, isMobile),
//                 ],
//               )
//             : Row(
//                 children: [
//                   Expanded(
//                     child: _buildField(
//                       'نوع العربيه',
//                       Icons.directions_car,
//                       (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'هذا الحقل مطلوب';
//                         }
//                         return null;
//                       },
//                       onChanged: (value) {
//                         transportations[index].vehicleType = value;
//                       },
//                       isMobile: isMobile,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(child: _buildNolonField(index, isMobile)),
//                 ],
//               ),
//         SizedBox(height: isMobile ? 12 : 16),
//         _buildField(
//           'ملاحظات (اختياري)',
//           Icons.note,
//           (value) => null,
//           onChanged: (value) {
//             transportations[index].notes = value;
//           },
//           isMobile: isMobile,
//         ),
//       ],
//     );
//   }

//   Widget _buildField(
//     String label,
//     IconData icon,
//     String? Function(String?)? validator, {
//     required Function(String) onChanged,
//     required bool isMobile,
//   }) {
//     return TextFormField(
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: isMobile ? 12 : 16,
//           vertical: isMobile ? 12 : 16,
//         ),
//       ),
//       validator: validator,
//       onChanged: onChanged,
//       style: TextStyle(fontSize: isMobile ? 14 : 16),
//     );
//   }

//   Widget _buildNolonField(int index, bool isMobile) {
//     return TextFormField(
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         labelText: 'النولون',
//         prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF3498DB)),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: isMobile ? 12 : 16,
//           vertical: isMobile ? 12 : 16,
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'هذا الحقل مطلوب';
//         }
//         if (double.tryParse(value) == null) {
//           return 'يجب إدخال رقم صحيح';
//         }
//         return null;
//       },
//       onChanged: (value) {
//         if (value.isNotEmpty) {
//           transportations[index].nolon = double.parse(value);
//         }
//       },
//       style: TextStyle(fontSize: isMobile ? 14 : 16),
//     );
//   }

//   Widget _buildActionButtons(bool isMobile) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: isSaving ? null : _savePriceOffer,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF2E86C1),
//           padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//           ),
//         ),
//         child: isSaving
//             ? const CircularProgressIndicator(color: Colors.white)
//             : Text(
//                 'حفظ عرض السعر',
//                 style: TextStyle(
//                   fontSize: isMobile ? 16 : 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//       ),
//     );
//   }

//   void _addTransportation() {
//     setState(() {
//       transportations.add(
//         Transportation(
//           loadingLocation: '',
//           unloadingLocation: '',
//           vehicleType: '',
//           nolon: 0.0,
//         ),
//       );
//     });
//   }

//   void _removeTransportation(int index) {
//     setState(() {
//       transportations.removeAt(index);
//     });
//   }

//   void _savePriceOffer() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isSaving = true);

//     try {
//       final priceOffer = PriceOffer(
//         companyId: widget.companyId,
//         companyName: widget.companyName,
//         transportations: transportations,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );

//       await _firestore
//           .collection('companies')
//           .doc(widget.companyId)
//           .collection('priceOffers')
//           .add(priceOffer.toMap());

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('تم حفظ عرض السعر بنجاح'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في الحفظ: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => isSaving = false);
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:last/models/models.dart';

class AddPriceOfferForm extends StatefulWidget {
  final String companyId;
  final String companyName;

  const AddPriceOfferForm({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<AddPriceOfferForm> createState() => _AddPriceOfferFormState();
}

class _AddPriceOfferFormState extends State<AddPriceOfferForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Transportation> transportations = [
    Transportation(
      loadingLocation: '',
      unloadingLocation: '',
      vehicleType: '',
      nolon: 0.0,
      companyOvernight: 0.0,
      companyHoliday: 0.0,
      wheelNolon: 0.0,
      wheelOvernight: 0.0,
      wheelHoliday: 0.0,
    ),
  ];

  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet = constraints.maxWidth < 1000;

          return Column(
            children: [
              _buildCustomAppBar(isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 8 : 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  isMobile ? 16 : 22,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 16 : 32),
                                child: Column(
                                  children: [
                                    SizedBox(height: isMobile ? 16 : 32),
                                    _buildHeaderSection(isMobile),
                                    SizedBox(height: isMobile ? 16 : 32),
                                    _buildTransportationsSection(isMobile),
                                    SizedBox(height: isMobile ? 20 : 40),
                                    _buildActionButtons(isMobile),
                                  ],
                                ),
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

  Widget _buildCustomAppBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isMobile ? 20 : 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Icon(
              Icons.price_change,
              color: Colors.white,
              size: isMobile ? 24 : 32,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Text(
                'إضافة عرض سعر - ${widget.companyName}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isMobile) {
    return Column(
      children: [
        Text(
          'إضافة عرض سعر لشركة ${widget.companyName}',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTransportationsSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if (!isMobile) // نخفي العنوان في الشاشات الصغيرة لتوفير المساحة
        // const Text(
        //   'تفاصيل عروض الاسعار',
        //   style: TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.bold,
        //     color: Color(0xFF2C3E50),
        //   ),
        // ),
        if (!isMobile) SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transportations.length,
          itemBuilder: (context, index) =>
              _buildTransportationCard(index, isMobile),
        ),
      ],
    );
  }

  Widget _buildTransportationCard(int index, bool isMobile) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'عرض سعر ${index + 1}',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const Spacer(),
                if (transportations.length > 1)
                  IconButton(
                    onPressed: () => _removeTransportation(index),
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: isMobile ? 18 : 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            _buildTransportationFields(index, isMobile),
            SizedBox(height: isMobile ? 12 : 16),
            if (index == transportations.length - 1)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addTransportation,
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: isMobile ? 16 : 20,
                  ),
                  label: Text(
                    'إضافة عرض سعر أخرى',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: isMobile ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportationFields(int index, bool isMobile) {
    return Column(
      children: [
        // الحقول الأساسية: مكان التحميل، مكان التعتيق، نوع العربيه
        isMobile
            ? Column(
                children: [
                  _buildField(
                    'مكان التحميل',
                    Icons.location_on,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      transportations[index].loadingLocation = value;
                    },
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  _buildField(
                    'مكان التعتيق',
                    Icons.location_on,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      transportations[index].unloadingLocation = value;
                    },
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  _buildField(
                    'نوع العربيه',
                    Icons.directions_car,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      transportations[index].vehicleType = value;
                    },
                    isMobile: isMobile,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'مكان التحميل',
                      Icons.location_on,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        transportations[index].loadingLocation = value;
                      },
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      'مكان التعتيق',
                      Icons.location_on,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        transportations[index].unloadingLocation = value;
                      },
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      'نوع العربيه',
                      Icons.directions_car,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        transportations[index].vehicleType = value;
                      },
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),

        SizedBox(height: isMobile ? 16 : 24),

        // قسم الشركات
        _buildCompanySection(index, isMobile),

        SizedBox(height: isMobile ? 16 : 24),

        // قسم العجل
        _buildWheelSection(index, isMobile),

        SizedBox(height: isMobile ? 16 : 24),

        // حقل الملاحظات
        // _buildField(
        //   'ملاحظات (اختياري)',
        //   Icons.note,
        //   (value) => null,
        //   onChanged: (value) {
        //     transportations[index].notes = value;
        //   },
        //   isMobile: isMobile,
        // ),
      ],
    );
  }

  Widget _buildCompanySection(int index, bool isMobile) {
    return Card(
      elevation: 2,
      color: const Color(0xFFE8F4F8),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: const Color(0xFF1B4F72), size: 20),
                SizedBox(width: 8),
                Text(
                  'أسعار الشركات',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B4F72),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            isMobile
                ? Column(
                    children: [
                      _buildNumberField(
                        'النولون',
                        Icons.attach_money,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'هذا الحقل مطلوب';
                          }
                          if (double.tryParse(value) == null) {
                            return 'يجب إدخال رقم صحيح';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            transportations[index].nolon = double.parse(value);
                          }
                        },
                        isMobile: isMobile,
                      ),
                      SizedBox(height: 12),
                      _buildNumberField(
                        'المبيت',
                        Icons.hotel,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'هذا الحقل مطلوب';
                          }
                          if (double.tryParse(value) == null) {
                            return 'يجب إدخال رقم صحيح';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            transportations[index].companyOvernight =
                                double.parse(value);
                          }
                        },
                        isMobile: isMobile,
                      ),
                      SizedBox(height: 12),
                      _buildNumberField(
                        'العطلة',
                        Icons.beach_access,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'هذا الحقل مطلوب';
                          }
                          if (double.tryParse(value) == null) {
                            return 'يجب إدخال رقم صحيح';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            transportations[index].companyHoliday =
                                double.parse(value);
                          }
                        },
                        isMobile: isMobile,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          'النولون',
                          Icons.attach_money,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'يجب إدخال رقم صحيح';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              transportations[index].nolon = double.parse(
                                value,
                              );
                            }
                          },
                          isMobile: isMobile,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildNumberField(
                          'المبيت',
                          Icons.hotel,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'يجب إدخال رقم صحيح';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              transportations[index].companyOvernight =
                                  double.parse(value);
                            }
                          },
                          isMobile: isMobile,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildNumberField(
                          'العطلة',
                          Icons.beach_access,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'يجب إدخال رقم صحيح';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              transportations[index].companyHoliday =
                                  double.parse(value);
                            }
                          },
                          isMobile: isMobile,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelSection(int index, bool isMobile) {
    return Card(
      elevation: 2,
      color: const Color(0xFFF5E8F8),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: const Color(0xFF6A1B9A),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'أسعار العجل',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6A1B9A),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            isMobile
                ? Column(
                    children: [
                      _buildNumberField(
                        'النولون',
                        Icons.attach_money,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'هذا الحقل مطلوب';
                          }
                          if (double.tryParse(value) == null) {
                            return 'يجب إدخال رقم صحيح';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            transportations[index].wheelNolon = double.parse(
                              value,
                            );
                          }
                        },
                        isMobile: isMobile,
                      ),
                      SizedBox(height: 12),
                      _buildNumberField(
                        'المبيت',
                        Icons.hotel,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'هذا الحقل مطلوب';
                          }
                          if (double.tryParse(value) == null) {
                            return 'يجب إدخال رقم صحيح';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            transportations[index].wheelOvernight =
                                double.parse(value);
                          }
                        },
                        isMobile: isMobile,
                      ),
                      SizedBox(height: 12),
                      _buildNumberField(
                        'العطلة',
                        Icons.beach_access,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'هذا الحقل مطلوب';
                          }
                          if (double.tryParse(value) == null) {
                            return 'يجب إدخال رقم صحيح';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            transportations[index].wheelHoliday = double.parse(
                              value,
                            );
                          }
                        },
                        isMobile: isMobile,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          'النولون',
                          Icons.attach_money,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'يجب إدخال رقم صحيح';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              transportations[index].wheelNolon = double.parse(
                                value,
                              );
                            }
                          },
                          isMobile: isMobile,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildNumberField(
                          'المبيت',
                          Icons.hotel,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'يجب إدخال رقم صحيح';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              transportations[index].wheelOvernight =
                                  double.parse(value);
                            }
                          },
                          isMobile: isMobile,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildNumberField(
                          'العطلة',
                          Icons.beach_access,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'يجب إدخال رقم صحيح';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              transportations[index].wheelHoliday =
                                  double.parse(value);
                            }
                          },
                          isMobile: isMobile,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    required Function(String) onChanged,
    required bool isMobile,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
      ),
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(fontSize: isMobile ? 14 : 16),
    );
  }

  Widget _buildNumberField(
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    required Function(String) onChanged,
    required bool isMobile,
  }) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
      ),
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(fontSize: isMobile ? 14 : 16),
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving ? null : _savePriceOffer,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E86C1),
          padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          ),
        ),
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'حفظ عرض السعر',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _addTransportation() {
    setState(() {
      transportations.add(
        Transportation(
          loadingLocation: '',
          unloadingLocation: '',
          vehicleType: '',
          nolon: 0.0,
          companyOvernight: 0.0,
          companyHoliday: 0.0,
          wheelNolon: 0.0,
          wheelOvernight: 0.0,
          wheelHoliday: 0.0,
        ),
      );
    });
  }

  void _removeTransportation(int index) {
    setState(() {
      transportations.removeAt(index);
    });
  }

  void _savePriceOffer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final priceOffer = PriceOffer(
        companyId: widget.companyId,
        companyName: widget.companyName,
        transportations: transportations,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('companies')
          .doc(widget.companyId)
          .collection('priceOffers')
          .add(priceOffer.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ عرض السعر بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الحفظ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }
}
