import 'dart:developer';
import 'dart:io';

import 'package:arthurmorgan/enums.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/models/gfile.dart';
import 'package:arthurmorgan/providers/taskinfopopup_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class FileInfoSheetProvider extends ChangeNotifier {
  bool isOpen = false;
  GFile? currentSelectedFile;
  List<int> encryptedPreviewData = [];
  PreviewLoadState previewLoadState = PreviewLoadState.notloaded;
  List<int> previewData=[];

  void setIsOpen(bool value) {
    isOpen = value;
    notifyListeners();
  }

  void setCurrentGFile(GFile gfile) {
    currentSelectedFile = gfile;
    setIsOpen(true);
    encryptedPreviewData = [];
    previewLoadState = PreviewLoadState.notloaded;
    notifyListeners();
  }

  void loadAndDecryptPreview() async {
    previewLoadState = PreviewLoadState.loading;
    notifyListeners();

    // Ensure previewData is initialized
    // if (previewData == null) {
    //   previewData = [];
    // }

    try {
      var stream = await GlobalData.gDriveManager!.downloadFile(currentSelectedFile!);

      stream.listen((data) {
        previewData!.addAll(data);
      }, onDone: () {
        log("Download complete for ${currentSelectedFile!.name}");
        previewLoadState = PreviewLoadState.loaded;
        notifyListeners();
      }, onError: (error) {
        log("Download error for ${currentSelectedFile!.name}: $error");
        notifyListeners();
      });

    } catch (e) {
      log("An exception occurred while downloading ${currentSelectedFile!.name}: $e");
      notifyListeners();
    }
  }





  void saveToDisk(BuildContext context) async {
    try {
      Provider.of<TaskInfoPopUpProvider>(context, listen: false)
          .show("Downloading ${currentSelectedFile!.name}");

      List<int> data = [];
      var stream =
      await GlobalData.gDriveManager!.downloadFile(currentSelectedFile!);

      stream.listen((chunk) {
        data.insertAll(data.length, chunk);
      }, onDone: () {
        log("Download complete for ${currentSelectedFile!.name}");

        String docDir = GlobalData.gAppDocDir!.path;
        String savePath = path.join(
            docDir, "ArthurMorgan", "Downloads", currentSelectedFile!.name);
        log("Saving file to: $savePath");

        File(savePath).create(recursive: true).then((saveFile) {
          saveFile.writeAsBytes(data);
          log("File ${currentSelectedFile!.name} saved to disk successfully.");
          Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
        }).catchError((error) {
          log("Error while writing file to disk: $error");
          Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
        });

      }, onError: (error) {
        log("Error during download of ${currentSelectedFile!.name}: $error");
        Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
      });

    } catch (e) {
      log("An exception occurred while saving ${currentSelectedFile!.name} to disk: $e");
      Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
    }
  }


  get getIsOpen {
    return isOpen;
  }

  get getcurrentSelectedFile {
    return currentSelectedFile;
  }

  get getPreviewLoadState {
    return previewLoadState;
  }

  get getPreviewData {
    return  Uint8List.fromList(previewData!);
    ;
  }
}
