import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shotandshoot/utils/company_list.dart';

import '../models/company.dart';
import '../service/api_service.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final ApiService _apiService = ApiService();
  late Map<String, double> _currentLocation = {}; // 현재 위치
  late Future<List<Company>> _companies;

  Future<List<Company>> fetchCompany() async {
    try {
      final companyData = await _apiService.fetchCompanies();

      const latLng = NLatLng(35.17407924, 126.8265393); //현재위치

      List<Company> companies = companyData.map((company) {
        double companyLat = double.parse(company.lat);
        double companyLot = double.parse(company.lot);

        var distance = latLng.distanceTo(NLatLng(companyLat, companyLot));
        company.distance = distance; // 계산된 거리 할당

        return company;
      }).toList();

      companies.sort((a, b) => a.distance!.compareTo(b.distance!));
      return companies;
    } catch (e) {
      print("에러 $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _permission();
    _companies = fetchCompany();
  }

  Future<void> _permission() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;
    if (requestStatus.isGranted) {
      //await _getCurrentLocation();
    } else if (requestStatus.isPermanentlyDenied ||
        status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 5));

      setState(() {
        _currentLocation = {
          "latitude": position.latitude,
          "longitude": position.longitude,
        };
      });
      print(_currentLocation);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Company>>(
      future: _companies,
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // 에러처리
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // 데이터가 없는 경우 처리
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        List<Company> companies = snapshot.data!;

        return buildNaverMap(companies);
      },
    );
  }

  Widget buildNaverMap(List<Company> companies) {
    return Stack(
      children: [
        //--------------------네이버맵-----------------
        NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(35.17407924, 126.8265393),
              zoom: 13,
            ),
            locationButtonEnable: true,
          ),
          forceGesture: false,
          onMapReady: (controller) {
            var marker = NMarker(
              id: "현재 위치",
              position: NLatLng(35.17407924, 126.8265393),
            );
            controller.addOverlay(marker);
            marker.setSize(Size(40, 40));
            marker.setIcon(
                NOverlayImage.fromAssetImage("images/current_location.png"));

            for (int i = 0; i < companies.length; i++) {
              var company = companies[i];
              var marker = NMarker(
                id: company.companyName,
                position: NLatLng(
                  double.parse(company.lat),
                  double.parse(company.lot),
                ),
              );
              controller.addOverlay(marker);

              var onMarkerInfoWindow = NInfoWindow.onMarker(
                id: marker.info.id,
                text: company.companyName,
              );
              marker.openInfoWindow(onMarkerInfoWindow);
              marker.setOnTapListener((NMarker marker) {
                print(marker.info.id);
              });
            }
          },
          onMapTapped: (point, latLng) {},
          onSymbolTapped: (symbol) {},
          onCameraChange: (position, reason) {},
          onCameraIdle: () {},
          onSelectedIndoorChanged: (indoor) {},
        ),

        //----------------하단 바텀시트---------------
        Positioned.fill(
          child: DraggableScrollableSheet(
            initialChildSize: 0.4, // 초기 높이 (40%)
            minChildSize: 0.1, // 최소 높이 (10%)
            maxChildSize: 0.85, // 최대 높이 (90%)
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: Text(
                        "🏴 분리수거 대행업체",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),
                    ...companies.map((company) {
                      return CompanyList(
                        company: company,
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),

        //----------------상단 검색창---------------
        Positioned(
          top: 30.0,
          left: 16.0,
          right: 16.0,
          child: Container(
            padding: EdgeInsets.fromLTRB(13, 10, 13, 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "대행업체명으로 검색",
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                print("검색어: $value");
              },
            ),
          ),
        ),
      ],
    );
  }
}
