import 'package:carexpert/model/user.dart';
import 'package:carexpert/notifier/user_notifier.dart';
import 'package:carexpert/pages/main/homePage.dart';
import 'package:carexpert/services/auth_service.dart';
import 'package:carexpert/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;


class InboxPage extends StatefulWidget {

  InboxPage({Key key}) : super(key: key);

  @override
  _InboxPage createState() => _InboxPage();
}

class _InboxPage extends State<InboxPage> {
  
  final AuthService _auth = AuthService();
  bool _notiIcon = true;
  bool _dealerMode;
  String uid;
  
  @override
  void initState() {
    UserNotifier noti = Provider.of<UserNotifier>(context, listen: false);
    _dealerMode = noti.dealerMode;
    uid = noti.userUID;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Inbox'),
        actions: <Widget>[
          IconButton(
            icon: _notiIcon ? Icon(Icons.add_alert) : Icon(Icons.notifications_off),
            onPressed: (){ 
              setState(() => _notiIcon = !_notiIcon);      
              Scaffold.of(context).showSnackBar(snackbar(_notiIcon));
            },
          )
        ],
      ),
      drawer: MainDrawer(),
      body: _dealerMode ? Consumer<DealerDetails>(
        builder: (context, notifier, widget) {
          if (notifier != null) {
            if (notifier.likeNotification != null) {
              if (notifier.likeNotification.isNotEmpty) {
                return ListView.builder(
                  itemCount: notifier.likeNotification.length,
                  itemBuilder: (context, index) {

                    String _createdAt = timeago
                    .format(DateTime.tryParse(notifier.likeNotification[index]['time'].toDate().toString()))
                    .toString();

                    return Dismissible(
                      key: ValueKey(notifier.likeNotification[index]['username']),
                      background: Container(color: Colors.red,),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (DismissDirection direction) => DatabaseService().deleteNotification(notifier.likeNotification[index], uid),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                        child: Card(
                          elevation: 5,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            child: Stack(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 10,top: 32, right: 20),
                                  child: Text('${notifier.likeNotification[index]['userName']} just added ${notifier.likeNotification[index]['adTitle']} into his or her list.'),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Text("Notification", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                ),
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: Text(_createdAt, style: TextStyle(fontSize: 14, color: Colors.grey),),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    );
                  },
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: Image(image: AssetImage('assets/images/noti.png'),)
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No notifications', style: TextStyle(fontSize: 20),),
                      ),
                    ]
                  ),
                );
              }
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Image(image: AssetImage('assets/images/noti.png'),)
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('No notifications', style: TextStyle(fontSize: 20),),
                    ),
                  ]
                ),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ) : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 40,
              width: 40,
              child: Image(image: AssetImage('assets/images/noti.png'),)
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('No notifications', style: TextStyle(fontSize: 20),),
            ),
          ]
        ),
      ),
    );
  }

  Widget snackbar(bool noti){
      if (noti != true){
        return SnackBar(
            content: Text('Notifications enabled'),
        );
      }
      else{
        return SnackBar(
            content: Text('Notifications disabled'),
        );
      }
  }

}