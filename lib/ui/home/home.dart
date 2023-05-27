import 'package:chatgpt/models/message.dart';
import 'package:chatgpt/utils/widgets/OtherSideMsg.dart';
import 'package:chatgpt/utils/widgets/OwnMsgCard.dart';
import 'package:chatgpt/utils/widgets/UserInfo.dart';
import 'package:chatgpt/utils/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatgpt/ui/home/homeVM.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> userChatMenuBtn = [
    "view contact",
    "Media, links, and docs",
    "Search",
    "Mute notifications",
    "Disappering messages",
    "Wallpaper",
    "More"
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeVM>(builder: (vm) {
      return Stack(
        children: [
          Image.asset(
            "assets/images/whatsappbg.png",
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: const Color(0xff8080ff),
              // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leadingWidth: 75,
              toolbarHeight: 55,
              titleSpacing: 0,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: InkWell(
                  onTap: () {
                    showUserInfo(context);
                    // Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: CircleAvatar(
                      radius: 20,
                    ),
                  ),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.all(8),
                child: InkWell(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.useDalle ? "Daal-e" : "Chat GPT",
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "last used ${vm.messages.isEmpty ? "..." : vm.getTime(vm.messages.last.time)}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
                // PopupMenuBtn(items: userChatMenuBtn)
              ],
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: WillPopScope(
                child: Column(
                  children: [
                    Expanded(
                      child: vm.loadMessages
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              controller: vm.scrollController,
                              itemCount: vm.messages.length + 1,
                              itemBuilder: (context, i) {
                                if (i == vm.messages.length) {
                                  return vm.replyLoading
                                      ? vm.useDalle
                                          ? Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Stack(
                                                children: [
                                                  Container(
                                                      width: 250,
                                                      height: 250,
                                                      child: Image.asset(
                                                          'assets/images/defaultt.png')),
                                                  const Positioned(
                                                      top: 100,
                                                      left: 100,
                                                      child:
                                                          CircularProgressIndicator()),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                              ),
                                              margin: EdgeInsets.only(
                                                  right: Get.width * 0.5,
                                                  top: 15,
                                                  left: 15),
                                              padding: const EdgeInsets.only(
                                                top: 5,
                                                bottom: 25,
                                                left: 10,
                                                right: 75,
                                              ),
                                              child: const Text(
                                                "processing...",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            )
                                      : Container(
                                          height: 10,
                                        );
                                }
                                if (!vm.messages[i].isBot) {
                                  return OwnMsgCard(
                                      text: vm.messages[i].msg,
                                      time: vm.getTime(
                                          vm.messages[i].time.toString()));
                                } else {
                                  return OtherSideMsgCard(
                                      isImage: vm.messages[i].isImage,
                                      text: vm.messages[i].msg.trim(),
                                      time: vm.getTime(
                                          vm.messages[i].time.toString()));
                                }
                              },
                            ),
                    ),
                    bottomTextMessaging(context)
                  ],
                ),
                onWillPop: () {
                  if (vm.useDalle == true) {
                    setState(() {
                      vm.useDalle = false;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                  return Future.value(false);
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  GetBuilder bottomTextMessaging(BuildContext context) {
    return GetBuilder<HomeVM>(builder: (vm) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          // height: widget.isWeb! ? 70 : 500,
          // width: widget.isWeb!
          //     ? MediaQuery.of(context).size.width - 400
          //     : MediaQuery.of(context).size.width - 55,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 2.0, right: 2),
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 55,
                      child: Card(
                        margin:
                            const EdgeInsets.only(left: 4, right: 2, bottom: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        child: TextFormField(
                          onChanged: (value) {
                            value.isNotEmpty
                                ? vm.sendButton = true
                                : vm.sendButton = false;
                            vm.update();
                          },
                          controller: vm.msgController,
                          focusNode: vm.focusNode,
                          textAlignVertical: TextAlignVertical.center,
                          maxLines: 5,
                          minLines: 1,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Message",
                            hintStyle: const TextStyle(fontSize: 18),
                            prefixIcon: IconButton(
                              icon: Icon(
                                vm.useDalle ? Icons.image : Icons.message,
                                size: 28,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                // focusNode.unfocus();
                                // focusNode.canRequestFocus = false;

                                showSnackBar(
                                    context,
                                    vm.useDalle
                                        ? "Switched to chat gpt"
                                        : "Switched to Daale");
                                vm.useDalle = !vm.useDalle;
                                vm.update();
                              },
                            ),
                            contentPadding: const EdgeInsets.all(5),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: CircleAvatar(
                        radius: 24.5,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                            onPressed: () {
                              if (vm.sendButton) {
                                vm.scrollControllerAtLast();
                                vm.focusNode.unfocus();
                                vm.sendMessage();
                                // messages.add(MessageModel(
                                //     msg: _txtController.text,
                                //     time: DateTime.now().toString(),
                                //     type: "source")
                                //     );
                                vm.msgController.clear();
                                vm.sendButton = false;
                                vm.update();
                              }
                            },
                            icon: Icon(vm.sendButton ? Icons.send : Icons.mic,
                                color: Colors.white,
                                size: vm.sendButton ? 23 : 25)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Widget sendFiles(){
  //   return ;
  // }
}

class IconBtn extends StatelessWidget {
  const IconBtn({
    Key? key,
    this.iconColor,
    this.iconSize,
    required this.icon,
    this.iconOnPress,
  }) : super(key: key);

  // final List<MoreOption> moreOptionsToSend;
  final IconData icon;
  final Color? iconColor;
  final double? iconSize;
  final void Function()? iconOnPress;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: iconOnPress ?? () {},
        icon: Icon(
          icon,
          color: iconColor ?? Colors.grey,
          size: iconSize ?? 24,
        ));
  }
}
