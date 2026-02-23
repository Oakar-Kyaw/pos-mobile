import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/localization/company-local.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final voucherByIdProvider = FutureProvider.family<VoucherDetailModel, int>((
  ref,
  id,
) async {
  final notifier = ref.read(voucherProvider.notifier);
  return await notifier.getVoucherById(id);
});

class ReceiptPage extends ConsumerWidget {
  final int id;

  const ReceiptPage({super.key, required this.id});

  /// Helper: format price/amount
  String formatAmount(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString(); // hide .00
    } else {
      return value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherAsync = ref.watch(voucherByIdProvider(id));

    return SafeArea(
      child: Scaffold(
        body: voucherAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error: $err")),
          data: (voucher) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// ================= HEADER =================
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                if (voucher.company?.photoUrl != null &&
                                    voucher.company!.photoUrl!.isNotEmpty)
                                  Container(
                                    height: 70,
                                    width: 70,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          voucher.company!.photoUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                Text(
                                  voucher.company?.name ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),
                                Text(
                                  "${CompanyRegisterScreenLocal.companyPhone.getString(context)}: ${voucher.company?.phone ?? ''}",
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${CompanyRegisterScreenLocal.companyAddress.getString(context)}: ${voucher.company?.address ?? ''}",
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                Text(
                                  VoucherScreenLocale.receipt.getString(
                                    context,
                                  ),
                                  style: TextStyle(
                                    fontSize: FontSizeConfig.title(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(),
                              ],
                            ),

                            const SizedBox(height: 20),

                            /// ================= ITEM TABLE =================
                            Table(
                              columnWidths: const {
                                0: FlexColumnWidth(5),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(2),
                                3: FlexColumnWidth(2),
                              },
                              children: [
                                // Table Header
                                TableRow(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  children: [
                                    _buildTableHeader(
                                      VoucherScreenLocale.item.getString(
                                        context,
                                      ),
                                      context,
                                    ),
                                    _buildTableHeader(
                                      VoucherScreenLocale.price.getString(
                                        context,
                                      ),
                                      context,
                                    ),
                                    _buildTableHeader(
                                      VoucherScreenLocale.quantity.getString(
                                        context,
                                      ),
                                      context,
                                    ),
                                    _buildTableHeader(
                                      VoucherScreenLocale.amount.getString(
                                        context,
                                      ),
                                      context,
                                      alignRight: true,
                                    ),
                                  ],
                                ),

                                // Table Rows
                                ...voucher.items.map(
                                  (item) => TableRow(
                                    children: [
                                      _buildTableCell(item.name),
                                      _buildTableCell(formatAmount(item.price)),
                                      _buildTableCell(item.quantity.toString()),
                                      _buildTableCell(
                                        formatAmount(
                                          item.price * item.quantity,
                                        ),
                                        alignRight: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Divider(),
                            const SizedBox(height: 10),

                            /// ================= TOTALS =================
                            _receiptRow(
                              context,
                              VoucherScreenLocale.subtotal.getString(context),
                              voucher.subTotal,
                            ),
                            _receiptRow(
                              context,
                              VoucherScreenLocale.tax.getString(context),
                              voucher.tax,
                            ),
                            _receiptRow(
                              context,
                              PaymentScreenLocale.deliveryFee.getString(
                                context,
                              ),
                              voucher.deliveryFee,
                            ),
                            const Divider(),
                            _receiptRow(
                              context,
                              VoucherScreenLocale.total.getString(context),
                              voucher.total,
                              isBold: true,
                            ),

                            const SizedBox(height: 20),

                            /// ================= PAYMENTS =================
                            ...voucher.payments.map(
                              (payment) => _receiptRow(
                                context,
                                payment.paymentData?.accountName ?? '',
                                payment.amount,
                              ),
                            ),
                            const Divider(),
                            _receiptRow(
                              context,
                              PaymentScreenLocale.paymentRemainingAmount
                                  .getString(context),
                              voucher.remainingPaymentAmount,
                              isBold: true,
                            ),

                            const SizedBox(height: 30),

                            /// ================= PRINT BUTTON =================
                            ShadButton(
                              onPressed: () {},
                              child: Text(
                                VoucherScreenLocale.printReceipt.getString(
                                  context,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            /// ================= THANK YOU =================
                            Text(
                              VoucherScreenLocale.thankYouMessage.getString(
                                context,
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                height: 1.8,
                                fontSize: FontSizeConfig.title(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// ================= HELPERS =================
  Widget _receiptRow(
    BuildContext context,
    String label,
    double value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            formatAmount(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(
    String text,
    BuildContext context, {
    bool alignRight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          textAlign: TextAlign.center,
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSizeConfig.body(context),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          textAlign: TextAlign.center,
          text,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
