import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('EcoUrbano inicia corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoUrbanoApp());

    expect(find.text('EcoUrbano'), findsOneWidget);
    expect(find.text('Olá! Bem-vindo ao EcoUrbano.'), findsOneWidget);
  });
}