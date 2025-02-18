import '/resources/pages/add_task_page.dart';
import '/resources/pages/edit_task_page.dart';
import '../resources/pages/sign_in_page.dart';
import '../resources/pages/sign_up_page.dart';
import '../resources/pages/task_list_page.dart';
import '/resources/pages/profile_page.dart';
import '/resources/pages/bottom_nav_bar_page.dart';
import '/resources/pages/dashboard_page.dart';
import '/resources/pages/not_found_page.dart';
import '/resources/pages/home_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* App Router
|--------------------------------------------------------------------------
| * [Tip] Create pages faster 🚀
| Run the below in the terminal to create new a page.
| "dart run nylo_framework:main make:page profile_page"
|
| * [Tip] Add authentication 🔑
| Run the below in the terminal to add authentication to your project.
| "dart run scaffold_ui:main auth"
|
| * [Tip] Add In-app Purchases 💳
| Run the below in the terminal to add In-app Purchases to your project.
| "dart run scaffold_ui:main iap"
|
| Learn more https://nylo.dev/docs/6.x/router
|-------------------------------------------------------------------------- */

appRouter() => nyRoutes((router) {
      router.add(HomePage.path);
      // Add your routes here ...

      // router.add(NewPage.path, transition: PageTransitionType.fade);

      // Example using grouped routes
      // router.group(() => {
      //   "route_guards": [AuthRouteGuard()],
      //   "prefix": "/dashboard"
      // }, (router) {
      //
      // });
      router.add(NotFoundPage.path).unknownRoute();
      router.add(DashboardPage.path);
      router.add(BottomNavBarPage.path);
      router.add(ProfilePage.path);
      router
          .add(SignInPage.path, transition: PageTransitionType.fade)
          .initialRoute();
      router.add(SignUpPage.path, transition: PageTransitionType.fade);
      router.add(TaskListPage.path, transition: PageTransitionType.leftToRight);
      router.add(EditTaskPage.path);
      router.add(AddTaskPage.path, transition: PageTransitionType.bottomToTop);
    });
