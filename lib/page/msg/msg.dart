import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:offer_show/asset/color.dart';
import 'package:offer_show/asset/svg.dart';
import 'package:offer_show/asset/time.dart';
import 'package:offer_show/components/BottomTip.dart';
import 'package:offer_show/components/empty.dart';
import 'package:offer_show/components/niw.dart';
import 'package:offer_show/page/topic/topic_detail.dart';
import 'package:offer_show/util/interface.dart';
import 'package:offer_show/util/provider.dart';
import 'package:provider/provider.dart';

import '../../outer/cached_network_image/cached_image_widget.dart';

class Msg extends StatefulWidget {
  Function refresh;
  Msg({
    Key key,
    this.refresh,
  }) : super(key: key);

  @override
  _MsgState createState() => _MsgState();
}

class _MsgState extends State<Msg> {
  Map msg;
  List pmMsgArr = [];
  bool vibrate = false;
  ScrollController _scrollController = new ScrollController();
  bool load_done = false;
  bool loading = false;
  bool showBackToTop = false;

  List<Widget> _buildPMMsg() {
    List<Widget> tmp = [];
    pmMsgArr.forEach((element) {
      tmp.add(
        MsgCard(
          data: element,
        ),
      );
    });
    if (pmMsgArr.length < 6) {
      tmp.add(Container(
        height: MediaQuery.of(context).size.height / 2,
      ));
    }
    return tmp;
  }

  getPm() async {
    var tmp = await Api().message_pmsessionlist({
      "json": {
        "page": 1,
        "pageSize": 10,
      }.toString()
    });
    if (tmp != null && tmp["rs"] != 0 && tmp["body"] != null) {
      pmMsgArr = tmp["body"]["list"];
      load_done = tmp["body"]["list"].length < 10;
    } else {
      pmMsgArr = [];
      load_done = true;
    }
    setState(() {});
  }

  _getMore() async {
    if (load_done || loading) return;
    loading = true;
    var tmp = await Api().message_pmsessionlist({
      "json": {
        "page": (pmMsgArr.length / 10 + 1).toInt(),
        "pageSize": 10,
      }.toString()
    });
    if (tmp != null &&
        tmp["body"] != null &&
        int.parse(tmp["body"]["list"][0]["lastDateline"]) <
            int.parse(pmMsgArr[pmMsgArr.length - 1]["lastDateline"])) {
      pmMsgArr.addAll(tmp["body"]["list"]);
      load_done = tmp["body"]["list"].length < 10;
    } else {
      load_done = true;
    }
    loading = false;
    setState(() {});
  }

  getData() async {
    var data = await Api().message_heart({});
    if (data != null &&
        data["body"] != null &&
        data["body"]["atMeInfo"] != null) {
      setState(() {
        msg = {
          "atMeInfoCount": data["body"]["atMeInfo"]["count"],
          "replyInfoCount": data["body"]["replyInfo"]["count"],
          "systemInfoCount": data["body"]["systemInfo"]["count"],
        };
      });
    } else {
      setState(() {
        msg = {
          "atMeInfoCount": 0,
          "replyInfoCount": 0,
          "systemInfoCount": 0,
        };
      });
    }
  }

  @override
  void initState() {
    getData();
    getPm();
    _scrollController = Provider.of<HomeRefrshProvider>(context, listen: false)
        .msgScrollController;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 1000 && !showBackToTop) {
        setState(() {
          showBackToTop = true;
        });
      }
      if (_scrollController.position.pixels < 1000 && showBackToTop) {
        setState(() {
          showBackToTop = false;
        });
      }
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMore();
      }
      if (_scrollController.position.pixels < -100) {
        if (!vibrate) {
          vibrate = true; //不允许再震动
          Vibrate.feedback(FeedbackType.impact);
        }
      }
      if (_scrollController.position.pixels >= 0) {
        vibrate = false; //允许震动
      }
    });
    super.initState();
  }

  GlobalKey<RefreshIndicatorState> _indicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    HomeRefrshProvider provider = Provider.of<HomeRefrshProvider>(context);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: os_white,
        foregroundColor: os_black,
        elevation: 0,
        title: Text(
          "消息",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: os_white,
        child: RefreshIndicator(
          key: provider.msgRefreshIndicator,
          color: Color(0xFF2FCC7E),
          onRefresh: () async {
            await getData();
            await getPm();
            return;
          },
          child: ListView(
            physics: BouncingScrollPhysics(),
            controller: _scrollController,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 7),
                child: msg == null || msg is int
                    ? Container()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ColorBtn(
                            tap: () {
                              msg["atMeInfoCount"] = 0;
                              setState(() {});
                              if (widget.refresh != null) widget.refresh();
                              Navigator.pushNamed(
                                context,
                                "/msg_three",
                                arguments: 0,
                              );
                            },
                            path: "lib/img/msg/@.svg",
                            title: "@我",
                            count: msg["atMeInfoCount"],
                          ),
                          ColorBtn(
                            path: "lib/img/msg/reply.svg",
                            title: "回复",
                            count: msg["replyInfoCount"],
                            tap: () {
                              msg["replyInfoCount"] = 0;
                              setState(() {});
                              if (widget.refresh != null) widget.refresh();
                              Navigator.pushNamed(
                                context,
                                "/msg_three",
                                arguments: 1,
                              );
                            },
                          ),
                          ColorBtn(
                            path: "lib/img/msg/noti.svg",
                            title: "通知",
                            count: msg["systemInfoCount"],
                            tap: () {
                              msg["systemInfoCount"] = 0;
                              if (widget.refresh != null) widget.refresh();
                              Navigator.pushNamed(
                                context,
                                "/msg_three",
                                arguments: 2,
                              );
                              setState(() {});
                            },
                          ),
                        ],
                      ),
              ),
              pmMsgArr.length == 0
                  ? Container()
                  : BottomTip(
                      top: 25,
                      bottom: 5,
                      txt: "- 私信内容 -",
                    ),
              pmMsgArr.length != 0
                  ? Container()
                  : Empty(
                      txt: "暂无私信内容",
                    ),
              Column(
                children: _buildPMMsg(),
              ),
              (load_done || pmMsgArr.length == 0)
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: BottomLoading(color: os_white)),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorBtn extends StatefulWidget {
  int count;
  String path;
  String title;
  Function tap;
  ColorBtn({
    Key key,
    this.count,
    this.path,
    this.title,
    this.tap,
  }) : super(key: key);

  @override
  State<ColorBtn> createState() => _ColorBtnState();
}

class _ColorBtnState extends State<ColorBtn> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.tap != null) {
          widget.tap();
        }
      },
      child: Container(
        child: Stack(
          children: [
            os_svg(
              path: widget.path,
              width: 108,
              height: 51,
            ),
            Positioned(
              top: 14,
              left: 20,
              child: Badge(
                position: BadgePosition(top: -10, end: 50),
                showBadge: widget.count != 0,
                badgeContent: Text(
                  widget.count.toString(),
                  style: TextStyle(
                    color: os_white,
                    fontSize: 10,
                  ),
                ),
                child: Container(
                  child: Hero(
                    tag: widget.title,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 100,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: os_white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MsgCard extends StatefulWidget {
  Map data;
  bool isNew;
  MsgCard({
    Key key,
    this.data,
    this.isNew,
  }) : super(key: key);

  @override
  State<MsgCard> createState() => _MsgCardState();
}

class _MsgCardState extends State<MsgCard> {
  double headImgSize = 40;
  @override
  Widget build(BuildContext context) {
    return myInkWell(
      tap: () {
        Navigator.pushNamed(context, "/msg_detail", arguments: {
          "uid": widget.data["toUserId"],
          "name": widget.data["toUserName"],
        });
      },
      radius: 0,
      color: Colors.transparent,
      widget: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Badge(
              showBadge: widget.data["isNew"] == 0 ? false : true,
              position: BadgePosition.topEnd(top: -2, end: -2),
              child: Container(
                width: headImgSize,
                height: headImgSize,
                decoration: BoxDecoration(
                  color: os_grey,
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  child: CachedNetworkImage(
                    imageUrl: widget.data["toUserAvatar"],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Container(width: 10),
            Container(
              width: MediaQuery.of(context).size.width - headImgSize - 42,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.data["toUserName"],
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF000000),
                        ),
                      ),
                      os_svg(
                        path: "lib/img/msg_card_right.svg",
                        width: 6,
                        height: 11,
                      )
                    ],
                  ),
                  Container(height: 5),
                  Text(
                    (widget.data["lastSummary"] == ""
                            ? "查看图片"
                            : widget.data["lastSummary"]) +
                        " · " +
                        RelativeDateFormat.format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(widget.data["lastDateline"]),
                          ),
                        ).toString(),
                    style: TextStyle(
                      color: Color(0xFFA0A0A0),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}