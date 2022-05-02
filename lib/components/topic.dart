import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:offer_show/asset/color.dart';
import 'package:offer_show/asset/size.dart';
import 'package:offer_show/asset/svg.dart';
import 'package:offer_show/asset/time.dart';
import 'package:offer_show/asset/to_user.dart';
import 'package:offer_show/components/niw.dart';
import 'package:offer_show/util/interface.dart';
import 'package:offer_show/util/storage.dart';

import '../outer/cached_network_image/cached_image_widget.dart';

class Topic extends StatefulWidget {
  Map data;
  double top;
  double bottom;
  Color backgroundColor;

  Topic({
    Key key,
    this.data,
    this.top,
    this.bottom,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _TopicState createState() => _TopicState();
}

class _TopicState extends State<Topic> {
  var _isRated = false;

  void _getLikeStatus() async {
    String tmp = await getStorage(
      key: "topic_like",
    );
    List<String> ids = tmp.split(",");
    if (ids.indexOf(
            (widget.data["source_id"] ?? widget.data["topic_id"]).toString()) >
        -1) {
      setState(() {
        _isRated = true;
      });
    }
  }

  void _tapLike() async {
    if (_isRated == true) return;
    _isRated = true;
    await Api().forum_support({
      "tid": (widget.data["source_id"] ?? widget.data["topic_id"]),
      "type": "thread",
      "action": "support",
    });
    String tmp = await getStorage(
      key: "topic_like",
    );
    tmp += ",${widget.data['source_id'] ?? widget.data['topic_id']}";
    setStorage(key: "topic_like", value: tmp);
  }

  @override
  void initState() {
    _getLikeStatus();
    super.initState();
  }

  _setHistory() async {
    var history_data = await getStorage(key: "history", initData: "[]");
    List history_arr = jsonDecode(history_data);
    bool flag = false;
    for (int i = 0; i < history_arr.length; i++) {
      var ele = history_arr[i];
      if (ele["userAvatar"] == widget.data["userAvatar"] &&
          ele["title"] == widget.data["title"] &&
          ele["subject"] ==
              ((widget.data["summary"] ?? widget.data["subject"]) ?? "")) {
        history_arr.removeAt(i);
      }
    }
    List tmp_list_history = [
      {
        "userAvatar": widget.data["userAvatar"],
        "title": widget.data["title"],
        "subject": (widget.data["summary"] ?? widget.data["subject"]) ?? "",
        "time": widget.data["last_reply_date"],
        "topic_id": (widget.data["source_id"] ?? widget.data["topic_id"]),
      }
    ];
    tmp_list_history.addAll(history_arr);
    setStorage(key: "history", value: jsonEncode(tmp_list_history));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        os_edge,
        widget.top ?? 10,
        os_edge,
        widget.bottom ?? 0,
      ),
      child: myInkWell(
        color: widget.backgroundColor ?? os_white,
        tap: () async {
          String info_txt = await getStorage(key: "myinfo", initData: "");
          print("${info_txt}");
          _setHistory();
          if (info_txt == "") {
            Navigator.pushNamed(context, "/login", arguments: 0);
          } else {
            Navigator.pushNamed(
              context,
              "/topic_detail",
              arguments: (widget.data["source_id"] ?? widget.data["topic_id"]),
              // arguments: 1903247,
            );
          }
        },
        widget: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (widget.data["user_nick_name"] != "匿名")
                              toUserSpace(context, widget.data["user_id"]);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              width: 27,
                              height: 27,
                              fit: BoxFit.cover,
                              imageUrl: widget.data["userAvatar"],
                              placeholder: (context, url) =>
                                  Container(color: os_grey),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.data["user_nick_name"],
                              style: TextStyle(
                                color: os_black,
                                fontSize: 14,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Text(
                            //   RelativeDateFormat.format(
                            //       DateTime.fromMillisecondsSinceEpoch(int.parse(
                            //           widget.data["last_reply_date"]))),
                            //   style: TextStyle(
                            //     color: Color(0xFFC4C4C4),
                            //     fontSize: 12,
                            //   ),
                            // ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        myInkWell(
                          tap: () {
                            setState(() {
                              // _tapLike();
                            });
                          },
                          color: Colors.transparent,
                          widget: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.more_horiz_sharp,
                                  size: 18,
                                  color: Color(0xFF585858),
                                ),
                                // Text(
                                //   (widget.data["recommendAdd"] ??
                                //           0 + (_isRated ? 1 : 0))
                                //       .toString(),
                                //   style: TextStyle(
                                //     fontSize: 12,
                                //     color:
                                //         _isRated ? os_color : Color(0xFFB1B1B1),
                                //     fontWeight: FontWeight.w600,
                                //   ),
                                // ),
                                // Padding(padding: EdgeInsets.all(2)),
                                // os_svg(
                                //   path: _isRated
                                //       ? "lib/img/detail_like_blue.svg"
                                //       : "lib/img/detail_like.svg",
                                //   width: 24,
                                //   height: 24,
                                // ),
                              ],
                            ),
                          ),
                          radius: 100,
                        ),
                      ],
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.all(3)),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    widget.data["title"],
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(3)),
                ((widget.data["summary"] ?? widget.data["subject"]) ?? "") == ""
                    ? Container()
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          (widget.data["summary"] ?? widget.data["subject"]) ??
                              "",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                Padding(padding: EdgeInsets.all(8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        os_svg(
                          path: "lib/img/topic_component_view.svg",
                          width: 20,
                          height: 20,
                        ),
                        Container(width: 5),
                        Text(
                          "${widget.data['hits']}",
                          style: TextStyle(
                            color: Color(0xFF6B6B6B),
                            fontSize: 12,
                          ),
                        ),
                        Container(width: 20),
                        os_svg(
                          path: "lib/img/topic_component_comment.svg",
                          width: 20,
                          height: 20,
                        ),
                        Container(width: 5),
                        Text(
                          "${widget.data['replies']}",
                          style: TextStyle(
                            color: Color(0xFF6B6B6B),
                            fontSize: 12,
                          ),
                        ),
                        Container(width: 20),
                        os_svg(
                          path: "lib/img/topic_component_like.svg",
                          width: 20,
                          height: 20,
                        ),
                        Container(width: 5),
                        Text(
                          (widget.data["recommendAdd"] ?? 0).toString(),
                          style: TextStyle(
                            color: Color(0xFF6B6B6B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      RelativeDateFormat.format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(widget.data["last_reply_date"]))),
                      style: TextStyle(
                        color: Color(0xFF9C9C9C),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // width: width,
        // height: height,
        radius: 10,
      ),
    );
  }
}
