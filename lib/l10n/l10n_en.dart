// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Awqaf Management System';

  @override
  String get systemDescription =>
      'System for managing and registering Waqf properties';

  @override
  String get registerNewProperty => 'Register New Property';

  @override
  String get viewProperties => 'View Properties';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get featureInDevelopment =>
      'This feature is currently under development';

  @override
  String get systemInfo => 'System Information';

  @override
  String get ministry => 'Ministry of Awqaf and Islamic Affairs';

  @override
  String get rights => 'All rights reserved';

  @override
  String get propertyRegistration => 'Property Registration';

  @override
  String get step1 => 'Step 1';

  @override
  String get step2 => 'Step 2';

  @override
  String get step3 => 'Step 3';

  @override
  String get step4 => 'Step 4';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get save => 'Save';

  @override
  String get propertyType => 'Property Type';

  @override
  String get selectPropertyType => 'Select the type of property';

  @override
  String get pleaseSelectPropertyType => 'Please select a property type';

  @override
  String get location => 'Location';

  @override
  String get governorate => 'Governorate';

  @override
  String get pleaseSelectGovernorate => 'Please select a governorate';

  @override
  String get sequenceNumber => 'Sequence Number';

  @override
  String get sequenceValidation => 'Must be between 1 and 999';

  @override
  String get pleaseEnterSequence => 'Please enter sequence number';

  @override
  String get pleaseEnterLocation => 'Please enter location details';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get longitude => 'Longitude';

  @override
  String get latitude => 'Latitude';

  @override
  String get propertyDetails => 'Property Details';

  @override
  String get propertyName => 'Property Name';

  @override
  String get pleaseEnterPropertyName => 'Please enter property name';

  @override
  String get area => 'Area';

  @override
  String get registrationDate => 'Registration Date';

  @override
  String get selectDate => 'Select Date';

  @override
  String get deedNumber => 'Deed Number';

  @override
  String get description => 'Description';

  @override
  String get notes => 'Notes';

  @override
  String get nationalId => 'National ID';

  @override
  String get registrationDetails => 'Registration Details';

  @override
  String successMessage(Object nationalId) {
    return 'Property registered successfully with National ID: $nationalId';
  }

  @override
  String errorMessage(Object error) {
    return 'Error: $error';
  }
}
