import 'dart:async';
import 'dart:io';

class BackgroundUploader {
  BackgroundUploader._();

  // static final uploader = FlutterUploader();

  static Future<String?> uploadEnqueue(File file) async {
    // print(file.path);
    // final String? taskId = await uploader.enqueue(
    //   MultipartFormDataUpload(
    //     url: 'https://api.cloudinary.com/v1_1/smatch/auto/upload',
    //     method: UploadMethod.POST,
    //     headers: {
    //       "api_key": "489522481445921",
    //       "api_secret": "H9DpbxyRYerllQ4XGnWf6_SOczI"
    //     },
    //     files: [FileItem(path: file.path, field: "file")],
    //     tag: "Media Uploading",
    //   ),
    // );

    // return taskId;
  }
}
