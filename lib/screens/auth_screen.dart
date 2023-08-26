import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chitchat/widgets/user_image_picker.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _form = GlobalKey();
  var _isLoginMode = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  final _firebase = FirebaseAuth.instance;
  File? _userProfileImage;
  var _isAuthenticating = false;

  Future<void> _submitForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid || (!_isLoginMode && _userProfileImage == null)) {
      return;
    }
    setState(() {
      _isAuthenticating = true;
    });
    _form.currentState!.save();
    try {
      if (_isLoginMode) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        print(userCredentials);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final storageref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');
        await storageref.putFile(_userProfileImage!);
        final imageUrl = await storageref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'userName': _enteredUsername,
          'email': _enteredEmail,
          'profilePic': imageUrl,
        });
        // print(imageUrl);
      }
    } on FirebaseAuthException catch (error) {
      // if(error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed')));
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                margin: const EdgeInsets.only(
                    top: 20, bottom: 10, left: 20, right: 20),
                width: 300,
                child: Image.asset('assets/images/chat.png')),
            Card(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                            key: _form,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!_isLoginMode)
                                  UserImagePickerState(
                                      userImage: (imagePicked) {
                                    setState(() {
                                      _userProfileImage = imagePicked;
                                    });
                                  }),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        !value.contains('@')) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _enteredEmail = value!;
                                  },
                                ),
                                if (!_isLoginMode)
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'Username'),
                                    validator: (newValue) {
                                      if (newValue == null ||
                                          newValue.isEmpty ||
                                          newValue.trim().length < 4) {
                                        return 'Please enter atleast 4 characters.';
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) =>
                                        _enteredUsername = newValue!,
                                  ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'password'),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 6) {
                                      return 'Password should be atleast 6 characters long.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _enteredPassword = value!;
                                  },
                                ),
                                const SizedBox(
                                  height: 13,
                                ),
                                if (_isAuthenticating)
                                  const CircularProgressIndicator(),
                                if (!_isAuthenticating)
                                  ElevatedButton(
                                    onPressed: _submitForm,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer),
                                    child:
                                        Text(_isLoginMode ? 'Login' : 'SignUp'),
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (!_isAuthenticating)
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isLoginMode = !_isLoginMode;
                                        });
                                      },
                                      child: Text(_isLoginMode
                                          ? 'Create an Account'
                                          : 'Already have an account? LogIn!'))
                              ],
                            )))))
          ]),
        ),
      ),
    );
  }
}
