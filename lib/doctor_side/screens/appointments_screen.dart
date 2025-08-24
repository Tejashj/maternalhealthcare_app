import 'package:flutter/material.dart';
import 'package:maternalhealthcare/doctor_side/provider/doctor_provider.dart';
import 'package:maternalhealthcare/doctor_side/widgets/appointment_card.dart';
import 'package:provider/provider.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorData = Provider.of<DoctorDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                doctorData.isLoadingAppointments
                    ? const Center(child: CircularProgressIndicator())
                    : doctorData.appointments.isEmpty
                    ? const Center(child: Text('No appointments scheduled.'))
                    : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: doctorData.appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = doctorData.appointments[index];
                        return AppointmentCard(
                          patientName: appointment.patientName,
                          date: appointment.date,
                          time: appointment.time,
                          onTap: () {},
                        );
                      },
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                    ),
          ),
          if (doctorData.appointments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton(
                onPressed: () => doctorData.cancelAllAppointments(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade700),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel all appointments',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
