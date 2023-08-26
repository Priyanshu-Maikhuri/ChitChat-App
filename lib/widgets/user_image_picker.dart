import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePickerState extends StatefulWidget {
  const UserImagePickerState({super.key, required this.userImage});

  final void Function(File pickedImage) userImage;

  @override
  State<UserImagePickerState> createState() => _UserImagePickerStateState();
}

class _UserImagePickerStateState extends State<UserImagePickerState> {
  File? _pickedUserImage;

  void _takeImageInput() async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 150, imageQuality: 50);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedUserImage = File(pickedImage.path);
    });

    widget.userImage(_pickedUserImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blueGrey[300],
          foregroundImage:
              _pickedUserImage != null ? FileImage(_pickedUserImage!) : null,
        ),
        TextButton.icon(
            onPressed: _takeImageInput,
            icon: const Icon(Icons.image),
            label: Text(
              'Add Image',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ))
      ],
    );
  }
}
