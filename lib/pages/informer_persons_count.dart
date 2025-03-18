import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/pages/informer_camera_review.dart';
import 'package:quick_social/provider/informer_data_provider.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:quick_social/widgets/layout/text_field.dart';

class InformerPersonsCount extends StatefulWidget {
  const InformerPersonsCount({super.key});

  @override
  State<InformerPersonsCount> createState() => _InformerPersonsCount();
}

class _InformerPersonsCount extends State<InformerPersonsCount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _quantityEditingController =
      TextEditingController();
  final TextEditingController _expirytimeEditingController =
      TextEditingController();
  final TextEditingController _expiryDateEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final informerDataProvider = Provider.of<InformerDataProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 420.0,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 400,
                        child: Image.asset(
                          'assets/images/informer.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 22,
                          ),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Add Needy People Details',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Add People Starving for food',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                          setState(() {
                            _expiryDateEditingController.text = formattedDate;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFieldWidget(
                          controller: _expiryDateEditingController,
                          hintText: 'Capture Date',
                          prefixIcon: const Icon(Icons.date_range),
                          keyboardType: TextInputType.datetime,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );

                        if (pickedTime != null) {
                          setState(() {
                            // Displaying time in 24-hour format like HH:mm
                            _expirytimeEditingController.text =
                                "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                          });
                        } else {
                          // If no time is picked, show the current time in 24-hour format
                          TimeOfDay currentTime = TimeOfDay.now();
                          _expirytimeEditingController.text =
                              "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}";
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFieldWidget(
                          controller: _expirytimeEditingController,
                          hintText: 'Current Time',
                          prefixIcon: const Icon(Icons.watch),
                          keyboardType: TextInputType.datetime,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a Current time';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    TextFieldWidget(
                      controller: _quantityEditingController,
                      hintText: 'Food Amount or People Count',
                      prefixIcon: const Icon(Icons.food_bank),
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid number';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          informerDataProvider.setDonationDate(
                              _expiryDateEditingController.text);
                          informerDataProvider.setDonationTime(
                              _expirytimeEditingController.text);
                          informerDataProvider
                              .setQuantity(_quantityEditingController.text);

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const InformerCameraReviewPage()));
                        }
                      },
                      child: const ButtonWidget(
                        borderRadius: 0.06,
                        height: 0.06,
                        width: 1,
                        text: 'Add Location',
                        textFontSize: 0.022,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
