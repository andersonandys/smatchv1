import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smatch/message/isole/constant.dart';
import 'package:smatch/message/isole/upload_isolate.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            //PICK IMAGE FROM GALLERY
            final image = await ImagePicker.platform
                .pickImage(source: ImageSource.gallery);
            //CHECK IF IMAGE IS NULL OR NOT
            if (image != null) {
              //GIVE IMAGE TO OUR ISOLATE FUNCTION WHICH WILL MAKE A ISOLATE AND UPLOAD THIS IMAGE TO THAT ISOLATE

            }
          },
          label: const Text('Upload'),
          icon: const Icon(Icons.upload_outlined),
        ),
        body: ValueListenableBuilder(
            valueListenable: isUploading,
            builder: (BuildContext context, value, Widget) {
              switch (value) {
                case UploadStatus.Idle:
                  return const Center(
                      child: Text("Upload the file to Firebase Storage"));
                  break;
                case UploadStatus.Uploading:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                  break;
                case UploadStatus.Finished:
                  return Center(
                    child: uploadedUrl == ''
                        ? const Icon(Icons.error)
                        : Image.network(uploadedUrl),
                  );
                  break;
                default:
                  return const Center(child: Text("Something went wrong"));
              }
            }));
  }
}
