import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsn_control_de_proyectos/models/mock_models.dart';

// ----------------------------------------
// INVENTORY PROVIDER
// ----------------------------------------
final inventoryProvider = NotifierProvider<InventoryNotifier, List<Product>>(
  InventoryNotifier.new,
);

class InventoryNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() {
    return MockData.products;
  }

  void addProduct(Product product) {
    state = [...state, product];
  }

  void removeProduct(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  void updateProduct(Product updated) {
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p,
    ];
  }
}

// ----------------------------------------
// PROJECTS PROVIDER
// ----------------------------------------
final projectsProvider = NotifierProvider<ProjectsNotifier, List<Project>>(
  ProjectsNotifier.new,
);

class ProjectsNotifier extends Notifier<List<Project>> {
  @override
  List<Project> build() {
    return MockData.projects;
  }

  void addProject(Project project) {
    state = [...state, project];
  }

  void updateStatus(String projectId, ProjectStatus newStatus) {
    state = [
      for (final p in state)
        if (p.id == projectId)
          Project(
            id: p.id,
            name: p.name,
            clientId: p.clientId,
            type: p.type,
            status: newStatus,
            budgetTotal: p.budgetTotal,
            billedAmount: p.billedAmount,
            pendingAmount: p.pendingAmount,
            currency: p.currency,
            progress: p.progress,
            isTemplate: p.isTemplate,
            createdAt: p.createdAt,
            updatedAt: DateTime.now(),
            detailsPhysical: p.detailsPhysical,
            detailsSoftware: p.detailsSoftware,
          )
        else
          p,
    ];
  }
}

// ----------------------------------------
// ITERATIONS (SPRINTS) PROVIDER
// ----------------------------------------
final iterationsProvider =
    NotifierProvider<IterationsNotifier, List<Iteration>>(
      IterationsNotifier.new,
    );

class IterationsNotifier extends Notifier<List<Iteration>> {
  @override
  List<Iteration> build() {
    return MockData.iterations;
  }

  void addIteration(Iteration iteration) {
    state = [...state, iteration];
  }
}

// ----------------------------------------
// TASKS PROVIDER
// ----------------------------------------
final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);

class TasksNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    return MockData.tasks;
  }

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTaskStatus(String taskId, TaskStatus status) {
    state = [
      for (final t in state)
        if (t.id == taskId)
          Task(
            id: t.id,
            iterationId: t.iterationId,
            title: t.title,
            description: t.description,
            status: status,
            assignedTo: t.assignedTo,
            evidenceUrl: t.evidenceUrl,
          )
        else
          t,
    ];
  }
}

// ----------------------------------------
// PROJECT INVENTORY PROVIDER
// ----------------------------------------
final projectInventoryProvider =
    NotifierProvider<ProjectInventoryNotifier, List<ProjectInventory>>(
      ProjectInventoryNotifier.new,
    );

class ProjectInventoryNotifier extends Notifier<List<ProjectInventory>> {
  @override
  List<ProjectInventory> build() {
    return [
      ProjectInventory(
        id: 'pi_1',
        projectId: '101',
        productId: '1',
        quantity: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ), // 4 Cameras to Project 101
      ProjectInventory(
        id: 'pi_2',
        projectId: '101',
        productId: '3',
        quantity: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ), // 10 Cables to Project 101
    ];
  }

  void assignProductToProject(ProjectInventory item) {
    state = [...state, item];
  }

  void returnProduct(String id, int quantityToReturn) {
    // Logic to reduce quantity or remove item
    // For mock simplicity, we just remove if quantity matches, or do nothing.
    state = state.where((i) => i.id != id).toList();
  }
}
