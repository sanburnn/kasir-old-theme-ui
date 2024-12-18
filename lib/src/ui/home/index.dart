import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kasir_app/src/config/constans_config.dart';
import 'package:kasir_app/src/config/size_config.dart';
import 'package:kasir_app/src/controller/cart_controller.dart';
import 'package:kasir_app/src/controller/product_controller.dart';
import 'package:kasir_app/src/model/product_model.dart';
import 'package:kasir_app/src/repository/sqlite_cart.dart';
import 'package:kasir_app/src/ui/components/custom_components.dart';
import 'package:kasir_app/src/ui/components/modal.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeUI extends StatefulWidget {
  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  final conProduct = Get.put(ProductController());
  final conCart = Get.find<CartController>();

  ScanResult? scanResult;

  final _refreshController = RefreshController(initialRefresh: false);
  final _formSearch = TextEditingController();
  bool _isSearch = false;
  bool _isQR = false;

  ProductModel? _productFrom;
  final _formName = TextEditingController();
  final _formPrice = TextEditingController();
  final _formQty = TextEditingController();

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));

    conProduct.isLoading.value = true;
    conProduct.getProduct(1);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));

    conProduct.getProduct(conProduct.productPage.value + 1);
    if (mounted) setState(() {});

    _refreshController.loadComplete();
  }

  @override
  void initState() {
    conProduct.getProduct(1);
    conCart.getCart();
    super.initState();
  }

  Future<void> _searchQr() async {
    try {
      final result = await BarcodeScanner.scan(
        options: ScanOptions(
          strings: {
            'cancel': 'Kembali ',
            'flash_on': '',
            'flash_off': '',
          },
          restrictFormat: selectedFormats,
          useCamera: -1,
          autoEnableFlash: false,
          android: const AndroidOptions(
            aspectTolerance: 0.00,
            useAutoFocus: true,
          ),
        ),
      );
      setState(() {
        scanResult = result;
        _isQR = true;
      });

      conProduct.search.value = result.rawContent;
      conProduct.getProduct(1);
    } on PlatformException catch (e) {
      setState(() {
        scanResult = ScanResult(
          type: ResultType.Error,
          format: BarcodeFormat.unknown,
          rawContent: e.code == BarcodeScanner.cameraAccessDenied
              ? 'The user did not grant the camera permission!'
              : 'Unknown error: $e',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: height(context) * 0.01),
          Container(
            width: width(context),
            height: height(context) * 0.04,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: _isSearch
                ? CustomTextField(
                    controller: _formSearch,
                    hintText: "Cari Produk",
                    onChanged: (value) {
                      conProduct.search.value = value;
                      conProduct.getProduct(1);
                    },
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          _isSearch = !_isSearch;
                        });

                        conProduct.search.value = '';
                        _formSearch.clear();
                        conProduct.getProduct(1);
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.black87,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Produk',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isSearch = !_isSearch;
                              });
                            },
                            child: const Icon(
                              Icons.search,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: _isQR
                                ? () {
                                    setState(() {
                                      _isQR = !_isQR;
                                    });

                                    conProduct.search.value = '';
                                    _formSearch.clear();
                                    conProduct.getProduct(1);
                                  }
                                : _searchQr,
                            child: Icon(
                              Icons.qr_code,
                              color: _isQR ? Colors.red : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          SizedBox(height: height(context) * 0.02),
          Obx(() {
            final products = conProduct.listProduct.value;

            if (conProduct.isLoading.value) {
              return Container(
                height: height(context) * 0.8,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    for (var i = 0; i < 8; i++)
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: CustomShimmer(
                          width: width(context),
                          height: width(context) * 0.2,
                          radius: 10,
                        ),
                      )
                  ],
                ),
              );
            }

            if (products.isEmpty) {
              return Container(
                height: height(context) * 0.8,
                child: CustomEmptyData(
                  height: height(context) * 0.9,
                  text: 'Data tidak ditemukan',
                  onPressed: () async {
                    conProduct.isLoading.value = true;
                    conProduct.getProduct(1);
                  },
                ),
              );
            }

            return Container(
              height: height(context) * 0.8,
              child: CustomRefresh(
                controller: _refreshController,
                onRefresh: () => _onRefresh(),
                onLoading: () => _onLoading(),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    ...products.map((e) => _itemProductList(context, e)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Widget _itemProductGrid(BuildContext context, ProductModel item) {
  //   return Container(
  //     width: double.infinity,
  //     margin: EdgeInsets.symmetric(horizontal: 6),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(10),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black12,
  //           offset: Offset(0, 3),
  //           blurRadius: 6,
  //         ),
  //       ],
  //     ),
  //     child: Stack(
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             CustomImageNetwork(
  //               item.image ?? '',
  //               width: double.infinity,
  //               height: width(context) * 0.4,
  //             ),
  //             SizedBox(height: 6),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 10),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     item.name ?? '-',
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(
  //                       fontSize: 16,
  //                       color: Colors.black45,
  //                       fontWeight: FontWeight.w600,
  //                       height: 1.2,
  //                     ),
  //                   ),
  //                   SizedBox(height: 4),
  //                   Text(
  //                     item.unit ?? '-',
  //                     style: TextStyle(
  //                       fontSize: 10,
  //                       color: Colors.black45,
  //                       fontWeight: FontWeight.w400,
  //                       height: 1.2,
  //                     ),
  //                   ),
  //                   SizedBox(height: 6),
  //                   Text(
  //                     toRupiah(double.parse(item.price ?? "0")),
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       color: Colors.black45,
  //                       fontWeight: FontWeight.w600,
  //                       height: 1.2,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //         Positioned(
  //           bottom: 10,
  //           right: 10,
  //           child: Container(
  //             width: 40,
  //             height: 40,
  //             decoration: BoxDecoration(
  //               color: Colors.grey[100],
  //               borderRadius: BorderRadius.circular(10),
  //               border: Border.all(color: Colors.black12),
  //             ),
  //             child: IconButton(
  //                 padding: EdgeInsets.zero,
  //                 icon: Icon(
  //                   Icons.add,
  //                   size: 30,
  //                   color: Colors.black45,
  //                 ),
  //                 onPressed: () {
  //                   // conCart.status.value = "new";
  //                   conCart.addCart(CartModel(
  //                     item.id!,
  //                     int.parse(item.price!),
  //                     1,
  //                     item,
  //                   ));
  //                 }),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _itemProductList(BuildContext context, ProductModel item) {
    final cart = conCart.listCart.firstWhere(
      (element) => element.id == item.id,
      orElse: () => CartDBModel.fromMap({'_id': 0}),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                if (item.description != null) const SizedBox(height: 4),
                if (item.description != null)
                  Text(
                    item.description ?? '-',
                    overflow: TextOverflow.clip,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  item.unit ?? '-',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black45,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  toRupiah(double.parse((item.price).toString() ?? "0")),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          cart.id == 0
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.black45,
                    ),
                    onPressed: () {
                      setState(() {
                        _formName.text = item.name ?? '';
                        _formPrice.text = item.price.toString() ?? '';
                        _formQty.text = 1.toString();

                        _productFrom = item;
                      });

                      _openModal(context);
                    },
                  ),
                )
              : const Spacer(),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  _openModal(BuildContext context) {
    Modals.showModal(
      title: 'Keranjang',
      subTitle: '',
      subTitleWidget: Container(
        width: width(context) * 0.8,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: height(context) * 0.01),
            CustomTextField(
              controller: _formName,
              hintText: "Nama Barang",
              prefixIcon: const Icon(Icons.add_box),
              readOnly: true,
            ),
            SizedBox(height: height(context) * 0.01),
            CustomTextField(
              controller: _formPrice,
              hintText: "Uang Harga",
              prefixIcon: const Icon(Icons.money),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: height(context) * 0.01),
            CustomTextField(
              controller: _formQty,
              hintText: "Banyak",
              prefixIcon: const Icon(Icons.numbers),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: height(context) * 0.02),
            // button ok
            SizedBox(
              width: width(context),
              height: height(context) * 0.04,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  conCart.addCart(
                    CartDBModel.fromMap({
                      '_id': _productFrom!.id,
                      'name': _productFrom!.name,
                      'unit': _productFrom!.unit,
                      'price': int.parse(_formPrice.text),
                      'qty': int.parse(_formQty.text),
                    }),
                  );

                  setState(() {
                    _formName.clear();
                    _formPrice.clear();
                    _formQty.clear();
                  });
                  Navigator.pop(context);
                },
                child: const Text("OK", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
