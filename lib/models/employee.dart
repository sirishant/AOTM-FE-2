// {
//   "empId": 1,
//   "firstname": "sultan",
//   "lastname": "khan pathan",
//   "username": "dictator",
//   "designation": "ROLE_USER",
//   "nfcTagId": 1,
//   "password": "111111",
//   "workshop": {
//     "workshopId": 1,
//     "workshopName": "Workshop One"
//   },
//   "enabled": true,
//   "employeeName": "sultan khan pathan",
//   "authorities": [
//     {
//       "authority": "ROLE_USER"
//     }
//   ],
//   "accountNonExpired": true,
//   "accountNonLocked": true,
//   "credentialsNonExpired": true
// }

import 'package:aotm_fe_2/models/workshop.dart';

class Employee {
  final int empId;
  final String firstname;
  final String lastname;
  final String username;
  final String designation;
  final int nfcTagId;
  final String password;
  final Workshop workshop;
  final bool enabled;
  final String employeeName;
  final List<Authorities> authorities;
  final bool accountNonExpired;
  final bool accountNonLocked;
  final bool credentialsNonExpired;

  Employee({
    required this.empId,
    this.firstname = '',
    this.lastname = '',
    required this.username,
    this.designation = 'ROLE_USER',
    required this.nfcTagId,
    this.password = '',
    this.workshop = const Workshop.nullWorkshop(),
    this.enabled = true,
    required this.employeeName,
    this.authorities = const [],
    this.accountNonExpired = true,
    this.accountNonLocked = true,
    this.credentialsNonExpired = true,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empId: json['empId'],
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      username: json['username'] ?? '',
      designation: json['designation'] ?? 'ROLE_USER',
      nfcTagId: json['nfcTagId'] ?? 0,
      password: json['password'] ?? '',
      workshop: json['workshop'] != null ? Workshop.fromJson(json['workshop']) : Workshop.nullWorkshop(),
      enabled: json['enabled'] ?? true,
      employeeName: json['employeeName'] ?? '',
      authorities: (json['authorities'] as List?)
          ?.map((e) => Authorities.fromJson(e))
          .toList() ?? [],
      accountNonExpired: json['accountNonExpired'] ?? true,
      accountNonLocked: json['accountNonLocked'] ?? true,
      credentialsNonExpired: json['credentialsNonExpired'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'firstname': firstname,
      'lastname': lastname,
      'username': username,
      'designation': designation,
      'nfcTagId': nfcTagId,
      'password': password,
      'workshop': workshop.toJson(),
      'enabled': enabled,
      'employeeName': employeeName,
      'authorities': authorities.map((e) => e.toJson()).toList(),
      'accountNonExpired': accountNonExpired,
      'accountNonLocked': accountNonLocked,
      'credentialsNonExpired': credentialsNonExpired,
    };
  }

  @override
  String toString() {
    return 'Employee{empId: $empId, firstname: $firstname, lastname: $lastname, username: $username, designation: $designation, nfcTagId: $nfcTagId, password: $password, workshop: $workshop, enabled: $enabled, employeeName: $employeeName, authorities: $authorities, accountNonExpired: $accountNonExpired, accountNonLocked: $accountNonLocked, credentialsNonExpired: $credentialsNonExpired}';
  }
}

class Authorities {
  final String authority;

  Authorities({required this.authority});

  factory Authorities.fromJson(Map<String, dynamic> json) {
    return Authorities(
      authority: json['authority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authority': authority,
    };
  }

  @override
  String toString() {
    return 'Authorities{authority: $authority}';
  }
}