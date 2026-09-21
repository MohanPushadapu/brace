import 'models.dart';

class AppDatabase {
  Future<void> initialize() async {
    throw UnimplementedError('Database initialization will be implemented with the persistence choice.');
  }

  Future<List<SessionRecord>> getSessions() async {
    throw UnimplementedError('Session persistence is not implemented yet.');
  }

  Future<List<SensorReading>> getReadings(String sessionId) async {
    throw UnimplementedError('Sensor reading persistence is not implemented yet.');
  }
}
