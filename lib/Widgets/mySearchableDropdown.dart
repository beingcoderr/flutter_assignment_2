import 'package:flutter/material.dart';
import 'package:flutter_assignment_2/Models/citiesModel.dart';
import 'package:flutter_assignment_2/Repositories/getController.dart';
import 'package:get/get.dart';

// class MySearchableDropdown extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: Get.size.width * 75 / 100,
//           height: 70,
//           child: OutlineButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => MyDialog(),
//               );
//             },
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Select Cities'),
//                 Icon(Icons.arrow_downward),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class MyDialog extends StatefulWidget {
  final String title;

  const MyDialog({Key key, this.title}) : super(key: key);
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final Controller _controller = Get.find();

  final _scrollController = ScrollController();
  final _textEditingController = TextEditingController();

  var _tempList = List<CitiesModel>().obs;

  void _scrollToLast() {
    Future.delayed(Duration(milliseconds: 100)).then((value) =>
        _scrollController.hasClients
            ? _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent)
            : null);
  }

  void _applyFilter(String filter) async {
    _tempList.clear();
    if (filter.isNotEmpty || filter != null) {
      var _myList = await _controller.futureCities.value;
      _myList.forEach((element) {
        if (element.name.toLowerCase().contains(filter.toLowerCase())) {
          _tempList.add(element);
        }
      });
    } else {
      _controller.futureCities.value.then((value) => _tempList = value.obs);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.futureCities.value.then((value) => _tempList = value.obs);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // title: Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     Text('Cities'),
      //     TextButton(onPressed: () {}, child: Text("Clear All")),
      //   ],
      // ),
      // titleTextStyle: TextStyle(
      //     fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // padding: EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextButton(
                    onPressed: () {
                      _controller.addedCities.clear();
                      setState(() {});
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(fontSize: 18),
                    ))
              ],
            ),
          ),
          Obx(
            () => _controller.addedCities.isNotEmpty
                ? Container(
                    height: 40,
                    alignment: Alignment.topLeft,
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: _controller.addedCities.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(50)),
                            margin: EdgeInsets.only(left: 6, right: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(_controller.addedCities[index]),
                                SizedBox(
                                  width: 6,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _controller.addedCities
                                        .remove(_controller.addedCities[index]);
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.close_sharp,
                                    size: 18,
                                  ),
                                )
                              ],
                            ));
                      },
                    ),
                  )
                : Container(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 40,
              child: TextField(
                controller: _textEditingController,
                onChanged: _applyFilter,
                decoration: InputDecoration(
                  labelText: "Search",
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CitiesModel>>(
                future: _controller.futureCities.value,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.isNotEmpty) {
                    return Obx(() => _tempList.isNotEmpty
                        ? ListView.builder(
                            itemCount: _tempList.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return CheckboxListTile(
                                value: _controller.addedCities
                                    .contains(_tempList[index].name),
                                onChanged: (value) {
                                  if (_controller.addedCities
                                      .contains(_tempList[index].name)) {
                                    _controller
                                        .removeCity(_tempList[index].name);
                                  } else {
                                    _controller.addCity(_tempList[index].name);
                                    _scrollToLast();
                                  }
                                  setState(() {});
                                },
                                title: Text(_tempList[index].name),
                              );
                            },
                          )
                        : Container(
                            child: Text('No results found'),
                          ));
                  }
                  return Container();
                }),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('OK'))
            ],
          )
        ],
      ),
    );
  }
}
