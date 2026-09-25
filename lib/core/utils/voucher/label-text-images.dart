import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos/core/utils/myanmar-text-to-image.dart';
import 'package:pos/localization/company-local.dart';
import 'package:pos/localization/customer-local.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/localization/receipt-local.dart';
import 'package:pos/localization/voucher-local.dart';

class CustomerLabelImages {
  final pw.MemoryImage name;
  final pw.MemoryImage phone;
  final pw.MemoryImage address;

  const CustomerLabelImages({
    required this.name,
    required this.phone,
    required this.address,
  });
}

class CompanyLabelImages {
  final pw.MemoryImage name;
  final pw.MemoryImage phone;
  final pw.MemoryImage address;
  final pw.MemoryImage email;
  final pw.MemoryImage salePerson;

  const CompanyLabelImages({
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.salePerson,
  });
}

class SummaryLabelImages {
  final pw.MemoryImage subTotal;
  final pw.MemoryImage tax;
  final pw.MemoryImage discount;
  final pw.MemoryImage discountPercent;
  final pw.MemoryImage total;
  final pw.MemoryImage packagingFee;
  final pw.MemoryImage note;
  final pw.MemoryImage debtAmount;
  final pw.MemoryImage repayAmount;
  final pw.MemoryImage thankYou;

  const SummaryLabelImages({
    required this.subTotal,
    required this.tax,
    required this.discount,
    required this.discountPercent,
    required this.total,
    required this.packagingFee,
    required this.note,
    required this.debtAmount,
    required this.repayAmount,
    required this.thankYou, // 👈
  });
}

/// Table header (No, Product, Qty, Price, Total)
class TableHeaderLabelImages {
  final pw.MemoryImage no;
  final pw.MemoryImage product;
  final pw.MemoryImage quantity;
  final pw.MemoryImage price;
  final pw.MemoryImage total;

  const TableHeaderLabelImages({
    required this.no,
    required this.product,
    required this.quantity,
    required this.price,
    required this.total,
  });
}

class LabelTextImageInterface {
  final CustomerLabelImages customer;
  final CompanyLabelImages company;
  final SummaryLabelImages summary;
  final TableHeaderLabelImages tableHeader;

  const LabelTextImageInterface({
    required this.customer,
    required this.company,
    required this.summary,
    required this.tableHeader,
  });
}

class LabelTextImages {
  static Future<pw.MemoryImage> _toImage(String text) async {
    final bytes = await myanmarTextToImage(
      text,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    return pw.MemoryImage(bytes);
  }

  static Future<LabelTextImageInterface> getImageText(
    BuildContext context,
  ) async {
    final texts = <String, String>{
      // customer
      'cName': VoucherScreenLocale.customerName.getString(context),
      'cPhone': VoucherScreenLocale.phoneOptional.getString(context),
      'cAddress': CustomerLocale.customerAddress.getString(context),

      // company
      'coName': CompanyRegisterScreenLocal.companyName.getString(context),
      'coPhone': CompanyRegisterScreenLocal.companyPhone.getString(context),
      'coAddress': CompanyRegisterScreenLocal.companyAddress.getString(context),
      'coEmail': CompanyRegisterScreenLocal.companyEmail.getString(context),
      'coSalePerson': VoucherScreenLocale.salesperson.getString(context),

      // summary
      'subTotal': VoucherScreenLocale.subtotal.getString(context),
      'tax': VoucherScreenLocale.tax.getString(context),
      'discount': ReceiptScreenLocale.receiptDiscountAmount.getString(context),
      'discountPercent': ReceiptScreenLocale.receiptDiscountPercent.getString(
        context,
      ),
      'total': VoucherScreenLocale.total.getString(context),
      'packagingFee': VoucherScreenLocale.packagingFee.getString(context),
      'note': VoucherScreenLocale.note.getString(context),
      'debtAmount': VoucherScreenLocale.existDebt.getString(context),
      'repayAmount': VoucherScreenLocale.repay.getString(context),
      'thankYou': VoucherScreenLocale.thankYouMessage.getString(context), // 👈
      // table header
      'hNo': VoucherScreenLocale.no.getString(context),
      'hProduct': ProductScreenLocale.productTitle.getString(context),
      'hQty': VoucherScreenLocale.quantity.getString(context),
      'hPrice': VoucherScreenLocale.price.getString(context),
      'hTotal': VoucherScreenLocale.total.getString(context),
    };

    final keys = texts.keys.toList();
    final images = await Future.wait(keys.map((k) => _toImage(texts[k]!)));
    final m = Map<String, pw.MemoryImage>.fromIterables(keys, images);

    return LabelTextImageInterface(
      customer: CustomerLabelImages(
        name: m['cName']!,
        phone: m['cPhone']!,
        address: m['cAddress']!,
      ),
      company: CompanyLabelImages(
        name: m['coName']!,
        phone: m['coPhone']!,
        address: m['coAddress']!,
        email: m['coEmail']!,
        salePerson: m['coSalePerson']!,
      ),
      summary: SummaryLabelImages(
        subTotal: m['subTotal']!,
        tax: m['tax']!,
        discount: m['discount']!,
        discountPercent: m['discountPercent']!,
        total: m['total']!,
        packagingFee: m['packagingFee']!,
        note: m['note']!,
        debtAmount: m['debtAmount']!,
        repayAmount: m['repayAmount']!,
        thankYou: m['thankYou']!,
      ),
      tableHeader: TableHeaderLabelImages(
        no: m['hNo']!,
        product: m['hProduct']!,
        quantity: m['hQty']!,
        price: m['hPrice']!,
        total: m['hTotal']!,
      ),
    );
  }
}
