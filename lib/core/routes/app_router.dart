import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pgme/features/splash/screens/splash_screen.dart';
import 'package:pgme/features/onboarding/screens/onboarding_screen.dart';
import 'package:pgme/features/onboarding/screens/subject_selection_screen.dart';
import 'package:pgme/features/onboarding/screens/congratulations_screen.dart' as onboarding;
import 'package:pgme/features/auth/screens/login_screen.dart';
import 'package:pgme/features/auth/screens/otp_verification_screen.dart';
import 'package:pgme/features/auth/screens/data_collection_screen.dart';
import 'package:pgme/features/auth/screens/multiple_logins_screen.dart';
import 'package:pgme/features/home/screens/main_screen.dart';
import 'package:pgme/features/courses/screens/course_detail_screen.dart';
import 'package:pgme/features/courses/screens/lecture_video_screen.dart';
import 'package:pgme/features/courses/screens/video_player_screen.dart';
import 'package:pgme/features/notes/screens/notes_list_screen.dart';
import 'package:pgme/features/notes/screens/available_notes_screen.dart';
import 'package:pgme/features/notes/screens/your_notes_screen.dart';
import 'package:pgme/features/settings/screens/settings_screen.dart';
import 'package:pgme/features/settings/screens/manage_plans_screen.dart';
import 'package:pgme/features/purchase/screens/purchase_screen.dart';
import 'package:pgme/features/purchase/screens/congratulations_screen.dart';
import 'package:pgme/features/purchase/screens/all_packages_screen.dart';
import 'package:pgme/features/sessions/screens/session_details_screen.dart';
import 'package:pgme/features/notes/screens/order_physical_books_screen.dart';
import 'package:pgme/features/courses/screens/practical_series_screen.dart';
import 'package:pgme/features/courses/screens/revision_series_screen.dart';
import 'package:pgme/core/widgets/app_scaffold.dart';

class AppRouter {
  static int _getNavIndex(String location) {
    if (location.startsWith('/home')) {
      final uri = Uri.parse(location);
      return int.tryParse(uri.queryParameters['tab'] ?? '0') ?? 0;
    }
    if (location.startsWith('/notes') || location.startsWith('/available-notes')) return 2;
    if (location.startsWith('/practical-series') ||
        location.startsWith('/revision-series')) return 1;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Auth Flow
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const OTPVerificationScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/data-collection',
        name: 'data-collection',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DataCollectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/subject-selection',
        name: 'subject-selection',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SubjectSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/onboarding-complete',
        name: 'onboarding-complete',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const onboarding.CongratulationsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      GoRoute(
        path: '/multiple-logins',
        name: 'multiple-logins',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MultipleLoginsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      // Purchase Flow (outside shell - no nav bar)
      GoRoute(
        path: '/purchase',
        name: 'purchase',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PurchaseScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/congratulations',
        name: 'congratulations',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CongratulationsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      GoRoute(
        path: '/all-packages',
        name: 'all-packages',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AllPackagesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/manage-plans',
        name: 'manage-plans',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ManagePlansScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      // Video Player (fullscreen - no nav bar)
      GoRoute(
        path: '/video/:id',
        name: 'video-player',
        pageBuilder: (context, state) {
          final videoId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: VideoPlayerScreen(videoId: videoId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // Shell Route - routes with persistent nav bar
      ShellRoute(
        builder: (context, state, child) {
          final navIndex = _getNavIndex(state.uri.toString());
          final isSubscribed = state.uri.queryParameters['subscribed'] == 'true';
          return AppScaffold(
            currentIndex: navIndex,
            isSubscribed: isSubscribed,
            child: child,
          );
        },
        routes: [
          // Main App
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) {
              final tabIndex = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
              final isSubscribed = state.uri.queryParameters['subscribed'] == 'true';
              return CustomTransitionPage(
                key: state.pageKey,
                child: MainScreen(initialIndex: tabIndex, isSubscribed: isSubscribed),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              );
            },
          ),

          // Course Details
          GoRoute(
            path: '/course/:id',
            name: 'course-detail',
            pageBuilder: (context, state) {
              final seriesId = state.pathParameters['id']!;
              return CustomTransitionPage(
                key: state.pageKey,
                child: CourseDetailScreen(seriesId: seriesId),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),

          // Lecture Video Screen
          GoRoute(
            path: '/lecture/:id',
            name: 'lecture-video',
            pageBuilder: (context, state) {
              final courseId = state.pathParameters['id']!;
              final isSubscribed = state.uri.queryParameters['subscribed'] == 'true';
              return CustomTransitionPage(
                key: state.pageKey,
                child: LectureVideoScreen(courseId: courseId, isSubscribed: isSubscribed),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),

          // Notes
          GoRoute(
            path: '/notes',
            name: 'notes',
            pageBuilder: (context, state) {
              final isSubscribed = state.uri.queryParameters['subscribed'] == 'true';
              return CustomTransitionPage(
                key: state.pageKey,
                child: NotesListScreen(isSubscribed: isSubscribed),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),

          // Available Notes
          GoRoute(
            path: '/available-notes',
            name: 'available-notes',
            pageBuilder: (context, state) {
              final seriesId = state.uri.queryParameters['seriesId'] ?? '';
              return CustomTransitionPage(
                key: state.pageKey,
                child: AvailableNotesScreen(seriesId: seriesId),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),

          // Your Notes (for subscribed users)
          GoRoute(
            path: '/your-notes',
            name: 'your-notes',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const YourNotesScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          ),

          // Session Details
          GoRoute(
            path: '/session-details',
            name: 'session-details',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SessionDetailsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          ),

          // Order Physical Books
          GoRoute(
            path: '/order-physical-books',
            name: 'order-physical-books',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const OrderPhysicalBooksScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          ),

          // Practical Series
          GoRoute(
            path: '/practical-series',
            name: 'practical-series',
            pageBuilder: (context, state) {
              final isSubscribed = state.uri.queryParameters['subscribed'] == 'true';
              final packageId = state.uri.queryParameters['packageId'];
              return CustomTransitionPage(
                key: state.pageKey,
                child: PracticalSeriesScreen(
                  isSubscribed: isSubscribed,
                  packageId: packageId,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),

          // Revision Series (Theory Packages)
          GoRoute(
            path: '/revision-series',
            name: 'revision-series',
            pageBuilder: (context, state) {
              final isSubscribed = state.uri.queryParameters['subscribed'] == 'true';
              final packageId = state.uri.queryParameters['packageId'];
              return CustomTransitionPage(
                key: state.pageKey,
                child: RevisionSeriesScreen(
                  isSubscribed: isSubscribed,
                  packageId: packageId,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
        ],
      ),
    ],
  );
}
