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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل بيانات الحساب، يرجى المحاولة لاحقاً';
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

    // إذا تم الحفظ بنجاح في شاشة التعديل، أعد تحميل البيانات لعرض آخر تحديث
    if (updated == true) {
      _loadProfile();
    }
  }

  /// يولّد الحروف الأولى من الاسم لعرضها داخل الصورة الرمزية عند غياب الصورة
  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '؟';
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

                            _buildSectionLabel('المعلومات الشخصية', isDark),
                            const SizedBox(height: 8),
                            _buildInfoCard(isDark)
                                .animate()
                                .fadeIn(delay: 150.ms, duration: 350.ms)
                                .slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 26),

                            _buildSectionLabel('إعدادات الحساب', isDark),
                            const SizedBox(height: 8),
                            _buildSettingsCard(isDark)
                                .animate()
                                .fadeIn(delay: 175.ms, duration: 350.ms)
                                .slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 26),

                            _buildSectionLabel('الإجراءات', isDark),
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
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // ── الهيدر: صورة (أو حروف أولى) + الاسم + الإيميل + زر تعديل ──
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
                'الملف الشخصي',
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
                      _avatarUrl!,
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

  // ── شارة/بطاقة النقاط والإحصائيات ──
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
            label: 'نقاط',
            isDark: isDark,
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            icon: Icons.menu_book_rounded,
            value: '8',
            label: 'مقترضة',
            isDark: isDark,
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            icon: Icons.shopping_bag_rounded,
            value: '3',
            label: 'مشتراة',
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

  // ── بطاقة المعلومات الشخصية ──
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
            label: 'الاسم الكامل',
            value: _userName,
            isDark: isDark,
          ),
          _buildTileDivider(isDark),
          _buildInfoTile(
            icon: Icons.email_outlined,
            label: 'البريد الإلكتروني',
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
            label: 'رقم الهاتف',
            value: (_userPhone == null || _userPhone!.isEmpty)
                ? 'غير محدد'
                : _userPhone!,
            isDark: isDark,
          ),
          _buildTileDivider(isDark),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.wc_rounded,
                  label: 'الجنس',
                  value: _userGender == null
                      ? 'غير محدد'
                      : (_userGender == 'M' ? 'ذكر' : 'أنثى'),
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
                  label: 'تاريخ الميلاد',
                  value: (_userDob == null || _userDob!.isEmpty)
                      ? 'غير محدد'
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
    bool isLast = false,
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

  // ── بطاقة إعدادات الحساب (Dark Mode + Language) ──
  Widget _buildSettingsCard(bool isDark) {
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
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            label: 'الوضع الليلي',
            isDark: isDark,
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                // تنفيذ تغيير الوضع
              },
              activeColor: AppColors.primary,
            ),
          ),
          _buildTileDivider(isDark),
          _buildSettingsTile(
            icon: Icons.language_outlined,
            label: 'لغة التطبيق',
            isDark: isDark,
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark
                  ? AppColors.textDark.withOpacity(0.35)
                  : AppColors.textLight.withOpacity(0.35),
            ),
            onTap: () {
              // فتح قائمة اللغات
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final color = isDark ? AppColors.textDark : AppColors.textLight;

    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: color.withOpacity(0.65)),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  // ── بطاقة الإجراءات ──
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
          _buildActionTile(
            icon: Icons.edit_outlined,
            label: 'تعديل الملف الشخصي',
            isDark: isDark,
            onTap: _openEditProfile,
          ),
          _buildTileDivider(isDark),
          _buildActionTile(
            icon: Icons.history_rounded,
            label: 'سجل الطلبات',
            isDark: isDark,
            onTap: () {
              // الانتقال إلى سجل الطلبات
            },
          ),
          _buildTileDivider(isDark),
          _buildActionTile(
            icon: Icons.lock_outline_rounded,
            label: 'تغيير كلمة المرور',
            isDark: isDark,
            onTap: () {
              // فتح شاشة تغيير كلمة المرور
            },
          ),
          _buildTileDivider(isDark),
          _buildActionTile(
            icon: Icons.logout_rounded,
            label: 'تسجيل الخروج',
            isDark: isDark,
            isLogout: true,
            onTap: () {
              // تنفيذ تسجيل الخروج
            },
          ),
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
