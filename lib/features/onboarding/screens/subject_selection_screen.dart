import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/models/subject_model.dart';
import 'package:pgme/features/home/providers/dashboard_provider.dart';
import 'package:pgme/features/onboarding/providers/onboarding_provider.dart';

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch subjects when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSubjects();
    });
  }

  Future<void> _fetchSubjects() async {
    try {
      final onboardingProvider = context.read<OnboardingProvider>();
      await onboardingProvider.fetchSubjects();

      // Pre-select the user's current primary subject if available
      if (onboardingProvider.selectedSubject == null && mounted) {
        final primarySubject = context.read<DashboardProvider>().primarySubject;
        if (primarySubject != null) {
          final match = onboardingProvider.subjects.cast<SubjectModel?>().firstWhere(
            (s) => s!.subjectId == primarySubject.subjectId,
            orElse: () => null,
          );
          if (match != null) {
            onboardingProvider.selectSubject(match);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _fetchSubjects,
            ),
          ),
        );
      }
    }
  }

  /// Check if we're changing subject (already onboarded) vs initial onboarding
  bool get _isChangingSubject {
    final dashboardProvider = context.read<DashboardProvider>();
    return dashboardProvider.primarySubject != null;
  }

  Future<void> _onContinue() async {
    final provider = context.read<OnboardingProvider>();

    if (!provider.hasSelectedSubject) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subject to continue'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final success = await provider.submitSubjectSelection();
      if (success && mounted) {
        if (_isChangingSubject) {
          // Changing subject from profile — refresh dashboard and pop back
          context.read<DashboardProvider>().refresh();
          if (mounted) {
            context.pop();
          }
        } else {
          // Initial onboarding — complete onboarding and navigate to home
          await provider.completeOnboarding();
          if (mounted) {
            context.go('/home');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider, width: 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Logo
            Image.asset(
              'assets/illustrations/logo2.png',
              width: 200,
              height: 53,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(width: 200, height: 53);
              },
            ),

            const SizedBox(height: 32),

            // Title
            const Text(
              'Select Your Primary Subject',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF000000),
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Choose the subject you want to focus on',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Subjects Grid
            Expanded(
              child: Consumer<OnboardingProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoadingSubjects) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                    );
                  }

                  if (provider.subjects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No subjects available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please try again later',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _fetchSubjects,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: provider.subjects.length,
                    itemBuilder: (context, index) {
                      final subject = provider.subjects[index];
                      final isSelected = provider.selectedSubject?.id == subject.id;

                      return _SubjectCard(
                        subject: subject,
                        isSelected: isSelected,
                        onTap: () => provider.selectSubject(subject),
                      );
                    },
                  );
                },
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Consumer<OnboardingProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: provider.isSubmitting ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                      ),
                      child: provider.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon or placeholder
            if (subject.iconUrl != null && subject.iconUrl!.isNotEmpty)
              Image.network(
                subject.iconUrl!,
                width: 48,
                height: 48,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: AppColors.primaryBlue,
                  );
                },
              )
            else
              const Icon(
                Icons.school_outlined,
                size: 48,
                color: AppColors.primaryBlue,
              ),

            const SizedBox(height: 8),

            // Subject name
            Flexible(
              child: Text(
                subject.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                ),
              ),
            ),

            // Selected indicator
            if (isSelected) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Selected',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
