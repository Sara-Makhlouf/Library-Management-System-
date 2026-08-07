import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/profile/data/customer_repository.dart';
import 'package:library_mobile_app/feature/profile/presentation/edit_profile_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _repository = CustomerRepository();

  bool _isLoading = true;
  String? _errorMessage;

  String _userName = '';
  String _userEmail = '';
  String? _userPhone;
  String? _userGender;
  String? _userDob;
  String? _avatarUrl;
  int _userPoints = 0;
  int _avatarCacheBuster = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _repository.getProfile();
      final data = result['data'] as Map<String, dynamic>? ?? {};
      setState(() {
        _userName = data['name'] ?? '';
        _userEmail = data['email'] ?? '';
        _userPhone = data['phone'];
        _userGender = data['gender'];
        _userDob = data['DOB'];
        _avatarUrl = data['avatar'];
        _userPoints = data['points'] ?? 0;
        _avatarCacheBuster = DateTime.now().millisecondsSinceEpoch;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load account data, please try again later';
      });
    }
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          currentName: _userName,
          currentEmail: _userEmail,
          currentPhone: _userPhone,
          currentGender: _userGender,
          currentDob: _userDob,
          currentAvatarUrl: _avatarUrl,
        ),
      ),
    );

    if (updated == true) {
      _loadProfile();
    }
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1);
    return parts.first.substring(0, 1) + parts[1].substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
          ? _buildErrorState(isDark)
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadProfile,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(isDark)
                          .animate()
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: -0.05, end: 0),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 4),

                            _buildPointsCard(isDark)
                                .animate()
                                .fadeIn(delay: 100.ms, duration: 350.ms)
                                .slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 26),

                            _buildSectionLabel('Personal Information', isDark),
                            const SizedBox(height: 8),
                            _buildInfoCard(isDark)
                                .animate()
                                .fadeIn(delay: 150.ms, duration: 350.ms)
                                .slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 26),

                            _buildSectionLabel('Actions', isDark),
                            const SizedBox(height: 8),
                            _buildActionsCard(isDark)
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 350.ms)
                                .slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: isDark
                  ? AppColors.textDark.withOpacity(0.4)
                  : AppColors.textLight.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadProfile,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppColors.accentDark, AppColors.backgroundDark]
              : [AppColors.accentLight, AppColors.backgroundLight],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
              Text(
                'Profile',
                style: TextStyle(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withOpacity(0.06),
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                  onPressed: _openEditProfile,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
              border: Border.all(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _avatarUrl != null
                  ? Image.network(
                      '$_avatarUrl?v=$_avatarCacheBuster',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          _getInitials(_userName),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        _getInitials(_userName),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _userName,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _userEmail,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark
                  ? AppColors.textDark.withOpacity(0.55)
                  : AppColors.textLight.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            icon: Icons.star_rounded,
            value: '$_userPoints',
            label: 'Points',
            isDark: isDark,
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            icon: Icons.menu_book_rounded,
            value: '8',
            label: 'Borrowed',
            isDark: isDark,
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            icon: Icons.shopping_bag_rounded,
            value: '3',
            label: 'Purchased',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark
                  ? AppColors.textDark.withOpacity(0.7)
                  : AppColors.textLight.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textDark.withOpacity(0.5)
                  : AppColors.textLight.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 0.5,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.textDark.withOpacity(0.55)
              : AppColors.textLight.withOpacity(0.55),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.person_outline_rounded,
            label: 'Full Name',
            value: _userName,
            isDark: isDark,
          ),
          _buildTileDivider(isDark),
          _buildInfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _userEmail,
            isDark: isDark,
            trailing: Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: isDark
                  ? AppColors.textDark.withOpacity(0.35)
                  : AppColors.textLight.withOpacity(0.35),
            ),
          ),
          _buildTileDivider(isDark),
          _buildInfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: (_userPhone == null || _userPhone!.isEmpty)
                ? 'Not specified'
                : _userPhone!,
            isDark: isDark,
          ),
          _buildTileDivider(isDark),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.wc_rounded,
                  label: 'Gender',
                  value: _userGender == null
                      ? 'Not specified'
                      : (_userGender == 'M' ? 'Male' : 'Female'),
                  isDark: isDark,
                  compact: true,
                ),
              ),
              Container(
                width: 0.5,
                height: 44,
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
              ),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.cake_outlined,
                  label: 'Date of Birth',
                  value: (_userDob == null || _userDob!.isEmpty)
                      ? 'Not specified'
                      : _userDob!,
                  isDark: isDark,
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Widget? trailing,
    bool compact = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 15,
              color: isDark
                  ? AppColors.textDark.withOpacity(0.65)
                  : AppColors.textLight.withOpacity(0.65),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark
                        ? AppColors.textDark.withOpacity(0.5)
                        : AppColors.textLight.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildTileDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
    );
  }

  Widget _buildActionsCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        children: [
          _buildTileDivider(isDark),
          _buildActionTile(
            icon: Icons.history_rounded,
            label: 'Order History',
            isDark: isDark,
            onTap: () {},
          ),
          _buildTileDivider(isDark),
          _buildActionTile(
            icon: Icons.lock_outline_rounded,
            label: 'Change Password',
            isDark: isDark,
            onTap: () {},
          ),
          _buildTileDivider(isDark),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final color = isLogout
        ? Colors.red
        : (isDark ? AppColors.textDark : AppColors.textLight);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          icon,
          size: 15,
          color: isLogout ? Colors.red : color.withOpacity(0.65),
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: color.withOpacity(0.35),
      ),
    );
  }
}
