import 'package:flutter_test/flutter_test.dart';
import 'package:movuni/constants/trip_status.dart';
import 'package:movuni/utils/address_resolver.dart';
import 'package:movuni/services/rating_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:movuni/utils/validators.dart';
void main() {
  // TESTS para TripStatus (constants/trip_status.dart)
  group('TripStatus Tests', () {
    test('isValid debe retornar true para estados válidos', () {
      expect(TripStatus.isValid('activo'), true);
      expect(TripStatus.isValid('en_curso'), true);
      expect(TripStatus.isValid('completado'), true);
      expect(TripStatus.isValid('cancelado'), true);
    });

    test('isValid debe retornar false para estados inválidos', () {
      expect(TripStatus.isValid('invalido'), false);
      expect(TripStatus.isValid(''), false);
      expect(TripStatus.isValid('ACTIVO'), false);
      expect(TripStatus.isValid('pendiente'), false);
    });

    test('getDisplayText debe retornar el texto correcto para cada estado', () {
      expect(TripStatus.getDisplayText('activo'), 'Activo');
      expect(TripStatus.getDisplayText('en_curso'), 'En Curso');
      expect(TripStatus.getDisplayText('completado'), 'Completado');
      expect(TripStatus.getDisplayText('cancelado'), 'Cancelado');
      expect(TripStatus.getDisplayText('invalido'), 'Desconocido');
    });

    test('getColorHex debe retornar colores válidos en formato hexadecimal', () {
      expect(TripStatus.getColorHex('activo'), '#4CAF50');
      expect(TripStatus.getColorHex('en_curso'), '#2196F3');
      expect(TripStatus.getColorHex('completado'), '#9E9E9E');
      expect(TripStatus.getColorHex('cancelado'), '#F44336');
      expect(TripStatus.getColorHex('invalido'), '#9E9E9E');
    });

    test('allStatus debe contener exactamente 4 estados', () {
      expect(TripStatus.allStatus.length, 4);
      expect(TripStatus.allStatus, contains('activo'));
      expect(TripStatus.allStatus, contains('en_curso'));
      expect(TripStatus.allStatus, contains('completado'));
      expect(TripStatus.allStatus, contains('cancelado'));
    });
  });

  // TESTS para AddressResolver (utils/address_resolver.dart)
  group('AddressResolver Tests', () {
    test('resolveAddressFromData debe retornar defaultName cuando location es null', () async {
      final result = await resolveAddressFromData(null, 'Ubicación Desconocida');
      expect(result, 'Ubicación Desconocida');
    });

    test('resolveAddressFromData debe retornar el nombre si ya existe y no es coordenada', () async {
      final location = {
        'nombre': 'Universidad Nacional',
        'lat': -12.0464,
        'lng': -77.0428,
      };
      final result = await resolveAddressFromData(location, 'Default');
      expect(result, 'Universidad Nacional');
    });

    test('resolveAddressFromData debe retornar coordenadas formateadas cuando no hay nombre válido', () async {
      final location = {
        'nombre': '',
        'lat': -12.0464,
        'lng': -77.0428,
      };
      final result = await resolveAddressFromData(location, 'Default');
      // Debe contener formato de coordenadas
      expect(result, contains('Lat:'));
      expect(result, contains('Lng:'));
      expect(result, contains('-12.046'));
      expect(result, contains('-77.042'));
    });

    test('resolveAddressFromData debe retornar defaultName cuando no hay coordenadas válidas', () async {
      final location = {
        'nombre': '',
        'lat': null,
        'lng': null,
      };
      final result = await resolveAddressFromData(location, 'Sin Ubicación');
      expect(result, 'Sin Ubicación');
    });

    test('resolveAddressFromData debe manejar coordenadas como int o double', () async {
      final location = {
        'nombre': '',
        'lat': -12,  
        'lng': -77.5,
      };
      final result = await resolveAddressFromData(location, 'Default');
      expect(result, contains('Lat:'));
      expect(result, contains('Lng:'));
    });
  });

  
  // TESTS para RatingService (services/rating_service.dart)
  group('RatingService Tests', () {
    late RatingService ratingService;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      ratingService = RatingService(firestore: fakeFirestore);
    });

    test('createRating debe lanzar excepción si rating está fuera del rango 1-5', () async {
      expect(
        () => ratingService.createRating(
          tripId: 'trip123',
          ratedUserId: 'user1',
          raterUserId: 'user2',
          rating: 0,
        ),
        throwsException,
      );

      expect(
        () => ratingService.createRating(
          tripId: 'trip123',
          ratedUserId: 'user1',
          raterUserId: 'user2',
          rating: 6,
        ),
        throwsException,
      );
    });

    test('createRating debe lanzar excepción si el usuario intenta calificarse a sí mismo', () async {
      expect(
        () => ratingService.createRating(
          tripId: 'trip123',
          ratedUserId: 'user1',
          raterUserId: 'user1',
          rating: 5,
        ),
        throwsException,
      );
    });

    test('createRating debe crear una calificación válida correctamente', () async {
      // Crear el usuario primero para que _updateUserRating funcione
      await fakeFirestore.collection('users').doc('user1').set({
        'firstName': 'Juan',
        'lastName': 'Pérez',
        'rating': 5.0,
        'totalRatings': 0,
      });

      await ratingService.createRating(
        tripId: 'trip123',
        ratedUserId: 'user1',
        raterUserId: 'user2',
        rating: 4.5,
        comment: 'Excelente conductor',
      );

      final ratings = await fakeFirestore.collection('ratings').get();
      expect(ratings.docs.length, 1);
      expect(ratings.docs.first.data()['rating'], 4.5);
      expect(ratings.docs.first.data()['comment'], 'Excelente conductor');
      expect(ratings.docs.first.data()['tripId'], 'trip123');
    });

    test('getUserAverageRating debe retornar 5.0 cuando el usuario no existe', () async {
      final rating = await ratingService.getUserAverageRating('userInexistente');
      expect(rating, 5.0);
    });

    test('getUserAverageRating debe retornar el rating del usuario si existe', () async {
      await fakeFirestore.collection('users').doc('user1').set({
        'firstName': 'Juan',
        'lastName': 'Pérez',
        'rating': 4.7,
        'totalRatings': 10,
      });

      final rating = await ratingService.getUserAverageRating('user1');
      expect(rating, 4.7);
    });

    test('getUserTotalRatings debe retornar 0 cuando el usuario no tiene calificaciones', () async {
      final total = await ratingService.getUserTotalRatings('userInexistente');
      expect(total, 0);
    });

    test('getUserTotalRatings debe retornar el total correcto de calificaciones', () async {
      await fakeFirestore.collection('users').doc('user1').set({
        'firstName': 'Juan',
        'lastName': 'Pérez',
        'rating': 4.5,
        'totalRatings': 25,
      });

      final total = await ratingService.getUserTotalRatings('user1');
      expect(total, 25);
    });

    test('canRateUser debe retornar true cuando no existe calificación previa', () async {
      final canRate = await ratingService.canRateUser(
        tripId: 'trip123',
        raterUserId: 'user1',
        ratedUserId: 'user2',
      );
      expect(canRate, true);
    });

    test('canRateUser debe retornar false cuando ya existe una calificación', () async {
      await fakeFirestore.collection('ratings').add({
        'tripId': 'trip123',
        'raterUserId': 'user1',
        'ratedUserId': 'user2',
        'rating': 5.0,
        'comment': 'Muy bien',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final canRate = await ratingService.canRateUser(
        tripId: 'trip123',
        raterUserId: 'user1',
        ratedUserId: 'user2',
      );
      expect(canRate, false);
    });
  });

// Test de nuevo examen 3ra unidad
group('Validators Tests - Examen CI/CD', () {
  test('1. Validar Email Institucional UPT', () {
    // Casos válidos
    expect(Validators.isValidInstitutionalEmail('alumno@virtual.upt.pe'), true);
    expect(Validators.isValidInstitutionalEmail('juan.perez@virtual.upt.pe'), true);
    expect(Validators.isValidInstitutionalEmail('test123@virtual.upt.pe'), true);
    
    // Casos inválidos
    expect(Validators.isValidInstitutionalEmail('alumno@gmail.com'), false);
    expect(Validators.isValidInstitutionalEmail('alumno@upt.pe'), false);
    expect(Validators.isValidInstitutionalEmail('alumno@virtual.upt.edu.pe'), false);
    expect(Validators.isValidInstitutionalEmail(''), false);
    expect(Validators.isValidInstitutionalEmail('sin_arroba.com'), false);
  });

  test('2. Validar Contraseña Segura (mínimo 6 caracteres)', () {
    // Casos válidos
    expect(Validators.isSecurePassword('123456'), true);
    expect(Validators.isSecurePassword('password'), true);
    expect(Validators.isSecurePassword('MiClave2024'), true);
    expect(Validators.isSecurePassword('abc123'), true);
    
    // Casos inválidos
    expect(Validators.isSecurePassword('12345'), false);
    expect(Validators.isSecurePassword('abc'), false);
    expect(Validators.isSecurePassword(''), false);
    expect(Validators.isSecurePassword('a'), false);
  });

  test('3. Validar DNI Peruano (8 dígitos)', () {
    // Casos válidos
    expect(Validators.isValidDNI('12345678'), true);
    expect(Validators.isValidDNI('87654321'), true);
    expect(Validators.isValidDNI('00000001'), true);
    expect(Validators.isValidDNI(' 12345678 '), true); // Con espacios
    
    // Casos inválidos
    expect(Validators.isValidDNI('1234567'), false); // 7 dígitos
    expect(Validators.isValidDNI('123456789'), false); // 9 dígitos
    expect(Validators.isValidDNI('1234567a'), false); // Contiene letra
    expect(Validators.isValidDNI(''), false);
    expect(Validators.isValidDNI('abcdefgh'), false);
  });

  test('4. Validar Teléfono Peruano (9 dígitos, inicia con 9)', () {
    // Casos válidos
    expect(Validators.isValidPeruvianPhone('987654321'), true);
    expect(Validators.isValidPeruvianPhone('912345678'), true);
    expect(Validators.isValidPeruvianPhone('999999999'), true);
    expect(Validators.isValidPeruvianPhone('987 654 321'), true); // Con espacios
    expect(Validators.isValidPeruvianPhone('987-654-321'), true); // Con guiones
    
    // Casos inválidos
    expect(Validators.isValidPeruvianPhone('87654321'), false); // 8 dígitos
    expect(Validators.isValidPeruvianPhone('1987654321'), false); // 10 dígitos
    expect(Validators.isValidPeruvianPhone('887654321'), false); // No inicia con 9
    expect(Validators.isValidPeruvianPhone(''), false);
    expect(Validators.isValidPeruvianPhone('12345678'), false);
  });

  test('5. Validar Placa Vehicular Peruana (formato ABC-123 o ABC-1234)', () {
    // Casos válidos - Formato antiguo (ABC-123)
    expect(Validators.isValidLicensePlate('ABC-123'), true);
    expect(Validators.isValidLicensePlate('XYZ-999'), true);
    expect(Validators.isValidLicensePlate('abc-123'), true); // Minúsculas (se convierte)
    
    // Casos válidos - Formato nuevo (ABC-1234)
    expect(Validators.isValidLicensePlate('ABC-1234'), true);
    expect(Validators.isValidLicensePlate('XYZ-9999'), true);
    expect(Validators.isValidLicensePlate(' ABC-1234 '), true); // Con espacios
    
    // Casos inválidos
    expect(Validators.isValidLicensePlate('AB-123'), false); // 2 letras
    expect(Validators.isValidLicensePlate('ABCD-123'), false); // 4 letras
    expect(Validators.isValidLicensePlate('ABC-12'), false); // 2 números
    expect(Validators.isValidLicensePlate('ABC-12345'), false); // 5 números
    expect(Validators.isValidLicensePlate('ABC123'), false); // Sin guion
    expect(Validators.isValidLicensePlate('123-ABC'), false); // Orden invertido
    expect(Validators.isValidLicensePlate(''), false);
  });
});






}