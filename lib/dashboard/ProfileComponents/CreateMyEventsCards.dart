import 'package:flutter/material.dart';
import 'package:rooya_app/ChatModule/ApiConfig/SizeConfiq.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/utils/colors.dart';

class CreateEvetCards extends StatelessWidget {
  final Function()? addStoryButton;
  final Function()? addTimeLineButton;
  final Function()? addPostButton;
  final bool? showCreate;

  const CreateEvetCards(
      {Key? key,
      this.addStoryButton,
      this.addTimeLineButton,
      this.addPostButton,
      this.showCreate = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Visibility(
              visible: showCreate!,
              child: InkWell(
                onTap: addStoryButton,
                child: Card(
                  child: Container(
                    height: height * 0.110,
                    width: width * 0.170,
                    child: Column(
                      children: [
                        Container(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                              color: appThemes, shape: BoxShape.circle),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Story',
                          style: TextStyle(
                              fontFamily: AppFonts.segoeui, fontSize: 10),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            InkWell(
              onTap: addTimeLineButton,
              child: Card(
                child: Container(
                  height: height * 0.110,
                  width: width * 0.170,
                  child: Column(
                    children: [
                      Container(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.black, shape: BoxShape.circle),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'My Event',
                        style: TextStyle(
                            fontFamily: AppFonts.segoeui, fontSize: 10),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                ),
                elevation: 3,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Visibility(
              visible: showCreate!,
              child: InkWell(
                onTap: addPostButton,
                child: Card(
                  child: Container(
                    height: height * 0.110,
                    width: width * 0.170,
                    child: Column(
                      children: [
                        Container(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Rooya',
                          style: TextStyle(
                              fontFamily: AppFonts.segoeui, fontSize: 10),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        )
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}
