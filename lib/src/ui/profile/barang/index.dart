import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kasir_app/src/config/constans_config.dart';
import 'package:kasir_app/src/config/size_config.dart';
import 'package:kasir_app/src/controller/deleteitem_controller.dart';
import 'package:kasir_app/src/controller/product_controller.dart';
import 'package:kasir_app/src/model/product_model.dart';
import 'package:kasir_app/src/ui/components/custom_components.dart';
import 'package:kasir_app/src/ui/components/modal.dart';
import 'package:kasir_app/src/ui/profile/barang/edit.dart';
import 'package:kasir_app/src/ui/profile/barang/tambah.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListBarang extends StatefulWidget {
  static const routeName = '/profile/barang';
  // const ListBarang({super.key});

  @override
  State<ListBarang> createState() => _ListBarangState();
}

class _ListBarangState extends State<ListBarang> {
  bool _isSearch = false;
  final _formSearch = TextEditingController();
  final conProduct = Get.put(ProductController());
  DeleteItemController deleteItem = Get.put(DeleteItemController());
  final _refreshController = RefreshController(initialRefresh: false);
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
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
                          conProduct.getProduct(1);
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: width(context) * 0.02),
                        Text(
                          'Daftar Barang',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isSearch = !_isSearch;
                              });
                              _formSearch.clear();
                              conProduct.getProduct(1);
                            },
                            child: Icon(
                              Icons.search,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: height(context) * 0.02),
            Column(
              children: [
                Obx(() {
                  final products = conProduct.listProduct.value;

                  if (conProduct.isLoading.value) {
                    return Container(
                      height: height(context) * 0.82,
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
                      height: height(context) * 0.82,
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

                  return AnimatedContainer(
                    height: height(context) * 0.82,
                    duration: const Duration(seconds: 1),
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
            SizedBox(height: height(context) * 0.02),
            Container(
              width: width(context),
              height: height(context) * 0.04,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Get.toNamed(TambahBarang.routeName),
                child: Text("Tambah", style: TextStyle(fontSize: 18)),
              ),
            ),
            SizedBox(height: height(context) * 0.01),
          ],
        ),
      ),
    );
  }

  Widget _itemProductList(BuildContext context, ProductModel item) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // CustomImageNetwork(
          //   item.image ?? '',
          //   width: width(context) * 0.2,
          //   height: width(context) * 0.2,
          // ),
          // SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? '-',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                if (item.description != null) SizedBox(height: 4),
                if (item.description != null)
                  Text(
                    item.description ?? '-',
                    overflow: TextOverflow.clip,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                SizedBox(height: 4),
                Text(
                  item.unit ?? '-',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black45,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  toRupiah(double.parse((item.price).toString() ?? "0")),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () => Get.toNamed(
              EditBarang.routeName,
              arguments: [
                item.id,
                item.code1,
                item.code2,
                item.code3,
                item.code4,
                item.code5,
                item.code6,
                item.code7,
                item.code8,
                item.code9,
                item.code10,
                item.name,
                item.description,
                item.unit,
                item.takePrice.toString(),
                item.price.toString(),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.amber.shade300,
              ),
              child: const Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Modals.showModal(
                title: 'Peringatan',
                subTitle: 'Apakah anda yakin ingin menghapus data ini?',
                confirmText: 'Ya',
                confirmAction: () {
                  deleteItem.hapusProduk(item.id!);
                  _onRefresh();
                },
                cancleText: 'Tidak',
                cancleAction: () => Get.back(),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.red),
              child: const Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
