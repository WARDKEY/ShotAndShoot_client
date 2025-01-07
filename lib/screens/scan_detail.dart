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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Image.memory(base64Decode(scanInfo.imgUrl)),
        const SizedBox(height: 16),
        ...scanInfo.predictions.map((prediction) => Card(
              color: Color(0xfff9f9f9),
              child: ExpansionTile(
                shape: const Border(),
                initiallyExpanded: true,
                title: Text('${prediction.category} [${prediction.count}]'),
                children: (prediction.wasteSortingInfo ?? [])
                    .map((item) => ListTile(
                          dense: true,
                          visualDensity:
                              VisualDensity(horizontal: 0, vertical: -4),
                          title: Text(
                            item,
                            style: TextStyle(fontSize: 16),
                          ),
                        ))
                    .toList(),
              ),
            )),
      ],
    );
  }
}
