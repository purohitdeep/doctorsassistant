import 'dart:developer';

import 'package:arthurmorgan/enums.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/models/gfile.dart';
import 'package:flutter/material.dart';

class GDriveProvider extends ChangeNotifier {
  List<GFile>? files = [];
  bool fileListFetched = false; // TODO: PATCH
  UserState userState = UserState.undetermined;
  bool isLoggedIn =
      false; // THIS isLoggedIn is not google login, the internal login method using verify file

  void getFileList() async {
    files = await GlobalData.gDriveManager!.getFiles();
    fileListFetched = true;
    notifyListeners();
  }

  void setUserState() async {
    var isNew = await GlobalData.gDriveManager!.checkIfNewUser();
    if (isNew) {
      userState = UserState.noninitiated;
    } else {
      userState = UserState.initiated;
    }
    notifyListeners();
  }

  void setupArthurMorgan(String password) async {
    //var verifyString = FileHandler.createVerifyString(password);
    // var result = await GlobalData.gDriveManager!.setupArthurMorgan(verifyString);
    var result = await GlobalData.gDriveManager!.setupArthurMorgan();
    if (result) {
      userState = UserState.initiated;
    } else {
      log("Error Setting up Application.");
    }
    notifyListeners();
  }

  void login() async {
    try {
      var verifyFileMedia = await GlobalData.gDriveManager!.getVerifyFile();
      List<int> verifyFileBytes = [];

      verifyFileMedia.stream.listen((data) {
        verifyFileBytes.insertAll(verifyFileBytes.length, data);
      }, onDone: () {
        log("Download of verification file completed.");

        // Since we're removing password validation, we're going to assume successful login once the file is downloaded.
        isLoggedIn = true;
        notifyListeners();

      }, onError: (error) {
        log("Error downloading verification file: $error");
        notifyListeners();
      });

    } catch (e) {
      log("Error in login process: ${e.toString()}");
      notifyListeners();
    }
  }


  void logout() {
    userState = UserState.undetermined;
    isLoggedIn = false;
    files = [];
    fileListFetched = false;
    notifyListeners();
  }

  get getFiles {
    return files;
  }

  get getFileListFetched {
    return fileListFetched;
  }

  get getUserState {
    return userState;
  }

  get getIsLoggedIn {
    return isLoggedIn;
  }
}
