import 'package:flutter/material.dart';

class PostFilter extends StatefulWidget {
  final Map<String, bool> filters;
  final Function(Map<String, bool>) onApply;

  const PostFilter({super.key, required this.filters, required this.onApply});

  @override
  State<PostFilter> createState() => _PostFilterState();
}

class _PostFilterState extends State<PostFilter> {
  late Map<String, bool> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.filters);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: ElevatedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 필터 개수만큼 높이 조절됨
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "폐기물 카테고리 필터",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),

                      ListView.builder(
                        shrinkWrap: true, // 높이를 자동으로 조절
                        physics: NeverScrollableScrollPhysics(), // 내부 스크롤 방지
                        itemCount: _filters.length,
                        itemBuilder: (context, index) {
                          String filter = _filters.keys.elementAt(index);
                          return StatefulBuilder(
                            builder: (context, _setState) {
                              return CheckboxListTile(
                                activeColor: Color(0xff748d6f),
                                title: Text(filter),
                                value: _filters[filter],
                                onChanged: (value) {
                                  _setState(() => _filters[filter] = value!);
                                },
                              );
                            },
                          );
                        },
                      ),

                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onApply(_filters);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff748d6f),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          child: Text("필터 적용"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            side: BorderSide(color: Colors.black, width: 1.0),
            elevation: 0,
            iconColor: Colors.black,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
          icon: Icon(Icons.filter_list),
          label: Text("필터"),
        ),
      ),
    );
  }
}