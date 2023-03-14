import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppingmall/bodys/my_money_buyer.dart';
import 'package:shoppingmall/bodys/my_order_buyer.dart';
import 'package:shoppingmall/bodys/wallet.dart';
import 'package:shoppingmall/models/user_model.dart';
import 'package:shoppingmall/states/confirm_add_wallet.dart';
import 'package:shoppingmall/utility/my_constant.dart';
import 'package:shoppingmall/utility/my_dialog.dart';
import 'package:shoppingmall/widgets/show_image.dart';
import 'package:shoppingmall/widgets/show_progress.dart';

import 'package:shoppingmall/widgets/show_signout.dart';
import 'package:shoppingmall/widgets/show_title.dart';

class BuyerService extends StatefulWidget {
  const BuyerService({Key? key}) : super(key: key);

  @override
  _BuyerServiceState createState() => _BuyerServiceState();
}

class _BuyerServiceState extends State<BuyerService> {
  List<Widget> widgets = [
    MyMoneyBuyer(),
    ConfimeAddWallet(),
  ];
  int indexWidget = 0;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    findUserLogin();
  }

  Future<void> findUserLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var idUserLogin = preferences.getString('id');

    var urlAPI =
        '${MyConstant.domain}/chana/getUserWhereId.php?isAdd=true&id=$idUserLogin';
    await Dio().get(urlAPI).then((value) async {
      for (var item in json.decode(value.data)) {
        setState(() {
          userModel = UserModel.fromMap(item);
          print('#### id login ==> ${userModel!.id}');
        });
      }

      var path =
          '${MyConstant.domain}/chana/getWalletWhereIdBuyer.php?isAdd=true&idBuyer=${userModel!.id}';
      await Dio().get(path).then((value) {
        print('#### value getWalletWhereId ==> $value');

        if (value.toString() == 'null') {
          print('#### action Alert add Wallet');
          MyDialog(
            funcAction: () {
              Navigator.pop(context);
            },
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student'),
        actions: [],
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            Column(
              children: [
                buildHeader(),
                menuShowAllShop(),
                menuMyMoney(),
              ],
            ),
            ShowSignOut(),
          ],
        ),
      ),
      body: widgets[indexWidget],
    );
  }

  ListTile menuShowAllShop() {
    return ListTile(
      leading: Icon(
        Icons.short_text,
        size: 36,
        color: MyConstant.dark,
      ),
      title: ShowTitle(
        title: 'สถานะ',
        textStyle: MyConstant().h2Style(),
      ),
      subtitle: ShowTitle(
        title: '',
        textStyle: MyConstant().h3Style(),
      ),
      onTap: () {
        setState(() {
          indexWidget = 0;
          Navigator.pop(context);
        });
      },
    );
  }

  ListTile menuMyMoney() {
    return ListTile(
      leading: Icon(
        Icons.money,
        size: 36,
        color: MyConstant.dark,
      ),
      title: ShowTitle(
        title: 'แจ้งติดเชื้อ',
        textStyle: MyConstant().h2Style(),
      ),
      subtitle: ShowTitle(
        title: '',
        textStyle: MyConstant().h3Style(),
      ),
      onTap: () {
        setState(() {
          indexWidget = 1;
          Navigator.pop(context);
        });
      },
    );
  }

  UserAccountsDrawerHeader buildHeader() => UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 1,
          center: Alignment(-0.8, -0.2),
          colors: [Colors.white, MyConstant.dark],
        ),
      ),
      currentAccountPicture: userModel == null
          ? ShowImage(path: MyConstant.image1)
          : userModel!.avatar.isEmpty
              ? ShowImage(path: MyConstant.image1)
              : CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      '${MyConstant.domain}${userModel!.avatar}'),
                ),
      accountName: ShowTitle(
        title: userModel == null ? '' : userModel!.name,
        textStyle: MyConstant().h2WhiteStyle(),
      ),
      accountEmail: null);
}
