import 'package:flutter/material.dart';
import 'package:offer_show/asset/bigScreen.dart';
import 'package:offer_show/asset/color.dart';
import 'package:offer_show/asset/size.dart';
import 'package:offer_show/asset/svg.dart';
import 'package:offer_show/asset/xs_textstyle.dart';
import 'package:offer_show/components/leftNavi.dart';
import 'package:offer_show/components/niw.dart';
import 'package:offer_show/util/provider.dart';
import 'package:offer_show/util/storage.dart';
import 'package:provider/provider.dart';

class HomeBtn extends StatefulWidget {
  HomeBtn({Key? key}) : super(key: key);

  @override
  State<HomeBtn> createState() => _HomeBtnState();
}

class _HomeBtnState extends State<HomeBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Provider.of<ColorProvider>(context).isDark
            ? os_light_dark_card
            : os_white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      // margin: EdgeInsets.only(left: os_edge, right: os_edge),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      width: MediaQuery.of(context).size.width -
          os_edge * 2 -
          (isDesktop() ? LeftNaviWidth : 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Btn(
                txt: "视觉艺术",
                img: "lib/img/home/10.svg",
                url: "/column",
                board_id: 55,
              ),
              Btn(
                txt: "淘二手",
                img: "lib/img/home/2.svg",
                url: "/column",
                board_id: 61,
              ),
              Btn(
                txt: "失物",
                img: "lib/img/home/3.svg",
                url: "/column",
                board_id: 305,
              ),
              Btn(
                txt: "鹊桥",
                img: "lib/img/home/5.svg",
                url: "/column",
                board_id: 313,
              ),
              Btn(
                txt: "就业创业",
                img: "lib/img/home/4.svg",
                url: "/column",
                board_id: 174,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Btn(
                txt: "水手之家",
                img: "lib/img/home/6.svg",
                url: "/column",
                board_id: 25,
              ),
              Btn(
                txt: "吃喝玩乐",
                img: "lib/img/home/7.svg",
                url: "/column",
                board_id: 370,
              ),
              Btn(
                txt: "电子数码",
                img: "lib/img/home/8.svg",
                url: "/column",
                board_id: 66,
              ),
              Btn(
                txt: "水滴",
                img: "lib/img/home/9.svg",
                url: "/water_total",
                board_id: 0,
              ),
              Btn(
                txt: "全部板块",
                img: "lib/img/home/1.svg",
                url: "/square",
                board_id: 0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Btn extends StatefulWidget {
  String txt;
  String img;
  String url;
  int? board_id;
  Btn({
    Key? key,
    required this.txt,
    required this.img,
    required this.url,
    this.board_id,
  }) : super(key: key);

  @override
  State<Btn> createState() => _BtnState();
}

class _BtnState extends State<Btn> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double btn_width = (MediaQuery.of(context).size.width -
            os_edge * 2 -
            (isDesktop() ? LeftNaviWidth : 0) -
            50) /
        5 /
        (w > 1200 ? 3 : (w > 800 ? 2 : 1));
    return myInkWell(
      tap: () async {
        String myinfo = await getStorage(key: "myinfo", initData: "");
        if (myinfo == "") {
          Navigator.pushNamed(context, "/login", arguments: 0);
        } else {
          if (widget.url != "" &&
              widget.board_id != null &&
              widget.board_id != 0) {
            Navigator.pushNamed(context, widget.url,
                arguments: widget.board_id);
          } else if (widget.url != "") {
            Navigator.pushNamed(context, widget.url);
          }
        }
      },
      color: Provider.of<ColorProvider>(context).isDark
          ? os_light_dark_card
          : os_white,
      widget: Container(
        width: btn_width,
        padding: EdgeInsets.only(top: 10, bottom: 15),
        child: Column(
          children: [
            os_svg(path: widget.img, width: 30, height: 30),
            Container(height: 7.5),
            Text(
              widget.txt,
              overflow: TextOverflow.ellipsis,
              style: XSTextStyle(
                context: context,
                fontSize: 13,
                color: Provider.of<ColorProvider>(context).isDark
                    ? os_dark_white
                    : Color.fromARGB(255, 52, 52, 52),
              ),
            ),
          ],
        ),
      ),
      radius: 5,
    );
  }
}
