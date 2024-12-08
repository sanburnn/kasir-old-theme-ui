import 'package:flutter/material.dart';
import 'package:kasir_app/src/config/constans_config.dart';
import 'package:kasir_app/src/model/transaksi_model.dart';

class ShareStruk {
  static Widget struk(TransaksiModel transaksi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Toko Palapa',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Text(
              'Pertokoan Pasar Atas',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
            const Text(
              '085123123123',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tgl Trx: 12-12-2020 12:12:12',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            const Text(
              'Jml Jns Brg: 12',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            const Text(
              'Pembeli : Doni',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            const Text(
              '===========================',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            for (int i = 0; i < 4; i++)
              ...transaksi.details!.map((e) {
                String s = e.item!.unit ?? "-";
                final idx = s.split("/");

                int qty =
                    int.parse(idx[0]) * int.parse(e.quantity.toString() ?? '0');
                String unit = '$qty ${idx[1]}';

                String desc =
                    "$unit x ${toCurrency(double.parse(e.price.toString() ?? '0'))}";
                String price = toCurrency(
                    double.parse(e.price.toString() ?? '0') *
                        double.parse(e.quantity.toString() ?? '0'));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.item!.name ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            const Text(
              '===========================',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
                Text(
                  toRupiah(
                      double.parse(transaksi.totalPrice.toString() ?? '0')),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bayar',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
                Text(
                  toRupiah(
                      double.parse(transaksi.amountPaid.toString() ?? '0')),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kembali',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
                Text(
                  toRupiah(
                      double.parse(transaksi.amountPaid.toString() ?? '0') -
                          double.parse(transaksi.totalPrice.toString() ?? '0')),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Bukan jam setengah 7 pagi - 7 malam',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            const Text(
              'Terima Kasih',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            Text(
              dateFormatEEEEdMMMMyyyyhhmm(DateTime.now()),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // void onPressed(BuildContext context) async {
  //   screenshotController
  //       .capture(delay: Duration(milliseconds: 10))
  //       .then((capturedImage) async {
  //     ShowCapturedWidget(context, capturedImage!);
  //   }).catchError((onError) {
  //     print(onError);
  //   });
  // }

  // Future<dynamic> ShowCapturedWidget(
  //     BuildContext context, Uint8List capturedImage) {
  //   return showDialog(
  //     useSafeArea: false,
  //     context: context,
  //     builder: (context) => Scaffold(
  //       appBar: AppBar(
  //         backgroundColor: primaryColor,
  //         title: Text("Captured widget screenshot"),
  //       ),
  //       body: Center(
  //           child: capturedImage != null
  //               ? Image.memory(capturedImage)
  //               : Container()),
  //     ),
  //   );
  // }
}
