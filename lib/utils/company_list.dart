import 'package:flutter/material.dart';
import 'package:shotandshoot/models/company.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyList extends StatelessWidget {
  final Company company;

  const CompanyList({super.key, required this.company});

  Future<void> _launchPhone() async {
    final phoneUrl = 'tel:${company.phoneNumber}';
    if (await canLaunchUrl(Uri.parse(phoneUrl))) {
      await launchUrl(Uri.parse(phoneUrl));
    } else {
      throw 'Could not launch $phoneUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.place),
      title: Text(
        company.companyName.toString(),
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company.address.toString(),
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 4.0), // 간격 추가
          Text(
            "${company.distance?.toStringAsFixed(0)} m",
            style: TextStyle(
                color: Color(0xffac2323),
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.phone, color: Color(0xffac2323)),
        onPressed: () {
          print("전화시도");
          _launchPhone;
        },
      ),
      onTap: () => print("Place 1 tapped"),
    );
  }
}
