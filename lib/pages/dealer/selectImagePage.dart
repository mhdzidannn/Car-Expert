import 'package:carexpert/notifier/advertisment_notifier.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';


class SelectCarImagePage extends StatefulWidget {
  final List<Asset> initData;
  SelectCarImagePage({this.initData});
  @override
  _SelectCarImagePageState createState() => _SelectCarImagePageState();
}

class _SelectCarImagePageState extends State<SelectCarImagePage> {


  List<Asset> image;
  List<Asset> imageMain;
  List<Asset> deleteList;
  String _error;
  bool _iseDeleteMode;
  
  @override
  void initState() {
    _iseDeleteMode = false;
    imageMain = widget.initData;
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      if (imageMain == null) {_onInitializePage();}
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void scheduleRebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Selected Images'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: _iseDeleteMode ? Icon(Icons.done) : Icon(Icons.delete),
              onPressed: () {
                if (!_iseDeleteMode) {
                  _onDeletePress();
                }
                setState(() {
                  _iseDeleteMode = !_iseDeleteMode;
                });
              },
              color: Colors.white,
            )
          ],
        ),
        body: _buildGridView(),
        floatingActionButton: FloatingActionButton(
          disabledElevation: 0,
          onPressed: imageMain == null ? loadAssets :
          imageMain.length == 10 ? null : loadAssets,
          child: Icon(Icons.add_a_photo),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildGridView() {
    if (imageMain != null ) {
      return GridView.count(
        crossAxisCount: 2,
        children: List.generate(imageMain.length, (index) {
          Asset asset = imageMain[index];
          return GestureDetector(
            onTap: () {
              if (_iseDeleteMode) {
                setState(() => imageMain.removeWhere((element) => element == asset) );
              }
            },
            child: Stack(
              children: <Widget>[
                AssetThumb(asset: asset, width: 300, height: 300),
              ],
            ),
          );
        }),
      );
    } else {
      return Center(
        child: Text(
          'No Image Selected',
          style: TextStyle(fontSize: 20),
        ),
      );
    }
  }

  Future<void> loadAssets() async {
    setState(() {
      image = List<Asset>();
    });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10 - (imageMain == null ? 0 : imageMain.length),
        enableCamera: true
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      image = resultList;
      if (imageMain == null) {
        imageMain = image;
      } else {
        if (image != null)
        {imageMain.addAll(image);}
      }
      if (error == null) _error = 'No Error Dectected';
    });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => Consumer<AdvertistmentNotifier>(
        builder: (context, notifier, widget) {
          if (imageMain == null) {
            return AlertDialog(
              // title: Text('Are you sure?'),
              content: Text('Do you want to exit ?',style: TextStyle(fontSize: 20)),
              actions: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Text("No", style: TextStyle(color: Colors.cyan, fontSize: 25),),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    notifier.setImageAsset = null;
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Yes",style: TextStyle(color: Colors.cyan, fontSize: 25)),
                ),
                SizedBox(width: 10,)
              ],
            );
          } else {
            print("[IMAGE] ${notifier.getIsImageDone}");
            return AlertDialog(
              title: Text('Notice',style: TextStyle(color: Colors.cyan, fontSize: 25,fontWeight: FontWeight.bold)),
              content: imageMain.length >= 3 ? 
              Text('Your progress will be saved',style: TextStyle(fontSize: 20)) 
              : Text('Your progress will not be saved. Minimum number of picture required : 3',
              style: TextStyle(fontSize: 20),),
              actions: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Text("Stay", style: TextStyle(color: Colors.cyan, fontSize: 25),),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    if (imageMain.length >= 3){
                      notifier.setImageAsset = imageMain;
                      if (!notifier.getIsImageDone) {
                          notifier.updateProgressBarIndicator(true);
                          notifier.setIsImageDone = true;
                      }
                    } else {
                      notifier.setImageAsset = null;
                      if (notifier.getIsImageDone) {
                        notifier.updateProgressBarIndicator(false);
                        notifier.setIsImageDone = false;
                      }
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Exit",style: TextStyle(color: Colors.cyan, fontSize: 25)),
                ),
                SizedBox(width: 10,)
              ],
            );
          }
        }
      )
    ) ??
    false;
  }

  Future<void> _onInitializePage() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tip",style: TextStyle(fontSize: 24,color: Colors.cyan,fontWeight: FontWeight.bold),),
        content: Text("Please upload at least three pictures to proceed."
        ,style: TextStyle(fontSize: 20),),
        actions: <Widget>[
          GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text(
              'Dismiss',
              style: TextStyle(color: Colors.cyan, fontSize: 20),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _onDeletePress() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tip",style: TextStyle(fontSize: 24,color: Colors.cyan,fontWeight: FontWeight.bold),),
        content: Text("Tap the image to delete. When you are done ... tap the done button on the top right corner."
        ,style: TextStyle(fontSize: 20),),
        actions: <Widget>[
          GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text(
              'Dismiss',
              style: TextStyle(color: Colors.cyan, fontSize: 20),
            ),
          )
        ],
      ),
    );
  } 
}