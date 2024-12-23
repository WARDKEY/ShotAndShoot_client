import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shotandshoot/utils/company_list.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  late Map<String, double> _currentLocation = {};

  List<Map<String, dynamic>> companies = [
    {
      "id": 1,
      "name": "폐기물업체1",
      "address": "경기도 양주시 백석읍dddddddddddddddddddddddddddddddddddddddddd",
      "latitude": "37.506932467450326",
      "longitude": "127.05578661133796",
    },
    {
      "id": 2,
      "name": "폐기물업체2",
      "address": "경기도 의정부시 가능동",
      "latitude": "37.606932467450399",
      "longitude": "127.05578661133711",
    }
  ];

  @override
  void initState() {
    super.initState();
    _permission();
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
    return Stack(
      children: [
        // 네이버 지도
        NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(
                37.5666,
                126.979,
              ),
              zoom: 13,
            ),
            locationButtonEnable: true,
          ),
          forceGesture: false,
          onMapReady: (controller) {
            var marker = NMarker(
              id: "현재 위치",
              position: NLatLng(37.5666, 126.979),
            );
            controller.addOverlay(marker);
            marker.setSize(Size(40, 40));
            marker.setIcon(
                NOverlayImage.fromAssetImage("images/current_location.png"));

            for (int i = 0; i < companies.length; i++) {
              var marker = NMarker(
                id: companies[i]['id'].toString(),
                position: NLatLng(
                  double.parse(companies[i]['latitude']),
                  double.parse(companies[i]['longitude']),
                ),
              );
              controller.addOverlay(marker);

              var onMarkerInfoWindow = NInfoWindow.onMarker(
                id: marker.info.id,
                text: companies[i]['name'].toString(),
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
                      return CompanyList(company: company,);
                    }),
                  ],
                ),
              );
            },
          ),
        ),
        // 상단 검색창
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
