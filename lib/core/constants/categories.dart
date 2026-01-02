import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryModel({required this.name, required this.icon, required this.color});
}

const List<CategoryModel> appCategories = [
  CategoryModel(name: 'Alimentação', icon: Icons.restaurant, color: Colors.orange),
  CategoryModel(name: 'Transporte', icon: Icons.directions_car, color: Colors.blue),
  CategoryModel(name: 'Moradia', icon: Icons.home, color: Colors.purple),
  CategoryModel(name: 'Lazer', icon: Icons.celebration, color: Colors.pink),
  CategoryModel(name: 'Saúde', icon: Icons.medical_services, color: Colors.red),
  CategoryModel(name: 'Educação', icon: Icons.school, color: Colors.indigo),
  CategoryModel(name: 'Salário', icon: Icons.payments, color: Colors.green),
  CategoryModel(name: 'Outros', icon: Icons.category, color: Colors.grey),
];