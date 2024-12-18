import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_in_a_botlle/providers/auth_provider.dart';
import 'package:message_in_a_botlle/providers/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(userProvider);
      if (userState.user != null) {
        firstNameController.text = userState.user!.firstName;
        lastNameController.text = userState.user!.lastName;
        phoneController.text = userState.user!.mobile;
      }
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _saveProfile() {
    if (formKey.currentState!.validate()) {
      ref.read(userProvider.notifier).updateProfile(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            mobile: phoneController.text,
            avatar: _selectedImage,
          );

      final userState = ref.read(userProvider);

      if (userState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userState.error!),
            backgroundColor: Colors.red.shade500,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile Updated Successfully"),
          backgroundColor: Colors.teal,
        ));
      }
    }
  }

  void handleLogout(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: const Text("Are you sure you want to Delete your account?"),
      content: const Text("You cannot recover your chats and friends"),
      actions: [
        TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go("/auth/signup");
            },
            child: const Text(
              "Yes, Delete",
              style: TextStyle(color: Colors.red),
            )),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("No")),
      ],
    );

    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.teal.shade100,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          foregroundImage: _selectedImage != null
                              ? FileImage(File(_selectedImage!.path))
                              : NetworkImage(userState.user!.avatar)
                                  as ImageProvider,
                          radius: 96,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: _pickImage,
                              iconSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Personal Information",
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Edit your personal Information"),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                        label: const Text("First Name"),
                        hintText: "John",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your first name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                        label: const Text("Last Name"),
                        hintText: "Doe",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your last name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    initialValue: userState.user?.email,
                    decoration: InputDecoration(
                        enabled: false,
                        label: const Text("Email"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                        label: const Text("Phone Number"),
                        hintText: "+1234567890",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your phone number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ButtonStyle(
                            fixedSize: WidgetStatePropertyAll(Size.fromWidth(
                                MediaQuery.of(context).size.width / 3))),
                        child: userState.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "SAVE CHANGES",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      OutlinedButton(
                          onPressed: () {
                            handleLogout(context);
                          },
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              )),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                              Text("DELETE ACCOUNT")
                            ],
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
