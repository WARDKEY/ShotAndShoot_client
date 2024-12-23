import 'package:flutter/material.dart';

class CompanyList extends StatelessWidget {
  final Map<String, dynamic> company;

  const CompanyList({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.place),
      title: Text(
        company['name'].toString(),
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company['address'].toString(),
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 4.0), // 간격 추가
          Text(
            "135m",
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
          print("전화걸기");
        },
      ),
      onTap: () => print("Place 1 tapped"),
    );
  }
}
