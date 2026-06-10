import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/screen_state.dart';
import '../../../core/services/user_session.dart';
import '../../../data/models/user_model.dart';
import '../../../core/di/injection_container.dart';
import '../cubit/auth_cubit.dart';
import '../../../router/app_routes.dart';

const _avatarColors = [
  Color(0xFF6C63FF),
  Color(0xFF27AE60),
  Color(0xFFE67E22),
];

class UserSelectScreen extends StatelessWidget {
  const UserSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(28.w, 70.h, 28.w, 36.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF9747FF)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(Icons.bolt, color: Colors.white, size: 28.sp),
                ),
                SizedBox(height: 20.h),
                Text(
                  'QuickSlot',
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Book your sport slot instantly',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Who's playing today?",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: BlocBuilder<AuthCubit, ScreenState<List<UserModel>>>(
              builder: (context, state) {
                if (state.isLoading || state.isInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.isFailure) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage ?? 'Error loading users'),
                        SizedBox(height: 12.h),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<AuthCubit>().loadUsers(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                final users = state.data ?? [];
                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  children:
                      users.map((u) => _UserCard(user: u)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = user.name.split(' ').map((w) => w[0]).take(2).join();
    final idx =
        (int.tryParse(user.id.replaceAll(RegExp(r'\D'), '')) ?? 1) - 1;
    final color = _avatarColors[idx.clamp(0, _avatarColors.length - 1)];

    return GestureDetector(
      onTap: () {
        getIt<UserSession>().setUser(user.id, user.name);
        context.go(AppRoutes.venues);
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Tap to continue',
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.arrow_forward_ios,
                  size: 14.sp, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
