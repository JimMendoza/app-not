import 'package:app_not/features/home/domain/domain.dart';
import 'package:flutter/material.dart';

enum HomeModuleTarget { tramites, notificaciones, other }

class HomeModuleRouteResolver {
  const HomeModuleRouteResolver._();

  static const Set<String> _tramitesIds = <String>{
    'tramites',
    'mesa_partes',
    'mesa_partes_virtual',
  };

  static const Set<String> _tramitesNames = <String>{
    'tramites',
    'mesa_partes_virtual',
    'mesa_de_partes_virtual',
  };

  static const Set<String> _notificacionesIds = <String>{'notificaciones'};
  static const Set<String> _notificacionesNames = <String>{'notificaciones'};

  static const Map<String, IconData> _iconByName = <String, IconData>{
    'description': Icons.description,
    'notifications': Icons.notifications,
    'notification': Icons.notifications,
    'list_alt': Icons.list_alt,
    'assignment': Icons.assignment,
    'receipt_long': Icons.receipt_long,
    'timeline': Icons.timeline,
    'folder': Icons.folder,
    'dashboard': Icons.dashboard,
    'home': Icons.home,
  };

  static HomeModuleTarget resolveTarget(Module module) {
    final String normalizedId = _normalize(module.id);
    if (_tramitesIds.contains(normalizedId)) {
      return HomeModuleTarget.tramites;
    }

    if (_notificacionesIds.contains(normalizedId)) {
      return HomeModuleTarget.notificaciones;
    }

    final String normalizedName = _normalize(module.nombre);
    if (_tramitesNames.contains(normalizedName)) {
      return HomeModuleTarget.tramites;
    }

    if (_notificacionesNames.contains(normalizedName)) {
      return HomeModuleTarget.notificaciones;
    }

    return HomeModuleTarget.other;
  }

  static String buildRoute(Module module) {
    switch (resolveTarget(module)) {
      case HomeModuleTarget.tramites:
        return '/tramites';
      case HomeModuleTarget.notificaciones:
        return '/notificaciones';
      case HomeModuleTarget.other:
        final String moduleId = stableKey(module);
        final String encodedModuleId = Uri.encodeComponent(moduleId);
        final String encodedModuleName = Uri.encodeComponent(module.nombre);
        return '/modulo/$encodedModuleId?nombre=$encodedModuleName';
    }
  }

  static String stableKey(Module module) {
    final String normalizedId = _normalize(module.id);
    if (normalizedId.isNotEmpty) {
      return normalizedId;
    }

    final String normalizedName = _normalize(module.nombre);
    if (normalizedName.isNotEmpty) {
      return normalizedName;
    }

    return 'modulo';
  }

  static IconData resolveIcon(Module module) {
    switch (resolveTarget(module)) {
      case HomeModuleTarget.tramites:
        return Icons.description;
      case HomeModuleTarget.notificaciones:
        return Icons.notifications;
      case HomeModuleTarget.other:
        final String normalizedIcon = _normalize(module.icono);
        return _iconByName[normalizedIcon] ?? Icons.apps;
    }
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
