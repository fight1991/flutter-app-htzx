import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo _packageInfo;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo info) {
      setState(() {
        _packageInfo = info;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2B61FF),
        centerTitle: false,
        title: Text(
          "关于我们",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          },
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 23, right: 20, bottom: 16),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 35, top: 50),
              child: Image.asset(
                "assets/images/ydsd_icon.png",
                width: 48,
                height: 48,
                fit: BoxFit.fill,
              ),
            ),
            Text(
                "        航天吉光科技有限公司是深圳航天科技创新研究院作为投资主体，江阴市高新技术开发区管理委员会参与投资建设的，是航天科技集团和地方政府央地合作的典范。\n\n"
                "        小蛮腰APP是航天吉光科技有限公司精心打造的基于电子车牌的涉车支付商户平台，实现停洗车、加油、保险、维修保养等涉车消费商户功能。"),
            Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 35, top: 25),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/logo.png",
                      width: 92,
                      height: 24,
                      fit: BoxFit.fill,
                    ),
                    Padding(
                      child: Text(
                        "V${_packageInfo?.version} (${_packageInfo?.buildNumber})",
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                        ),
                      ),
                        padding: EdgeInsets.only(top: 15),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
