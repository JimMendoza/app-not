import 'package:app_not/features/home/presentation/helpers/module_route_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_fakes.dart';

void main() {
  group('HomeModuleRouteResolver', () {
    test('usa ids canonicos para resolver tramites y notificaciones', () {
      final tramiteModule = buildModule(
        id: 'mesa_partes_virtual',
        nombre: 'Mesa de Partes Virtual',
        icono: 'description',
      );
      final notificacionesModule = buildModule(
        id: 'notificaciones',
        nombre: 'Notificaciones',
        icono: 'notifications',
      );

      expect(
        HomeModuleRouteResolver.resolveTarget(tramiteModule),
        HomeModuleTarget.tramites,
      );
      expect(HomeModuleRouteResolver.buildRoute(tramiteModule), '/tramites');
      expect(
        HomeModuleRouteResolver.resolveTarget(notificacionesModule),
        HomeModuleTarget.notificaciones,
      );
      expect(
        HomeModuleRouteResolver.buildRoute(notificacionesModule),
        '/notificaciones',
      );
    });

    test('mantiene fallback acotado por nombre exacto cuando el id no es canonico', () {
      final module = buildModule(
        id: 'modulo_interno',
        nombre: 'Mesa de Partes Virtual',
        icono: 'apps',
      );

      expect(
        HomeModuleRouteResolver.resolveTarget(module),
        HomeModuleTarget.tramites,
      );
      expect(HomeModuleRouteResolver.buildRoute(module), '/tramites');
    });

    test('envia modulos no reconocidos al placeholder y usa icono seguro', () {
      final module = buildModule(
        id: 'reportes_internos',
        nombre: 'Reportes internos',
        icono: 'unknown_icon',
      );

      expect(
        HomeModuleRouteResolver.resolveTarget(module),
        HomeModuleTarget.other,
      );
      expect(
        HomeModuleRouteResolver.buildRoute(module),
        '/modulo/reportes_internos?nombre=Reportes%20internos',
      );
      expect(HomeModuleRouteResolver.resolveIcon(module), Icons.apps);
    });
  });
}
