/// Validadores para el sistema de autenticación de MovUni
/// Basados en las reglas de negocio de AuthService
class Validators {
  // 1. Validar Email Institucional UPT
  /// Valida que el email sea del dominio institucional @virtual.upt.pe
  /// Retorna true si es válido, false en caso contrario
  static bool isValidInstitutionalEmail(String email) {
    return email.endsWith('@virtual.upt.pe');
  }

  // 2. Validar Contraseña Segura
  /// Valida que la contraseña tenga al menos 6 caracteres (requisito Firebase)
  /// Retorna true si cumple el requisito, false en caso contrario
  static bool isSecurePassword(String password) {
    return password.length >= 6;
  }

  // 3. Validar DNI Peruano
  /// Valida que el DNI tenga exactamente 8 dígitos numéricos
  /// Retorna true si es válido, false en caso contrario
  static bool isValidDNI(String dni) {
    // Eliminar espacios en blanco
    final cleanDNI = dni.trim();
    
    // Verificar que tenga exactamente 8 caracteres
    if (cleanDNI.length != 8) return false;
    
    // Verificar que todos sean dígitos
    return RegExp(r'^\d{8}$').hasMatch(cleanDNI);
  }

  // 4. Validar Teléfono Peruano
  /// Valida que el teléfono tenga 9 dígitos y comience con 9
  /// Retorna true si es válido, false en caso contrario
  static bool isValidPeruvianPhone(String phone) {
    // Eliminar espacios y caracteres especiales
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verificar que tenga 9 dígitos y comience con 9
    return cleanPhone.length == 9 && cleanPhone.startsWith('9');
  }

  // 5. Validar Placa Vehicular Peruana
  /// Valida el formato de placa vehicular peruana (ABC-123 o ABC-1234)
  /// Retorna true si es válido, false en caso contrario
  static bool isValidLicensePlate(String plate) {
    // Eliminar espacios y convertir a mayúsculas
    final cleanPlate = plate.trim().toUpperCase();
    
    // Formato antiguo: ABC-123 (3 letras, guion, 3 números)
    // Formato nuevo: ABC-1234 (3 letras, guion, 4 números)
    final oldFormat = RegExp(r'^[A-Z]{3}-\d{3}$');
    final newFormat = RegExp(r'^[A-Z]{3}-\d{4}$');
    
    return oldFormat.hasMatch(cleanPlate) || newFormat.hasMatch(cleanPlate);
  }
}