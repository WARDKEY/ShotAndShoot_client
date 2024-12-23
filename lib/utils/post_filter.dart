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
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: ElevatedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.0),
                ),
              ),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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

                      ..._filters.keys.map((filter) {
                        return StatefulBuilder(builder: (context, _setState) => CheckboxListTile(
                          activeColor: Color(0xff748d6f),
                          title: Text(filter),
                          value: _filters[filter],
                          onChanged: (value) {
                            _setState(() => _filters[filter] = value!);
                          },
                        ),
                        );
                      }),

                      SizedBox (
                        width: double.infinity, // 가로로 꽉 차게 설정
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onApply(_filters);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff748d6f), // 배경색: 녹색
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0), // BorderRadius 6으로 설정
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.0), // 세로 패딩
                          ),
                          child: Text("필터 적용"),
                        ),
                      )

                    ],
                  ),
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            side: BorderSide(
              color: Colors.black, // 테두리 색상
              width: 1.0, // 테두리 두께
            ),
            elevation: 0,
            iconColor: Colors.black,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // 버튼의 둥근 모서리
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ), // 버튼 내부 여백
          ),
          icon: Icon(Icons.filter_list),
          label: Text("필터"),
        ),
      ),
    );
  }
}
