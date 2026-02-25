import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsn_control_de_proyectos/services/inventory_catalog_service.dart';
import 'package:gsn_control_de_proyectos/services/projects_service.dart';
import 'package:gsn_control_de_proyectos/services/iterations_service.dart';
import 'package:gsn_control_de_proyectos/services/tasks_service.dart';
import 'package:gsn_control_de_proyectos/services/project_inventory_service.dart';
import 'package:gsn_control_de_proyectos/services/profiles_service.dart';
import 'package:gsn_control_de_proyectos/services/project_documents_service.dart';
import 'package:gsn_control_de_proyectos/services/task_documents_service.dart';
import 'package:gsn_control_de_proyectos/services/project_payments_service.dart';
import 'package:gsn_control_de_proyectos/services/product_categories_service.dart';
import 'package:gsn_control_de_proyectos/services/notifications_service.dart';
import 'package:gsn_control_de_proyectos/services/quotes_service.dart';

final notificationsServiceProvider = Provider((ref) => NotificationsService());

final inventoryCatalogServiceProvider = Provider(
  (ref) => InventoryCatalogService(),
);
final projectsServiceProvider = Provider((ref) => ProjectsService());
final iterationsServiceProvider = Provider((ref) => IterationsService());
final tasksServiceProvider = Provider((ref) => TasksService());
final projectInventoryServiceProvider = Provider(
  (ref) => ProjectInventoryService(),
);
final profilesServiceProvider = Provider((ref) => ProfilesService());
final projectDocumentsServiceProvider = Provider(
  (ref) => ProjectDocumentsService(),
);
final taskDocumentsServiceProvider = Provider((ref) => TaskDocumentsService());
final projectPaymentsServiceProvider = Provider(
  (ref) => ProjectPaymentsService(),
);
final productCategoriesServiceProvider = Provider(
  (ref) => ProductCategoriesService(),
);

final quotesServiceProvider = Provider((ref) => QuotesService());
