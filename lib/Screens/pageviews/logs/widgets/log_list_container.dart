import 'package:flutter/material.dart';

import '../../../../Screens/chatscreens/widget/cached_image.dart';
import '../../../../constants/strings.dart';
import '../../../../models/log.dart';
import '../../../../resources/local_db/repository/log_repository.dart';
import '../../../../utils/utilities.dart';
import '../../../../widgets/custom_tile.dart';
import '../../../../widgets/quiet_box.dart';

class LogListContainer extends StatefulWidget {
  const LogListContainer({Key? key}) : super(key: key);

  @override
  _LogListContainerState createState() => _LogListContainerState();
}

class _LogListContainerState extends State<LogListContainer> {
  getIcon(String callStatus) {
    Icon _icon;
    double _iconSize = 15;

    switch (callStatus) {
      case callStatusDialed:
        _icon = Icon(
          Icons.call_made,
          size: _iconSize,
          color: Colors.green,
        );
        break;

      case callStatusMissed:
        _icon = Icon(
          Icons.call_missed,
          color: Colors.red,
          size: _iconSize,
        );
        break;

      default:
        _icon = Icon(
          Icons.call_received,
          size: _iconSize,
          color: Colors.grey,
        );
        break;
    }

    return Container(
      margin: const EdgeInsets.only(right: 5),
      child: _icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: LogRepository.getLogs(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          List<dynamic> logList = snapshot.data;

          if (logList.isNotEmpty) {
            return ListView.builder(
              itemCount: logList.length,
              itemBuilder: (context, i) {
                Log _log = logList[i];
                bool hasDialled = _log.callStatus == callStatusDialed;

                return CustomTile(
                  leading: CachedImage(
                    hasDialled ? _log.receiverPic! : _log.callerPic!,
                    isRound: true,
                    radius: 45,
                  ),
                  mini: false,
                  onLongPress: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete this Log?"),
                      content: const Text(
                          "Are you sure you wish to delete this log?"),
                      actions: [
                        TextButton(
                          child: const Text("YES"),
                          onPressed: () async {
                            Navigator.maybePop(context);
                            await LogRepository.deleteLogs(i);
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        ),
                        TextButton(
                          child: const Text("NO"),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    hasDialled ? _log.receiverName! : _log.callerName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  icon: getIcon(_log.callStatus ?? ""),
                  subtitle: Text(
                    Utils.formatDateString(_log.timestamp ?? ""),
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {},
                );
              },
            );
          }
          return const QuietBox(
            heading: "This is where all your call logs are listed",
            subtitle: "Calling people all over the world with just one click",
          );
        }

        return const QuietBox(
          heading: "This is where all your call logs are listed",
          subtitle: "Calling people all over the world with just one click",
        );
      },
    );
  }
}
