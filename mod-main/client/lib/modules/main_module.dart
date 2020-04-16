

import 'package:flutter_modular/flutter_modular.dart';
import 'package:meta/meta.dart';
import 'package:mod_main/core/core.dart';

import 'package:mod_main/core/shared_repositories/mocks/mock_org_repository.dart';
import 'package:mod_main/core/shared_repositories/mocks/mock_support_role_repository.dart';
import 'package:mod_main/core/shared_repositories/mocks/mock_user_need_repository.dart';
import 'org_manager/orgs/views/orgs_manager_view_mobile.dart';
import 'orgs/service/orgs_service.dart';
import 'orgs/views/org_view.dart';
import 'user_needs/services/user_need_service.dart';
import 'splash/views/splash_view.dart';
import 'support_roles/services/support_role_service.dart';
import 'support_roles/views/support_role_view.dart';
import 'user_needs/views/user_need_view.dart';
import 'userinfo/views/userinfo_view.dart';
import '../modules/org_manager/orgs/views/orgs_manager_view.dart';


class MainAppModule extends ChildModule{

  final String baseRoute;
  final String url;
  final String urlNative;

  // static String cutOffBaseRoute(String route) {
  //   if (route.indexOf(baseRoute) < 0) return route;
  //   return route.substring(
  //       route.indexOf(baseRoute) + baseRoute.length, route.length);
  // }

  MainAppModule({String baseRoute,  String url, String urlNative,}) : 
   this.baseRoute = (baseRoute == '/') ? '' : baseRoute,
   this.url  = url,
   this.urlNative = urlNative;

  @override
  List<Bind> get binds => [
      Bind((i) => Paths(baseRoute)),
      Bind((i) => EnvConfig(url , urlNative)),
      Bind((i) => OrgsService(repository: MockOrgRepository())), // TODO Replace this later with OrgRepository
      Bind((i) => UserNeedService(repository: MockUserNeedRepository())), // TODO Replace this later with UserNeedRepository
      Bind((i) => SupportRoleService(repository: MockSupportRoleRepository())) // TODO Replace this later with SupportRoleRepository
  ];
  
  @override
  List<Router> get routers => [
    Router("/", child: (_, args) => SplashView()),
    /// Non-Admin Dashboard Routes
    Router("/userInfo", child: (_, args) => UserInfoView()),
    Router("/orgs", child: (_, args) => OrgView()),
    Router("/myneeds/orgs/:id", child: (_, args) => UserNeedsView(orgID: args.params['id'],)),
    Router("/supportRoles/orgs/:id", child: (_, args) => SupportRoleView(orgId: args.params['id'],)),
    /// Admin Dashboard Routes
    Router("/dashboard", child: (_, args) => OrgManagerView()),
    Router("/dashboard/orgs/:id", child: (_, args) => OrgsDetailViewMobile(orgID: args.params['id'],)),
  ];

  static Inject get to => Inject<MainAppModule>.of();
}