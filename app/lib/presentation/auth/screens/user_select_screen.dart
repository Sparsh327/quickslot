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

class UserSelectScreen extends StatelessWidget {
  const UserSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              Text(
                'QuickSlot',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Who are you?',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40.h),
              BlocBuilder<AuthCubit, ScreenState<List<UserModel>>>(
                builder: (context, state) {
                  if (state.isLoading || state.isInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.isFailure) {
                    return Center(
                      child: Column(
                        children: [
                          Text(state.errorMessage ?? 'Error loading users'),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: () => context.read<AuthCubit>().loadUsers(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final users = state.data ?? [];
                  return Column(
                    children: users
                        .map((user) => _UserCard(user: user))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
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
    return GestureDetector(
      onTap: () {
        getIt<UserSession>().setUser(user.id, user.name);
        context.go(AppRoutes.venues);
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: const Color(0xFF6C63FF),
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
