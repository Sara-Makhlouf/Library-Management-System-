import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:library_mobile_app/core/components/custom_button.dart';
import 'package:library_mobile_app/core/components/custom_input_field.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/profile/data/customer_repository.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String? currentPhone;
  final String? currentGender;
  final String? currentDob;
  final String? currentAvatarUrl;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
    this.currentPhone,
    this.currentGender,
    this.currentDob,
    this.currentAvatarUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;

  final _repository = CustomerRepository();
  final ImagePicker _picker = ImagePicker();

  late String _gender;
  File? _newAvatar;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone ?? '');
    _dobController = TextEditingController(text: widget.currentDob ?? '');
    _gender = widget.currentGender ?? 'M';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    DateTime initial = DateTime(now.year - 18, now.month, now.day);
    if (widget.currentDob != null && widget.currentDob!.isNotEmpty) {
      initial = DateTime.tryParse(widget.currentDob!) ?? initial;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.accentDark : Colors.white,
              onSurface: isDark ? AppColors.textDark : AppColors.textLight,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _newAvatar = File(image.path));
    }
  }

  void _showAvatarOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.accentDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Choose from gallery',
                  style: TextStyle(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Take a photo',
                  style: TextStyle(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAvatar(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Name cannot be empty');
      return;
    }
    if (_phoneController.text.trim().isNotEmpty &&
        _phoneController.text.trim().length != 10) {
      setState(() => _errorMessage = 'Phone number must be 10 digits');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _repository.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        gender: _gender,
        dob: _dobController.text.isEmpty ? null : _dobController.text,
        avatar: _newAvatar,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      final serverMessage = e.response?.data is Map
          ? e.response?.data['message']
          : null;
      setState(() {
        _errorMessage =
            serverMessage ?? 'An error occurred while saving changes';
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: isDark ? AppColors.textDark : AppColors.textLight,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showAvatarOptions,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2.5,
                          ),
                          color: isDark ? AppColors.inputDark : Colors.white,
                        ),
                        child: ClipOval(
                          child: _newAvatar != null
                              ? Image.file(_newAvatar!, fit: BoxFit.cover)
                              : (widget.currentAvatarUrl != null
                                    ? Image.network(
                                        widget.currentAvatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.person,
                                          size: 52,
                                          color: AppColors.primary.withOpacity(
                                            0.6,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 52,
                                        color: AppColors.primary.withOpacity(
                                          0.6,
                                        ),
                                      )),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.backgroundDark
                                  : AppColors.backgroundLight,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 28),

              Text(
                'Email',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textDark.withOpacity(0.6)
                      : AppColors.textLight.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.inputDark.withOpacity(0.5)
                      : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 18,
                      color: isDark
                          ? AppColors.textDark.withOpacity(0.4)
                          : AppColors.textLight.withOpacity(0.4),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.currentEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textDark.withOpacity(0.55)
                              : AppColors.textLight.withOpacity(0.55),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.textDark.withOpacity(0.3)
                          : AppColors.textLight.withOpacity(0.3),
                    ),
                  ],
                ),
              ).animate(delay: 60.ms).fadeIn(),

              const SizedBox(height: 18),

              _fieldLabel('Full Name', isDark),
              const SizedBox(height: 8),
              CustomInputField(
                controller: _nameController,
                hint: 'Enter your full name',
                icon: Icons.person_outline_rounded,
                isDark: isDark,
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: 18),

              _fieldLabel('Phone Number', isDark),
              const SizedBox(height: 8),
              CustomInputField(
                controller: _phoneController,
                hint: 'Enter your phone number',
                icon: Icons.phone_outlined,
                isDark: isDark,
                keyboardType: TextInputType.phone,
              ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: 18),

              _fieldLabel('Date of Birth', isDark),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDob,
                child: AbsorbPointer(
                  child: CustomInputField(
                    controller: _dobController,
                    hint: 'Select your date of birth',
                    icon: Icons.calendar_today_outlined,
                    isDark: isDark,
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: 18),

              _fieldLabel('Gender', isDark),
              const SizedBox(height: 8),
              _GenderSelector(
                selected: _gender,
                isDark: isDark,
                onChanged: (value) => setState(() => _gender = value),
              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1, end: 0),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFB33A3A),
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 30),

              CustomButton(
                isLoading: _isSaving,
                onTap: _onSave,
                text: 'Save Changes',
              ).animate(delay: 300.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark
            ? AppColors.textDark.withOpacity(0.6)
            : AppColors.textLight.withOpacity(0.6),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onChanged;
  const _GenderSelector({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  Widget _chip(String value, String label, IconData icon) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.12)
                : (isDark ? AppColors.inputDark : AppColors.backgroundLight),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.textDark.withOpacity(0.5)
                          : AppColors.textLight.withOpacity(0.5)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.textDark : AppColors.textLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip('M', 'Male', Icons.male_rounded),
        const SizedBox(width: 10),
        _chip('F', 'Female', Icons.female_rounded),
      ],
    );
  }
}
