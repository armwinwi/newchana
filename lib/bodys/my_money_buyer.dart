import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppingmall/bodys/wallet.dart';
import 'package:shoppingmall/models/wallet_model.dart';
import 'package:shoppingmall/utility/my_constant.dart';
import 'package:shoppingmall/widgets/show_no_data.dart';
import 'package:shoppingmall/widgets/show_progress.dart';

class MyMoneyBuyer extends StatefulWidget {
  const MyMoneyBuyer({Key? key}) : super(key: key);

  @override
  _MyMoneyBuyerState createState() => _MyMoneyBuyerState();
}

class _MyMoneyBuyerState extends State<MyMoneyBuyer> {
  int indexWidget = 0;
  var widgets = <Widget>[];

  var titles = <String>[
    'infect',
  ];

  var iconDatas = <IconData>[
    Icons.money,
    Icons.fact_check,
    Icons.hourglass_bottom,
  ];

  var bottonNavigationBarItems = <BottomNavigationBarItem>[];

  int approvedWallet = 0, waitApproveWallet = 0;
  bool load = true;
  bool? haveWallet;

  // List<WalletModel> approveWalletModels = [];
  var approveWalletModels = <WalletModel>[];
  var waitWallerModels = <WalletModel>[];

  @override
  void initState() {
    super.initState();
    readAllWallet();
    setUpBottonBar();
  }

  Future<void> readAllWallet() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var idBuyer = preferences.getString('id');
    print('idBuyer ==> $idBuyer');

    var path =
        '${MyConstant.domain}/chana/getWalletWhereIdBuyer.php?isAdd=true&idBuyer=$idBuyer';
    await Dio().get(path).then((value) {
      print('### value getWalletWhrerIdBuyer ==>> $value');

      if (value.toString() != 'null') {
        for (var item in json.decode(value.data)) {
          WalletModel model = WalletModel.fromMap(item);
          switch (model.money) {
            case '10':
              approvedWallet = int.parse(model.idBuyer);
              approveWalletModels.add(model);
              break;
            case '20':
              waitApproveWallet = int.parse(model.idBuyer);
              waitWallerModels.add(model);
              break;
            default:
          }
        }

        print(
            'approveWallet ===> $approvedWallet , waitApproveWallet = $waitApproveWallet');
        widgets.add(Wallet(
          approveWallet: approvedWallet,
          waitApproveWallet: waitApproveWallet,
        ));

        setState(() {
          load = false;
          haveWallet = true;
        });
      } else {
        print('### no infect Status');

        setState(() {
          load = false;
          haveWallet = false;
        });
      }
    });
  }

  void setUpBottonBar() {
    int index = 0;
    for (var title in titles) {
      bottonNavigationBarItems.add(
        BottomNavigationBarItem(
          label: title,
          icon: Icon(
            iconDatas[index],
          ),
        ),
      );
      index++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: load
          ? ShowProgress()
          : haveWallet!
              ? widgets[indexWidget]
              : ShowNoData(title: 'No infect', pathImage: 'images/image4.png'),
    );
  }
}
