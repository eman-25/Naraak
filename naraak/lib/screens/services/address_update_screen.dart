import 'package:flutter/material.dart';
import '../../widgets/external_api_service_view.dart';

class AddressUpdateScreen extends StatelessWidget {
  const AddressUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Update Residential Address')),
        body: const ExternalApiServiceView(
            title: 'Update Residential Address', icon: Icons.home),
      );
}
