import 'dart:io';

import 'package:flutter/material.dart';

/// A kid's `photoUrl` is either a real URL (backend upload, once that
/// endpoint exists) or a local file path (picked via file_picker, no
/// upload endpoint yet — see ChildProfileCard). Route to the right
/// [ImageProvider] either way.
ImageProvider kidPhotoProvider(String photoUrl) =>
    photoUrl.startsWith('http') ? NetworkImage(photoUrl) : FileImage(File(photoUrl));
