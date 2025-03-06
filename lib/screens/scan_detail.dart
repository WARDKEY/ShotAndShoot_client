import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shotandshoot/models/scanInfo.dart';
import 'package:shotandshoot/service/api_service.dart';

import '../provider/app_state_provider.dart';

class ScanDetail extends StatefulWidget {
  final File file;

  const ScanDetail({super.key, required this.file});

  @override
  State<ScanDetail> createState() => _ScanDetailState();
}

class _ScanDetailState extends State<ScanDetail> {
  final ApiService _apiService = ApiService();
  late Future<ScanInfo> _scanInfoFuture;

  Future<ScanInfo> uploadImage(File file) async {
    try {
      final response = await _apiService.postWasteImage(file);
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseBody);
        return ScanInfo.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
      throw Exception('Error uploading image: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _scanInfoFuture = uploadImage(widget.file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text('분석 결과'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AppState>(context, listen: false).onItemTapped(2);
            },
          ),
        ],
      ),
      body: FutureBuilder<ScanInfo>(
        future: _scanInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final scanInfo = snapshot.data!;
            return _buildScanInfoView(scanInfo);
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildScanInfoView(ScanInfo scanInfo) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Image.memory(base64Decode(scanInfo.imgUrl)),
              const SizedBox(height: 16),
              ...scanInfo.predictions.map((prediction) => Card(
                    color: const Color(0xfff9f9f9),
                    child: ExpansionTile(
                      shape: const Border(),
                      initiallyExpanded: true,
                      title: Text(
                        '${prediction.category} [${prediction.count}개]',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      children: [
                        ...(prediction.wasteSortingInfo ?? [])
                            .asMap()
                            .entries
                            .expand((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final parts = item.split(':');

                          return [
                            Column(
                              children: [
                                ListTile(
                                  dense: true,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: Column(
                                    children: [
                                      Text(
                                        parts[0],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        parts[1],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                if (index <
                                    (prediction.wasteSortingInfo.length - 1))
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Divider(
                                      thickness: 1,
                                      color: Color(0xffe0e0e0),
                                      height: 20,
                                    ),
                                  ),
                              ],
                            )
                          ];
                        }),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        // 하단 고정 버튼
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2), // 그림자의 색상
                    offset: Offset(0, -3), // 위쪽으로 그림자 위치
                    blurRadius: 5, // 흐림 정도
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Provider.of<AppState>(context, listen: false).onItemTapped(2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff748d6f), // 버튼 배경색 초록
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // borderRadius 5
                  ),
                ),
                child: const Text(
                  '다시 찍기',
                  style: TextStyle(fontSize: 18, color: Colors.white), // 글씨 흰색
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
