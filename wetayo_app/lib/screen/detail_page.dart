import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wetayo_app/model/bus_arrival.dart';
import 'package:wetayo_app/model/bus_route.dart';
import 'package:wetayo_app/model/station_routes.dart';
import 'dart:convert';
import 'package:xml2json/xml2json.dart';
import '../api/arrival_api.dart' as arrival_api;
//import '../api/route_api.dart' as route_api;
import '../api/stationRoute_api.dart' as route_api;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class DetailPage extends StatefulWidget {
  final String item;
  DetailPage({Key key, this.item}) : super(key: key);
  _DetailPage createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  final CarouselController _controller = CarouselController();
  final Xml2Json xml2Json = Xml2Json();

  List<busArrival> _data = [];
  List<stationRoutes> _routesData = [];

  bool _isLoading = false;
  String routeName = '조회를 실패했습니다.';

  @override
  void initState() {
    super.initState();
    _getRoutesList();
    _getArrivalList();
  }

  String matchRoute(String _routeId) {
    for (var item in _routesData) {
      print('plz>>${item.routeId}, prefix>>$_routeId');
      if (item.routeId.compareTo(_routeId) == 0) {
        print('compare>>${item.routeId}, ${_routeId}');
        return item.routeName;
      }
    }
    print('end');
    return 'error';
  }

  _getArrivalList() async {
    String result = 'null';
    setState(() => _isLoading = true);

    //String station = _stationController.text;
    var response = await http.get(arrival_api.buildUrl(widget.item));
    String responseBody = response.body;
    xml2Json.parse(responseBody);
    var jsonString = xml2Json.toParker();
    //print('res >> $jsonString');

    var json = jsonDecode(jsonString);
    print(json);
    Map<String, dynamic> errorMessage = json['response']['msgHeader'];

    print('errorcode >> ${errorMessage['resultCode']}');
    if (errorMessage['resultCode'] != arrival_api.STATUS_OK) {
      setState(() {
        final String errMessage = errorMessage['resultMessage'];
        print('error >> $errMessage');

        _data = const [];
        _isLoading = false;
      });
      return;
    }

    List<dynamic> busArrivalList =
        json['response']['msgBody']['busArrivalList'];
    final int cnt = busArrivalList.length;
    print('cnt >> $cnt');

    List<busArrival> list = List.generate(cnt, (int i) {
      Map<String, dynamic> item = busArrivalList[i];
      print('check>>> ${busArrivalList[i]['routeId']}');
      result = matchRoute(busArrivalList[i]['routeId']);
      return busArrival(
        item['flag'],
        item['locationNo1'],
        item['locationNo2'],
        item['lowPlate1'],
        item['lowPlate2'],
        item['plateNo1'],
        item['plateNo2'],
        item['predictTime1'],
        item['predictTime2'],
        item['remainSeatCnt1'],
        item['remainSeatCnt2'],
        item['routeId'],
        item['staOrder'],
        item['stationId'],
        item['routeName'] = result,
      );
    });

    print('list >>> ${list[0].locationNo1}');

    setState(() {
      _data = list;
      _isLoading = false;
      //matchRoute();
      print(_data[0].routeName);
    });
  }

//////////////////////////////////////////

  _getRoutesList() async {
    //setState(() => _isLoading = true);

    //String station = _stationController.text;
    var response = await http.get(route_api.buildUrl(widget.item));
    String responseBody = response.body;
    xml2Json.parse(responseBody);
    var jsonString = xml2Json.toParker();
    //print('res >> $jsonString');

    var json = jsonDecode(jsonString);
    print(json);
    Map<String, dynamic> errorMessage = json['response']['msgHeader'];

    print('errorcode >> ${errorMessage['resultCode']}');
    if (errorMessage['resultCode'] != arrival_api.STATUS_OK) {
      setState(() {
        final String errMessage = errorMessage['resultMessage'];
        print('error >> $errMessage');

        _data = const [];
        _isLoading = false;
      });
      return;
    }

    List<dynamic> stationRoutesList =
        json['response']['msgBody']['busRouteList'];
    final int cnt = stationRoutesList.length;
    print('route_cnt >> $cnt');

    List<stationRoutes> list = List.generate(cnt, (int i) {
      Map<String, dynamic> item = stationRoutesList[i];
      return stationRoutes(
        item['districtCd'],
        item['regionName'],
        item['routeId'],
        item['routeName'],
        item['routeTypeCd'],
        item['routeTypeName'],
        item['staOrder'],
      );
    });

    print('route_list >>> ${list[0].routeName}');

    setState(() {
      _routesData = list;
      print('routeTest >>>> $_routesData');
      //_isLoading = false;
    });
  }

  Widget countArriverBus(int index) {
    if (_data.length <= 0) {
      return Text('도착 정보가 없어요ㅠㅠ');
    } else {
      return Text(_data[index].routeName);
      Text(_data[index].predictTime1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                child: SafeArea(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Positioned(
                            child: AppBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                      Container(
                          child: CarouselSlider.builder(
                        itemCount: _data.length,
                        options: CarouselOptions(
                            aspectRatio: 1.0,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.vertical,
                            autoPlay: false),
                        carouselController: _controller,
                        itemBuilder: (context, index, idx) {
                          return Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                //countArriverBus(index),
                                if (_data.length > 0)
                                  Text(
                                    _data[index].routeName,
                                    style: TextStyle(
                                        fontSize: 65.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                if (_data.length > 0)
                                  Text(
                                    '도착까지 ${_data[index].predictTime1} 분',
                                    style: TextStyle(
                                        fontSize: 50.0,
                                        fontWeight: FontWeight.bold),
                                  )
                                else
                                  Text('도착 버스 정보가 없습니다.')
                              ],
                            ),
                          );
                        },
                      )),
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.08,
                            padding: EdgeInsets.all(10.0),
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.0)),
                                onPressed: () => _controller.previousPage(),
                                child: Text(
                                  '<-',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                color: Color(0xff184C88)),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.08,
                            padding: EdgeInsets.all(10.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9.0)),
                              onPressed: () => _controller.nextPage(),
                              child: Text('->',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold)),
                              color: Color(0xff184C88),
                            ),
                          )
                        ],
                      ),
                      Mutation(
                        options: MutationOptions(
                          document: gql(
                              """mutation CreateRide(\$stationId : Int!, \$routeId : Int!){
                      createRide(stationId : \$stationId, routeId : \$routeId){
                        stationId
                        routeId
                      }
                    }"""),
                          update: (GraphQLDataProxy cache, QueryResult result) {
                            return cache;
                          },
                          onError: (OperationException error) =>
                              _simpleAlert(context, error.toString()),
                          onCompleted: (dynamic resultData) =>
                              Navigator.of(context).pop(),
                        ),
                        builder: (
                          RunMutation runMutation,
                          QueryResult result,
                        ) {
                          return Container(
                            margin: EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15.0),
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('탑승 예약'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text('Test'),
                                                Text(
                                                    '${_data[_controller.getIndex()].routeName}번 버스를 탑승 하시겠습니까?'),
                                                Text(_data[
                                                        _controller.getIndex()]
                                                    .stationId),
                                                Text(_data[
                                                        _controller.getIndex()]
                                                    .routeId)
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('확인'),
                                              onPressed: () => runMutation({
                                                'stationId': _data[
                                                        _controller.getIndex()]
                                                    .stationId,
                                                'routeId': _data[
                                                        _controller.getIndex()]
                                                    .routeId,
                                              }),
                                            ),
                                            FlatButton(
                                              child: Text('취소'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: Container(
                                  child: Text(
                                    '탑승 예약',
                                    style: TextStyle(
                                        fontSize: 55.0,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                color: Color(0xff184C88)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ));
  }
}

void _simpleAlert(BuildContext context, String text) => showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          actions: <Widget>[
            SimpleDialogOption(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
