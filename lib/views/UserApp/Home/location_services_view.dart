import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/worker_models.dart';
import '../../../services/worker_service.dart';
import '../../../services/storage_service.dart';

class LocationServicesView extends StatefulWidget {
  const LocationServicesView({super.key});

  @override
  State<LocationServicesView> createState() =>
      _LocationServicesViewState();
}

class _LocationServicesViewState extends State<LocationServicesView> {
  List<LocationService> locations = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        Get.snackbar(
          'Error',
          'Please login again',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await WorkerService.getLocationServices(token);

      if (response.success) {
        setState(() {
          locations = response.data ?? [];
        });
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to fetch locations',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        title: const Text(
          'Location Services',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1E3A8A),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchLocations,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Available Locations Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Locations',
                            style: TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (locations.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.location_off,
                                      size: 64,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No locations available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pull down to refresh',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: locations.length,
                              itemBuilder: (context, index) {
                                final location = locations[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: LocationItem(location: location),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    // Refresh Location Button
                    if (locations.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _fetchLocations,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Refresh Locations',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class LocationItem extends StatelessWidget {
  final LocationService location;

  const LocationItem({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location name
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFF1E3A8A),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.name ?? 'Unknown Location',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (location.address != null) ...[
            const SizedBox(height: 8),
            Text(
              location.address!,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
          if (location.latitude != null && location.longitude != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.my_location,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Lat: ${location.latitude!.toStringAsFixed(4)}, Long: ${location.longitude!.toStringAsFixed(4)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
