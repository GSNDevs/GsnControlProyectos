import 'product.dart';
import 'project.dart';
import 'project_details_physical.dart';
import 'project_details_software.dart';
import 'iteration.dart';
import 'task.dart';
import 'project_inventory.dart';

export 'product.dart';
export 'project.dart';
export 'project_details_physical.dart';
export 'project_details_software.dart';
export 'iteration.dart';
export 'task.dart';
export 'project_inventory.dart';

// ----------------------------------------
// MOCK DATA GENERATOR (UPDATED TO NEW MODELS)
// ----------------------------------------

class MockData {
  static final List<Product> products = [
    const Product(
      id: '1',
      name: 'Cámara Hikvision 4MP',
      sku: 'CAM-HIK-001',
      category: 'Seguridad',
      defaultPrice: 45000,
      stockCount: 12,
    ),
    const Product(
      id: '2',
      name: 'Servidor Dell PowerEdge',
      sku: 'SRV-DELL-X1',
      category: 'Infraestructura',
      defaultPrice: 1500000,
      stockCount: 2,
    ),
    const Product(
      id: '3',
      name: 'Cable UTP Cat6 Bobina',
      sku: 'CBL-UTP-C6',
      category: 'Cableado',
      defaultPrice: 80000,
      stockCount: 50,
    ),
    const Product(
      id: '4',
      name: 'Lector Biométrico ZK',
      sku: 'BIO-ZK-T4',
      category: 'Control Acceso',
      defaultPrice: 120000,
      stockCount: 8,
    ),
  ];

  static final List<Project> projects = [
    Project(
      id: '101',
      name: 'Instalación CCTV Cencosud',
      clientId: 'CENCOSUD',
      type: ProjectType.physical,
      status: ProjectStatus.in_progress,
      budgetTotal: 5000000,
      billedAmount: 2500000,
      pendingAmount: 2500000,
      progress: 50,
      createdAt: DateTime.now(), // Proxied
      detailsPhysical: const ProjectDetailsPhysical(
        projectId: '101',
        address: 'Av. Kennedy 9001, Las Condes',
      ),
    ),
    Project(
      id: '102',
      name: 'App de Control de Rondas',
      clientId: 'GSN_INTERNAL',
      type: ProjectType.software,
      status: ProjectStatus.planning,
      budgetTotal: 3000000,
      progress: 10,
      createdAt: DateTime.now(),
      detailsSoftware: const ProjectDetailsSoftware(
        projectId: '102',
        repoUrl: 'gitlab.com/gsn/rondas_app',
      ),
    ),
    Project(
      id: '103',
      name: 'Sistema de Acceso + App Móvil',
      clientId: 'FARMACIAS_AHUMADA',
      type: ProjectType.hybrid,
      status: ProjectStatus.blocked,
      budgetTotal: 8500000,
      billedAmount: 1000000,
      pendingAmount: 7500000,
      progress: 25,
      createdAt: DateTime.now(),
      detailsPhysical: const ProjectDetailsPhysical(
        projectId: '103',
        address: 'Callao 123, Providencia',
      ),
      detailsSoftware: const ProjectDetailsSoftware(
        projectId: '103',
        repoUrl: 'github.com/gsn/access_control',
      ),
    ),
  ];

  static final List<Iteration> iterations = [
    // Project 101
    Iteration(
      id: 'it_1',
      projectId: '101',
      name: 'Fase 1: Cableado',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      clientApprovalStatus: IterationApprovalStatus.approved,
    ),
    Iteration(
      id: 'it_2',
      projectId: '101',
      name: 'Fase 2: Instalación Cámaras',
      startDate: DateTime.now().add(const Duration(days: 6)),
      endDate: DateTime.now().add(const Duration(days: 20)),
    ),
    // Project 102
    Iteration(
      id: 'it_3',
      projectId: '102',
      name: 'Sprint 1: Diseño UI',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 14)),
    ),
  ];

  static final List<Task> tasks = [
    // Iteration 1
    const Task(
      id: 't_1',
      iterationId: 'it_1',
      title: 'Tendido Cable UTP Piso 1',
      description: 'Cableado estructurado zona norte',
      status: TaskStatus.done,
      assignedTo: ['Juan Perez'],
    ),
    const Task(
      id: 't_2',
      iterationId: 'it_1',
      title: 'Certificación Puntos',
      description: 'Pruebas con Fluke',
      status: TaskStatus.doing,
      assignedTo: ['Pedro Soto'],
    ),
    // Iteration 2
    const Task(
      id: 't_3',
      iterationId: 'it_2',
      title: 'Montaje Cámaras PTZ',
      description: 'Instalar soportes y cámaras',
      status: TaskStatus.todo,
    ),
    // Iteration 3
    const Task(
      id: 't_4',
      iterationId: 'it_3',
      title: 'Mockups Figma',
      description: 'Pantallas Login y Home',
      status: TaskStatus.doing,
      assignedTo: ['Maria Graf'],
    ),
  ];

  static final List<ProjectInventory> projectInventories = [
    ProjectInventory(
      id: 'pi_1',
      projectId: '101',
      productId: '1',
      quantity: 8,
      status: 'installed',
    ),
    ProjectInventory(
      id: 'pi_2',
      projectId: '101',
      productId: '3',
      quantity: 2,
      status: 'reserved',
    ),
    ProjectInventory(
      id: 'pi_3',
      projectId: '103',
      productId: '4',
      quantity: 4,
      status: 'reserved',
    ),
  ];
}
