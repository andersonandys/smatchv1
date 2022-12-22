import 'package:flutter/cupertino.dart';

//we made this enum to ease the state management
enum UploadStatus { Idle, Uploading, Finished }

String uploadedUrl = "";
//we will notify our homepage when upload status changes
//this status will be changed from the isolate itself
ValueNotifier isUploading = ValueNotifier<UploadStatus>(UploadStatus.Idle);
