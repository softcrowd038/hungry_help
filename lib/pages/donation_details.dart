import 'package:flutter/material.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/services/get_donor_details.dart';

class DonationDetails extends StatefulWidget {
  const DonationDetails({super.key});

  @override
  State<DonationDetails> createState() => _DonationDetailsState();
}

class _DonationDetailsState extends State<DonationDetails> {
  List<dynamic> data = [];
  final DonorInfo _service = DonorInfo();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final closestData = await _service.getDonorDetails();
      setState(() {
        data = [closestData];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
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
        backgroundColor: Colors.white,
        title: const Text('Donation Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.isNotEmpty
              ? ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (item['imageurl'] != null)
                              Image.network(
                                '$imageBaseUrl${item['imageurl']}',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  if (item['description'] != null)
                                    Text(
                                      item['description'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  if (item['donation_date'] != null &&
                                      item['donation_time'] != null)
                                    Text(
                                      'Donated on ${item['donation_date']} at ${item['donation_time']}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  const SizedBox(height: 8),
                                  if (item['quantity'] != null)
                                    Text(
                                      'Quantity: ${item['quantity']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    'No donation history found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
    );
  }
}
