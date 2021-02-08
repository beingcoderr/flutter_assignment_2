import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment_2/Models/citiesModel.dart';
import 'package:flutter_assignment_2/Models/countriesModel.dart';
import 'package:flutter_assignment_2/Models/statesModel.dart';
import 'package:flutter_assignment_2/Repositories/getController.dart';
import 'package:flutter_assignment_2/Repositories/locationRepository.dart';
import 'package:flutter_assignment_2/Widgets/mySearchableDropdown.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assignment',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _locationRepository = LocationRepository();
  Future<List<CountriesModel>> _countries;
  Future<List<StatesModel>> _states;
  Future<List<CitiesModel>> _cities;
  CountriesModel _selectedCountry;
  StatesModel _selectedState;
  CitiesModel _selectedCity;
  final Controller c = Get.put(Controller());

  @override
  void initState() {
    super.initState();

    _countries = _locationRepository.getCountries().then((value) {
      value.firstWhere((element) {
        if (element.name == "India") {
          _selectedCountry = element;
          return true;
        }
        return false;
      });
      return value;
    });
    _states = _locationRepository.getStates("IN");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select location"),
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          FutureBuilder<List<CountriesModel>>(
            future: _countries,
            builder: (BuildContext context,
                AsyncSnapshot<List<CountriesModel>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                );
              }
              if (!snapshot.hasData &&
                  snapshot.connectionState != ConnectionState.waiting) {
                return Text('Something went wrong');
              }
              if (snapshot.hasData &&
                  snapshot.connectionState != ConnectionState.waiting) {
                return MyDropDown(
                  child: DropdownSearch<CountriesModel>(
                    mode: Mode.BOTTOM_SHEET,
                    showSearchBox: true,
                    selectedItem: _selectedCountry,
                    autoFocusSearchBox: true,
                    label: "Select Country",
                    items: snapshot.data,
                    searchBoxDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Search Country",
                        hintText: "Search Country"),
                    itemAsString: (item) => item.name,
                    onChanged: (value) {
                      setState(() {
                        _states = _locationRepository.getStates(value.iso2);
                        _selectedCountry = value;
                        _cities = null;
                        _selectedState = null;
                        _selectedCity = null;
                      });
                    },
                  ),
                );
              }
              return Container();
            },
          ),
          FutureBuilder<List<StatesModel>>(
            future: _states,
            builder: (BuildContext context,
                AsyncSnapshot<List<StatesModel>> snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState != ConnectionState.waiting) {
                return MyDropDown(
                  child: DropdownSearch<StatesModel>(
                    mode: Mode.BOTTOM_SHEET,
                    showSearchBox: true,
                    selectedItem: _selectedState,
                    autoFocusSearchBox: true,
                    label: "Select State",
                    items: snapshot.data,
                    searchBoxDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Search State",
                        hintText: "Search State"),
                    itemAsString: (item) => item.name,
                    onChanged: (value) {
                      c.futureCities.value = _locationRepository.getCities(
                          value.iso2, _selectedCountry.iso2);
                    },
                  ),
                );
              }
              return Container();
            },
          ),
          Obx(
            () => FutureBuilder<List<CitiesModel>>(
              future: c.futureCities.value,
              builder: (BuildContext context,
                  AsyncSnapshot<List<CitiesModel>> snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState != ConnectionState.waiting &&
                    snapshot.data.isNotEmpty) {
                  return Column(
                    children: [
                      Container(
                        width: Get.size.width * 75 / 100,
                        height: 70,
                        child: OutlineButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => MyDialog(
                                title: "Select Cities",
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Select Cities'),
                              Icon(Icons.arrow_downward),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                  // return MyDropDown(
                  //   child: DropdownSearch<CitiesModel>(
                  //     mode: Mode.BOTTOM_SHEET,
                  //     showSearchBox: true,
                  //     itemAsString: (item) => item.name,
                  //     selectedItem: _selectedCity,
                  //     autoFocusSearchBox: true,
                  //     label: "Select City",
                  //     items: snapshot.data,
                  //     searchBoxDecoration: InputDecoration(
                  //         border: OutlineInputBorder(),
                  //         labelText: "Search City",
                  //         hintText: "Search City"),
                  //     onChanged: (value) {
                  //       if (!c.addedCities.contains(value.name)) {
                  //         c.addedCities.add(value.name);
                  //       } else {
                  //         Get.showSnackbar(GetBar(
                  //           message: "City already addded",
                  //           duration: Duration(seconds: 2),
                  //         ));
                  //       }
                  //       print(c.addedCities);
                  //     },
                  //   ),
                  // );
                }
                return Container();
              },
            ),
          ),
          Obx(() => c.addedCities.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Added Cities",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      children: List.generate(
                          c.addedCities.length,
                          (index) => AddedCity(
                                  child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(c.addedCities[index]),
                                  GestureDetector(
                                    onTap: () {
                                      final Controller _c = Get.find();
                                      _c.addedCities.removeAt(index);
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ))),
                    ),
                  ],
                )
              : Container()),
          // Container(
          //     height: 100,
          //     child: ListView.builder(
          //       itemCount: addedCities.length,
          //       scrollDirection: Axis.horizontal,
          //       physics: NeverScrollableScrollPhysics(),
          //       shrinkWrap: true,
          //       itemBuilder: (BuildContext context, int index) {
          //         return Row(
          //           children: [
          //             AddedCity(child: Text(addedCities[index])),
          //           ],
          //         );
          //       },
          //     ),
          //   )
        ],
      ),
    );
  }
}

class MyDropDown extends StatelessWidget {
  final Widget child;

  const MyDropDown({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.all(12),
          alignment: Alignment.center,
          width: Get.width * 75 / 100,
          child: child,
        ),
      ],
    );
  }
}

class AddedCity extends StatelessWidget {
  final Widget child;

  const AddedCity({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12, right: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
