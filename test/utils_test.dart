import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:papercups_flutter/models/models.dart';
import 'package:http/http.dart' as http;

import 'package:papercups_flutter/utils/updateUserMetadata.dart';

import 'mocks.dart';

void main() {
  final customer = PapercupsCustomer(
    id: 'id',
    createdAt: DateTime.tryParse('2020-12-31T22:19:52.644532'),
    email: 'email@papercups.com',
    externalId: 'external_id',
    firstSeen: DateTime.tryParse('2021-01-08T22:19:52.644532'),
    lastSeen: DateTime.tryParse('2021-01-08T22:19:52.644532'),
    updatedAt: DateTime.tryParse('2021-01-08T22:19:52.644532'),
    name: 'name',
    phone: 'phone',
  );
  final props = Props(
    accountId: 'account_id',
    customer: CustomerMetadata(externalId: 'external_id'),
  );
  group('updateUserMetadata', () {
    test('returns a customer object on success', () async {
      final client = MockClient();
      final res = jsonEncode({
        "data": {
          "id": customer.id,
          "customer_id": customer.id,
          "email": customer.email,
          "external_id": customer.externalId,
          "created_at": customer.createdAt.toIso8601String(),
          "first_seen": customer.firstSeen.toIso8601String(),
          "last_seen": customer.lastSeen.toIso8601String(),
          "updated_at": customer.updatedAt.toIso8601String(),
          "name": customer.name,
          "phone": customer.phone,
        }
      });

      when(
        client.put(
          Uri.https(props.baseUrl, "/api/customers/${customer.id}/metadata"),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(res, 200));

      final PapercupsCustomer c =
          await updateUserMetadata(props, customer.id, client: client);

      verify(
        client.put(
          Uri.https(props.baseUrl, "/api/customers/${customer.id}/metadata"),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).called(1);
      verify(client.close()).called(1);

      expect(c, isNot(null));
      expect(c.id, equals(customer.id));
    });

    test("returns null when there's an error", () async {
      final client = MockClient();
      when(
        client.put(
          Uri.https(props.baseUrl, "/api/customers/${customer.id}/metadata"),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenThrow(HttpException('Request failed'));

      final PapercupsCustomer c =
          await updateUserMetadata(props, customer.id, client: client);

      verify(
        client.put(
          Uri.https(props.baseUrl, "/api/customers/${customer.id}/metadata"),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).called(1);

      verify(client.close()).called(1);
      expect(c, equals(null));
    });
  });
}
