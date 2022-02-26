import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:offer_show/asset/color.dart';
import 'package:offer_show/asset/modal.dart';
import 'package:offer_show/asset/svg.dart';
import 'package:offer_show/asset/time.dart';
import 'package:offer_show/components/niw.dart';
import 'package:offer_show/util/interface.dart';

class Search extends StatefulWidget {
  const Search({Key key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  int select = 0;
  var data = [];
  FocusNode _commentFocus = FocusNode();
  TextEditingController _controller = new TextEditingController();
  _getData() async {
    showToast(context: context, type: XSToast.loading);
    var tmp = await Api().forum_search({
      "keyword": _controller.text ?? "",
      "page": 1,
      "pageSize": 20,
    });
    data = tmp["list"] ?? [];
    setState(() {});
  }

  _getMore() async {
    var tmp = await Api().forum_search({
      "keyword": _controller.text ?? "",
      "page": 1,
      "pageSize": 10,
    });
    data = tmp["list"] ?? [];
    setState(() {});
  }

  List<Widget> _buildTopic() {
    List<Widget> tmp = [];
    if (data.length > 0) {
      for (int i = 0; i < data.length; i++) {
        tmp.add(SearchTopicCard(
          index: i,
          data: data[i],
        ));
      }
    }
    return tmp;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: os_back,
        foregroundColor: os_black,
        elevation: 0,
        actions: [
          SearchBtn(
            search: () {
              _getData();
              _commentFocus.unfocus();
            },
          )
        ],
        leadingWidth: 0,
        leading: Container(width: 0),
        title: SearchLeft(
          confirm: () {
            _getData();
            _commentFocus.unfocus();
          },
          commentFocus: _commentFocus,
          controller: _controller,
          select: (idx) {
            setState(() {
              select = idx;
            });
          },
        ),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Color(0xFFF1F4F8),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: _buildTopic(),
          ),
        ),
      ),
    );
  }
}

class SearchBtn extends StatefulWidget {
  Function search;
  SearchBtn({Key key, @required this.search}) : super(key: key);

  @override
  _SearchBtnState createState() => _SearchBtnState();
}

class _SearchBtnState extends State<SearchBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 15),
      child: myInkWell(
        tap: () {
          widget.search();
        },
        color: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        widget: Center(
          child: Text(
            "搜索",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFA3A3A3),
            ),
          ),
        ),
        radius: 100,
      ),
    );
  }
}

class SearchLeft extends StatefulWidget {
  Function select;
  Function confirm;
  TextEditingController controller;
  FocusNode commentFocus;
  SearchLeft({
    Key key,
    @required this.select,
    this.controller,
    @required this.commentFocus,
    @required this.confirm,
  }) : super(key: key);

  @override
  _SearchLeftState createState() => _SearchLeftState();
}

class _SearchLeftState extends State<SearchLeft> {
  int select_idx = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 83,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: os_white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          myInkWell(
            tap: () {
              widget.commentFocus.unfocus();
              showActionSheet(
                context: context,
                list: ["帖子", "用户"],
                select: (idx) {
                  setState(() {
                    select_idx = idx;
                  });
                  widget.select(idx);
                },
              );
            },
            radius: 10,
            widget: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    select_idx == 0 ? "帖子" : "用户",
                    style: TextStyle(
                      color: Color(0xFF004DFF),
                      fontSize: 16,
                    ),
                  ),
                  Container(width: 2),
                  Container(
                    margin: EdgeInsets.only(top: 2),
                    child: os_svg(
                      path: "lib/img/search_filter.svg",
                      width: 7.9,
                      height: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 165.5,
            child: TextField(
              onSubmitted: (context) {
                widget.confirm();
              },
              controller: widget.controller,
              cursorColor: os_black,
              cursorWidth: 1.5,
              focusNode: widget.commentFocus,
              style: TextStyle(
                fontSize: 16,
              ),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    widget.controller.clear();
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Color(
                      widget.controller.text.length > 0
                          ? 0xFFCCCCCC
                          : 0X00CCCCCC,
                    ),
                    size: 20,
                  ),
                ),
                hintText: "搜一搜",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchTopicCard extends StatefulWidget {
  Map data;
  int index;

  SearchTopicCard({Key key, this.data, this.index}) : super(key: key);

  @override
  _SearchTopicCardState createState() => _SearchTopicCardState();
}

class _SearchTopicCardState extends State<SearchTopicCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
      child: myInkWell(
        tap: () {
          Navigator.pushNamed(
            context,
            "/topic_detail",
            arguments: widget.data["topic_id"],
            // arguments: 1903247,
          );
        },
        widget: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 16, 15, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 35,
                            height: 35,
                            color: os_wonderful_color_opa[widget.index % 7],
                            child: Center(
                              child: Text(
                                widget.data["user_nick_name"].length == 0
                                    ? "X"
                                    : widget.data["user_nick_name"][0],
                                style: TextStyle(
                                  color: os_wonderful_color[widget.index % 7],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(4)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.data["user_nick_name"],
                              style: TextStyle(
                                color: Color(0xFF636363),
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              RelativeDateFormat.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(widget.data["last_reply_date"]),
                                ),
                              ),
                              style: TextStyle(
                                color: Color(0xFFC4C4C4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(1)),
                Container(
                  width: MediaQuery.of(context).size.width - 60,
                  child: Text(
                    widget.data["title"],
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(2)),
                Container(
                  width: MediaQuery.of(context).size.width - 60,
                  child: Text(
                    (widget.data["summary"] ?? widget.data["subject"]) ?? "",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFA3A3A3),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(7)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        os_svg(
                          path: "lib/img/comment.svg",
                          width: 12.8,
                          height: 12.8,
                        ),
                        Padding(padding: EdgeInsets.all(2)),
                        Text(
                          "评论 ${widget.data['replies']} · 浏览量 ${widget.data['hits']}",
                          style: TextStyle(
                            color: Color(0xFFC5C5C5),
                            fontSize: 14,
                          ),
                        )
                      ],
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