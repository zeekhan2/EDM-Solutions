import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../controllers/clock_shift_controller.dart';
import '../../../models/shift_models.dart';

class ClockInOutView extends StatelessWidget {
  final Shift shift;

  const ClockInOutView({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClockShiftController(shift));
    // final Rx<GoogleMapController?> mapCtrl =
    //     Rx<GoogleMapController?>(null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Clock In / Out',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        final permissionGranted = controller.locationGranted.value;
        final lat = controller.currentLat.value;
        final lng = controller.currentLng.value;
        final bool hasLocation = lat != 0.0 && lng != 0.0;

        // =====================================================
        // ❌ LOCATION PERMISSION NOT GRANTED
        // =====================================================
        if (!permissionGranted) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off, size: 52, color: Colors.red),
                  const SizedBox(height: 14),
                  const Text(
                    'Location permission is required to clock in.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      LocationPermission permission =
                          await Geolocator.checkPermission();

                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                      }

                      if (permission == LocationPermission.whileInUse ||
                          permission == LocationPermission.always) {
                        controller.onInit();
                      } else if (permission ==
                          LocationPermission.deniedForever) {
                        await Geolocator.openAppSettings();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Allow Location',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // =====================================================
        // ⏳ LOCATION LOADING
        // =====================================================
        if (!hasLocation) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final LatLng userLatLng = LatLng(lat, lng);

        // Move camera smoothly
        // if (mapCtrl.value != null) {
        //   mapCtrl.value!.animateCamera(
        //     CameraUpdate.newLatLng(userLatLng),
        //   );
        // }

        // =====================================================
        // ✅ MAIN UI
        // =====================================================
        return Column(
          children: [
            const SizedBox(height: 24),

            const Text(
              'Current Shift Timer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            /// 🔥 PERSISTENT TIMER (SURVIVES KILL / RESTART)
            Text(
              controller.timerText.value,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Shift Starts At ${shift.startTime}',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            /// 🟡 GEOFENCE STATUS (INFO ONLY)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Geofence is temporarily disabled. Location is still being recorded.',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🗺 MAP (VISUAL ONLY)
            Container(
              height: 160,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: userLatLng,
                    zoom: 16,
                  ),
                  onMapCreated: (c) {
                    controller.mapController.value = c;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  markers: {
                    Marker(
                      markerId: const MarkerId('me'),
                      position: userLatLng,
                    ),
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Live location active',
                style: TextStyle(color: Colors.green),
              ),
            ),

            const Spacer(),

            /// ================= CLOCK ACTIONS =================
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          controller.canClockIn ? controller.clockIn : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Clock in',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          controller.canClockOut ? controller.clockOut : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Clock out',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
