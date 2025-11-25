# Examen Unidad 3 - Automatización de Calidad con GitHub Actions

**Curso:** Soluciones Moviles II
**Fecha:** 18/11/2025  
**Estudiante:** Alvaro Javier Contreras Lipa  
**Repositorio:** https://github.com/AlvaroContreras13/SM2_ExamenUnidad3
**Reporte:** **Debido a la caida de Github se creo un archivo de reporte_pruebas.html que puede encontrar en la raiz del repositorio**

---

## Descripción del Proyecto

Este proyecto implementa un sistema de automatización de calidad usando GitHub Actions para una aplicación móvil desarrollada en Flutter.

---

## Objetivos Alcanzados

- Creación de repositorio público en GitHub  
- Implementación de pruebas unitarias (19 tests)  
- Configuración de workflow de GitHub Actions  
- Análisis automático de código con `flutter analyze`  
- Ejecución automática de tests con `flutter test`

---

## Pruebas Unitarias Implementadas

Se crearon **19 pruebas unitarias** distribuidas en 3 grupos:

### 1. TripStatus Tests (5 pruebas)
- Validación de estados válidos e inválidos
- Verificación de textos descriptivos
- Validación de colores hexadecimales
![test 1](evidencia/test1.png)

### 2. AddressResolver Tests (5 pruebas)
- Manejo de datos nulos
- Resolución de direcciones desde coordenadas
- Formateo de ubicaciones
![test 2](evidencia/test2.png)

### 3. RatingService Tests (9 pruebas)
- Validación de rangos de calificación
- Prevención de auto-calificación
- Gestión de calificaciones de usuarios
![test 3.1](evidencia/test3-1.png)
![test 3.2](evidencia/test3-2.png)

---

## Estructura del Proyecto
```
SM2_ExamenUnidad3/
├── .github/
│   └── workflows/
│       └── quality-check.yml
├── test/
│   └── main_test.dart
├── lib/
│   ├── constants/
│   │   └── trip_status.dart
│   ├── utils/
│   │   └── address_resolver.dart
│   └── services/
│       └── rating_service.dart
└── README.md
```

---

## Configuración del Workflow

El archivo `quality-check.yml` ejecuta automáticamente:

1. **Checkout del código**
2. **Instalación de Flutter 3.19.0**
3. **Instalación de dependencias** (`flutter pub get`)
4. **Análisis de código** (`flutter analyze`)
5. **Ejecución de tests** (`flutter test`)

---

## Evidencias

### 1. Estructura de carpetas .github/workflows/
![estructura](evidencia/estructura.png)

### 2. Contenido del archivo quality-check.yml
![contenido](evidencia/workflow.png)

### 3. Ejecución exitosa del workflow
![ejecucion](evidencia/ejecucion.png)

### 4. Detalle de la ejecución
![detalle](evidencia/reporte-auxiliar.png)

---

## Resultados

- **Tests ejecutados:** 19/19 
- **Tests pasados:** 19 (100%)
- **Tests fallidos:** 0
- **Análisis de código:** Completado

---

## Ejecución Local
```bash
# Instalar dependencias
flutter pub get

# Ejecutar tests
flutter test test/main_test.dart

# Analizar código
flutter analyze
```

---

## Dependencias de Testing
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  fake_cloud_firestore: ^3.0.3
  mockito: ^5.4.4
  build_runner: ^2.4.13
```

---

## Conclusiones

Se implementó exitosamente un pipeline de CI/CD básico usando GitHub Actions que:
- Valida la calidad del código automáticamente
- Ejecuta pruebas unitarias en cada commit
- Garantiza que el código cumpla con los estándares establecidos
- Previene la integración de código con errores

---
