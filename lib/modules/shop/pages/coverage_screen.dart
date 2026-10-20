import 'package:flutter/material.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import 'package:nubesim/ui/custom_appbar.dart';

class CoverageScreen extends StatelessWidget {
  final List<LocationNetworkList> locations;
  const CoverageScreen({super.key,required this.locations});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(title: "Supported Countries"),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: 
      (context, index){
        return ListTile(
          title: Text(locations[index].locationName),
          // subtitle: Text(locations[index].operatorList.length.toString()),
          leading: Image.network("https://static.redteago.com${locations[index].locationLogo}", height: 40,),
        );
      }),
    );
  }
}