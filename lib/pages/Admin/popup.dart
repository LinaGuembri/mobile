import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/category.dart';

class MultiSelectPopup<T extends Category> extends PopupRoute<List<T>> {
  final List<T> options;
  final List<T> initialValue;
  final Widget Function(BuildContext, T, bool) itemBuilder;

  MultiSelectPopup({
    required this.options,
    required this.initialValue,
    required this.itemBuilder,
  });

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Color get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => "Dismiss";

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 60, vertical: 100),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6.0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((option) {
                    bool isSelected = initialValue.contains(option);
                    return ListTile(
                      onTap: () {
                        if (isSelected) {
                          initialValue.remove(option);
                        } else {
                          initialValue.add(option);
                        }
                        (context as Element).markNeedsBuild();
                      },
                      title: Text(
                        option!.name,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Colors.blue)
                          : Icon(Icons.circle_outlined),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, initialValue);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
