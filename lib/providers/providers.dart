import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsn_control_de_proyectos/models/models.dart';
import 'package:gsn_control_de_proyectos/providers/services_providers.dart';

export 'package:gsn_control_de_proyectos/providers/services_providers.dart';

// ----------------------------------------
// INVENTORY
// ----------------------------------------
final inventoryProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(inventoryCatalogServiceProvider);
  final data = await service.getProducts();
  return data.map((e) => Product.fromJson(e)).toList();
});

final inventoryControllerProvider = Provider((ref) => InventoryController(ref));

class InventoryController {
  final Ref ref;
  InventoryController(this.ref);

  Future<void> addProduct(Map<String, dynamic> productData) async {
    final service = ref.read(inventoryCatalogServiceProvider);
    await service.createProduct(productData);
    ref.invalidate(inventoryProvider);
  }

  Future<void> removeProduct(String productId) async {
    final service = ref.read(inventoryCatalogServiceProvider);
    await service.deleteProduct(productId);
    ref.invalidate(inventoryProvider);
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    final service = ref.read(inventoryCatalogServiceProvider);
    await service.updateProduct(productId, updates);
    ref.invalidate(inventoryProvider);
  }
}

// ----------------------------------------
// PROJECTS
// ----------------------------------------
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final service = ref.watch(projectsServiceProvider);
  final data = await service.getProjects();
  return data.map((e) => Project.fromJson(e)).toList();
});

final projectsControllerProvider = Provider((ref) => ProjectsController(ref));

class ProjectsController {
  final Ref ref;
  ProjectsController(this.ref);

  Future<void> createProject(Map<String, dynamic> projectData) async {
    final service = ref.read(projectsServiceProvider);
    await service.createProject(projectData);
    ref.invalidate(projectsProvider);
  }

  Future<void> updateStatus(String projectId, ProjectStatus newStatus) async {
    final service = ref.read(projectsServiceProvider);
    await service.updateProject(projectId, {'status': newStatus.name});
    ref.invalidate(projectsProvider);
  }

  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> updates,
  ) async {
    final service = ref.read(projectsServiceProvider);
    await service.updateProject(projectId, updates);
    ref.invalidate(projectsProvider);
  }

  Future<void> cloneProject(
    Map<String, dynamic> projectData,
    String sourceProjectId,
  ) async {
    final projService = ref.read(projectsServiceProvider);
    final iterService = ref.read(iterationsServiceProvider);
    final tasksService = ref.read(tasksServiceProvider);

    // 1. Create new project
    final newProjectId = await projService.createProject(projectData);

    // 2. Clone project details if they exist
    final sourceProject = await projService.getProjectById(sourceProjectId);
    if (sourceProject != null) {
      if (sourceProject['project_details_physical'] != null &&
          (sourceProject['project_details_physical'] as List).isNotEmpty) {
        final physical =
            sourceProject['project_details_physical'][0]
                as Map<String, dynamic>;
        final Map<String, dynamic> pData = Map.from(physical)
          ..remove('project_id'); // remove old id
        pData['project_id'] = newProjectId;
        await projService.createProjectDetailsPhysical(pData);
      }
      if (sourceProject['project_details_software'] != null &&
          (sourceProject['project_details_software'] as List).isNotEmpty) {
        final software =
            sourceProject['project_details_software'][0]
                as Map<String, dynamic>;
        final Map<String, dynamic> sData = Map.from(software)
          ..remove('project_id'); // remove old id
        sData['project_id'] = newProjectId;
        await projService.createProjectDetailsSoftware(sData);
      }
    }

    // 3. Clone iterations
    final sourceIterations = await iterService.getProjectIterations(
      sourceProjectId,
    );
    for (final iter in sourceIterations) {
      final newIterData = {
        'project_id': newProjectId,
        'name': iter['name'],
        'start_date': iter['start_date'],
        'end_date': iter['end_date'],
        'client_approval_status': 'pending',
      };
      final newIterIdStr = await iterService.createIteration(newIterData);

      // 4. Clone tasks for this iteration
      final sourceTasks = await tasksService.getIterationTasks(iter['id']);
      for (final task in sourceTasks) {
        final newTaskData = {
          'iteration_id': newIterIdStr,
          'title': task['title'],
          'status': 'todo',
        };
        await tasksService.createTask(newTaskData);
      }
    }

    ref.invalidate(projectsProvider);
  }
}

// ----------------------------------------
// ITERATIONS (SPRINTS)
// ----------------------------------------
final iterationsProvider = FutureProvider.family<List<Iteration>, String>((
  ref,
  projectId,
) async {
  final service = ref.watch(iterationsServiceProvider);
  final data = await service.getProjectIterations(projectId);
  return data.map((e) => Iteration.fromJson(e)).toList();
});

final iterationsControllerProvider = Provider(
  (ref) => IterationsController(ref),
);

class IterationsController {
  final Ref ref;
  IterationsController(this.ref);

  Future<void> createIteration(Map<String, dynamic> iterationData) async {
    final service = ref.read(iterationsServiceProvider);
    await service.createIteration(iterationData);
    // Invalidate specific family provider not easy without saving arguments,
    // but usually we act on a screen where we know the projectId.
    // For now we might need to rely on parent refresh or careful invalidation.
    // Actually, we can invalidate(iterationsProvider(projectId)) if we pass projectId here.
  }

  Future<void> createIterationForProject(
    String projectId,
    Map<String, dynamic> iterationData,
  ) async {
    final service = ref.read(iterationsServiceProvider);
    await service.createIteration(iterationData);
    ref.invalidate(iterationsProvider(projectId));
  }

  Future<void> deleteIteration(String projectId, String iterationId) async {
    final service = ref.read(iterationsServiceProvider);
    await service.deleteIteration(iterationId);
    ref.invalidate(iterationsProvider(projectId));
  }

  Future<void> updateIterationDetails(
    String projectId,
    String iterationId,
    Map<String, dynamic> updates,
  ) async {
    final service = ref.read(iterationsServiceProvider);
    await service.updateIteration(iterationId, updates);
    ref.invalidate(iterationsProvider(projectId));
  }

  Future<void> requestClientApproval(
    String projectId,
    String iterationId,
    String iterationName,
    String clientId,
  ) async {
    final service = ref.read(iterationsServiceProvider);
    await service.updateIteration(iterationId, {
      'client_approval_status': IterationApprovalStatus.pending.name,
    });

    // Notify the client
    final notifService = ref.read(notificationsServiceProvider);
    await notifService.createNotification({
      'recipient_id': clientId,
      'message': 'Nueva solicitud de aprobación para el sprint: $iterationName',
      'related_project_id': projectId,
    });

    ref.invalidate(iterationsProvider(projectId));
  }

  Future<void> respondClientApproval(
    String projectId,
    String iterationId,
    String iterationName,
    String projectOwnerId,
    bool approved,
  ) async {
    final service = ref.read(iterationsServiceProvider);
    final status = approved
        ? IterationApprovalStatus.approved.name
        : IterationApprovalStatus.rejected.name;

    await service.updateIteration(iterationId, {
      'client_approval_status': status,
      'client_approval_date': DateTime.now().toIso8601String(),
    });

    // Notify the project owner
    if (projectOwnerId.isNotEmpty) {
      final notifService = ref.read(notificationsServiceProvider);
      final statusMsg = approved ? 'Aprobado' : 'Rechazado';
      await notifService.createNotification({
        'recipient_id': projectOwnerId,
        'message': 'El cliente ha $statusMsg el sprint: $iterationName',
        'related_project_id': projectId,
      });
    }

    ref.invalidate(iterationsProvider(projectId));
  }
}

// ----------------------------------------
// TASKS
// ----------------------------------------
final tasksProvider = FutureProvider.family<List<Task>, String>((
  ref,
  iterationId,
) async {
  final service = ref.watch(tasksServiceProvider);
  final data = await service.getIterationTasks(iterationId);
  return data.map((e) => Task.fromJson(e)).toList();
});

final tasksControllerProvider = Provider((ref) => TasksController(ref));

class TasksController {
  final Ref ref;
  TasksController(this.ref);

  Future<void> _recalculateProjectProgress(String iterationId) async {
    try {
      final itService = ref.read(iterationsServiceProvider);
      // Fetch the iteration to get the project_id
      final iteration = await itService.getIterationDetails(iterationId);
      final projectId = iteration['project_id'];

      // Get all iterations for the project
      final projectIterations = await itService.getProjectIterations(projectId);

      final taskService = ref.read(tasksServiceProvider);
      int totalTasks = 0;
      int doneTasks = 0;

      // Loop over iterations to fetch tasks
      for (final itr in projectIterations) {
        final tasksRaw = await taskService.getIterationTasks(itr['id']);
        final tasksList = tasksRaw.map((e) => Task.fromJson(e)).toList();

        totalTasks += tasksList.length;
        doneTasks += tasksList.where((t) => t.status == TaskStatus.done).length;
      }

      final int progress = totalTasks > 0
          ? ((doneTasks / totalTasks) * 100).round()
          : 0;

      final projService = ref.read(projectsServiceProvider);
      await projService.updateProject(projectId, {'progress': progress});
      ref.invalidate(projectsProvider);
    } catch (e) {
      // Ignorar errores silentes si la fase ya fue borrada o no se puede recalcular
    }
  }

  Future<void> createTask(
    String iterationId,
    Map<String, dynamic> taskData,
  ) async {
    final service = ref.read(tasksServiceProvider);
    await service.createTask(taskData);

    // Notify assigned users
    final assignedTo = taskData['assigned_to'];
    if (assignedTo != null && assignedTo is List && assignedTo.isNotEmpty) {
      final notifService = ref.read(notificationsServiceProvider);
      for (final userId in assignedTo) {
        await notifService.createNotification({
          'recipient_id': userId,
          'message': 'Se te ha asignado la tarea: ${taskData['title']}',
        });
      }
    }

    ref.invalidate(tasksProvider(iterationId));
    await _recalculateProjectProgress(iterationId);
  }

  Future<void> updateTaskStatus(
    String iterationId,
    String taskId,
    TaskStatus status,
  ) async {
    final service = ref.read(tasksServiceProvider);
    await service.updateTask(taskId, {'status': status.name});
    ref.invalidate(tasksProvider(iterationId));
    await _recalculateProjectProgress(iterationId);
  }

  Future<void> updateTaskDetails(
    String iterationId,
    String taskId,
    Map<String, dynamic> updates,
  ) async {
    final service = ref.read(tasksServiceProvider);
    await service.updateTask(taskId, updates);
    ref.invalidate(tasksProvider(iterationId));
  }

  Future<void> deleteTask(String iterationId, String taskId) async {
    final service = ref.read(tasksServiceProvider);
    await service.deleteTask(taskId);
    ref.invalidate(tasksProvider(iterationId));
    await _recalculateProjectProgress(iterationId);
  }

  Future<void> deleteTaskEvidence(String iterationId, String taskId) async {
    final service = ref.read(tasksServiceProvider);
    await service.updateTask(taskId, {'evidence_url': null});
    ref.invalidate(tasksProvider(iterationId));
  }

  Future<void> updateTaskAssignees(
    String iterationId,
    String taskId,
    List<String> assignees,
  ) async {
    final service = ref.read(tasksServiceProvider);
    await service.updateTask(taskId, {'assigned_to': assignees});

    // Optionally notify new assignees? For now just update and refresh.
    ref.invalidate(tasksProvider(iterationId));
  }

  Future<void> uploadEvidence(
    String iterationId,
    String taskId,
    Uint8List fileBytes,
    String fileName,
  ) async {
    final service = ref.read(tasksServiceProvider);
    await service.uploadTaskEvidence(taskId, fileBytes, fileName);
    ref.invalidate(tasksProvider(iterationId));
  }
}

// ----------------------------------------
// PROJECT INVENTORY
// ----------------------------------------
final projectInventoryProvider =
    FutureProvider.family<List<ProjectInventory>, String>((
      ref,
      projectId,
    ) async {
      final service = ref.watch(projectInventoryServiceProvider);
      final data = await service.getProjectInventory(projectId);
      return data.map((e) => ProjectInventory.fromJson(e)).toList();
    });

final projectInventoryControllerProvider = Provider(
  (ref) => ProjectInventoryController(ref),
);

class ProjectInventoryController {
  final Ref ref;
  ProjectInventoryController(this.ref);

  Future<void> assignProduct(
    String projectId,
    Map<String, dynamic> data,
  ) async {
    final service = ref.read(projectInventoryServiceProvider);
    await service.assignProduct(data);
    ref.invalidate(projectInventoryProvider(projectId));
  }

  Future<void> returnProduct(String projectId, String id, int quantity) async {
    final service = ref.read(projectInventoryServiceProvider);
    await service.removeAssignment(id);
    ref.invalidate(projectInventoryProvider(projectId));
  }

  Future<void> updateQuantity(
    String projectId,
    String id,
    int newQuantity,
  ) async {
    final service = ref.read(projectInventoryServiceProvider);
    await service.updateAssignment(id, {'quantity': newQuantity});
    ref.invalidate(projectInventoryProvider(projectId));
  }
}

// ----------------------------------------
// PROFILES / USERS
// ----------------------------------------
final clientsProvider = FutureProvider<List<Profile>>((ref) async {
  final service = ref.watch(profilesServiceProvider);
  final data = await service.getClients();
  return data.map((e) => Profile.fromJson(e)).toList();
});

final profilesProvider = FutureProvider<List<Profile>>((ref) async {
  final service = ref.watch(profilesServiceProvider);
  final data = await service.getProfiles();
  return data.map((e) => Profile.fromJson(e)).toList();
});

// ----------------------------------------
// PROJECT DOCUMENTS
// ----------------------------------------
final projectDocumentsProvider =
    FutureProvider.family<List<ProjectDocument>, String>((
      ref,
      projectId,
    ) async {
      final service = ref.watch(projectDocumentsServiceProvider);
      final data = await service.getProjectDocuments(projectId);
      return data.map((e) => ProjectDocument.fromJson(e)).toList();
    });

final projectDocumentsControllerProvider = Provider(
  (ref) => ProjectDocumentsController(ref),
);

class ProjectDocumentsController {
  final Ref ref;
  ProjectDocumentsController(this.ref);

  Future<void> uploadDocument(
    String projectId,
    Uint8List fileBytes,
    String fileName,
    String fileType,
  ) async {
    final service = ref.read(projectDocumentsServiceProvider);
    await service.uploadDocument(projectId, fileBytes, fileName, fileType);
    ref.invalidate(projectDocumentsProvider(projectId));
  }

  Future<void> deleteDocument(
    String projectId,
    String documentId,
    String fileUrl,
  ) async {
    final service = ref.read(projectDocumentsServiceProvider);
    await service.deleteDocument(documentId, fileUrl);
    ref.invalidate(projectDocumentsProvider(projectId));
  }
}

// ----------------------------------------
// TASK DOCUMENTS
// ----------------------------------------
final taskDocumentsProvider = FutureProvider.family<List<TaskDocument>, String>(
  (ref, taskId) async {
    final service = ref.watch(taskDocumentsServiceProvider);
    final data = await service.getTaskDocuments(taskId);
    return data.map((e) => TaskDocument.fromJson(e)).toList();
  },
);

final taskDocumentsControllerProvider = Provider(
  (ref) => TaskDocumentsController(ref),
);

class TaskDocumentsController {
  final Ref ref;
  TaskDocumentsController(this.ref);

  Future<void> uploadDocument(
    String taskId,
    Uint8List fileBytes,
    String fileName,
  ) async {
    final service = ref.read(taskDocumentsServiceProvider);
    await service.uploadDocument(taskId, fileBytes, fileName);
    ref.invalidate(taskDocumentsProvider(taskId));
  }

  Future<void> deleteDocument(
    String taskId,
    String documentId,
    String fileUrl,
  ) async {
    final service = ref.read(taskDocumentsServiceProvider);
    await service.deleteDocument(documentId, fileUrl);
    ref.invalidate(taskDocumentsProvider(taskId));
  }
}

// ----------------------------------------
// PROJECT PAYMENTS (COBROS)
// ----------------------------------------
final projectPaymentsProvider =
    FutureProvider.family<List<ProjectPayment>, String>((ref, projectId) async {
      final service = ref.watch(projectPaymentsServiceProvider);
      final data = await service.getProjectPayments(projectId);
      return data.map((e) => ProjectPayment.fromJson(e)).toList();
    });

final projectPaymentsControllerProvider = Provider(
  (ref) => ProjectPaymentsController(ref),
);

class ProjectPaymentsController {
  final Ref ref;
  ProjectPaymentsController(this.ref);

  Future<void> addPayment(String projectId, Map<String, dynamic> data) async {
    final service = ref.read(projectPaymentsServiceProvider);
    await service.addPayment(data);
    ref.invalidate(projectPaymentsProvider(projectId));
  }

  Future<void> updatePayment(
    String projectId,
    String paymentId,
    Map<String, dynamic> updates,
  ) async {
    final service = ref.read(projectPaymentsServiceProvider);
    await service.updatePayment(paymentId, updates);
    ref.invalidate(projectPaymentsProvider(projectId));
  }

  Future<void> deletePayment(String projectId, String paymentId) async {
    final service = ref.read(projectPaymentsServiceProvider);
    await service.deletePayment(paymentId);
    ref.invalidate(projectPaymentsProvider(projectId));
  }
}

// ----------------------------------------
// PRODUCT CATEGORIES
// ----------------------------------------
final productCategoriesProvider = FutureProvider<List<ProductCategory>>((
  ref,
) async {
  final service = ref.watch(productCategoriesServiceProvider);
  return await service.getCategories();
});

final productCategoriesControllerProvider = Provider(
  (ref) => ProductCategoriesController(ref),
);

class ProductCategoriesController {
  final Ref ref;
  ProductCategoriesController(this.ref);

  Future<void> addCategory(Map<String, dynamic> data) async {
    final service = ref.read(productCategoriesServiceProvider);
    await service.createCategory(data);
    ref.invalidate(productCategoriesProvider);
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    final service = ref.read(productCategoriesServiceProvider);
    await service.updateCategory(id, data);
    ref.invalidate(productCategoriesProvider);
  }

  Future<void> deleteCategory(String id) async {
    final service = ref.read(productCategoriesServiceProvider);
    await service.deleteCategory(id);
    ref.invalidate(productCategoriesProvider);
  }
}

// ----------------------------------------
// QUOTES
// ----------------------------------------

final allQuotesProvider = FutureProvider<List<Quote>>((ref) async {
  final service = ref.watch(quotesServiceProvider);
  return await service.getAllQuotes();
});

final clientQuotesProvider = FutureProvider.family<List<Quote>, String>((
  ref,
  clientId,
) async {
  final service = ref.watch(quotesServiceProvider);
  return await service.getClientQuotes(clientId);
});

final quotesControllerProvider = Provider((ref) => QuotesController(ref));

class QuotesController {
  final Ref ref;
  QuotesController(this.ref);

  Future<void> createQuote(Map<String, dynamic> quoteData) async {
    final service = ref.read(quotesServiceProvider);
    await service.createQuote(quoteData);

    // Invalidate both lists
    ref.invalidate(allQuotesProvider);
    if (quoteData['client_id'] != null) {
      ref.invalidate(clientQuotesProvider(quoteData['client_id']));
    }
  }

  Future<String> uploadDocument(
    String clientId,
    Uint8List fileBytes,
    String fileName,
  ) async {
    final service = ref.read(quotesServiceProvider);
    return await service.uploadQuoteDocument(clientId, fileBytes, fileName);
  }
}
