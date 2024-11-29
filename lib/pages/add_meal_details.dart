import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/pages/add_location_data.dart';
import 'package:quick_social/provider/donor_data_provider.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:quick_social/widgets/layout/text_field.dart';

class AddMealDetails extends StatefulWidget { 
  const AddMealDetails({super.key});

  @override
  State<StatefulWidget> createState() => _AddMealDetailsState();
}

class _AddMealDetailsState extends State<AddMealDetails> {
  final GlobalKey _globalKey = GlobalKey();

  final TextEditingController _quantityEditingController =
      TextEditingController();
  final TextEditingController _expirytimeEditingController =
      TextEditingController();
  final TextEditingController _expiryDateEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final donorDataProvider = Provider.of<DonorDataProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        child: Image.asset(
                          'assets/images/food.png',
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
                key: _globalKey,
                child: Column(
                  children: [
                    const Text(
                      'Add Meal',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Add remaining today\'s meal',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.0080),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (donorDataProvider.imageurl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.height * 0.01),
                              child: Image.file(
                                File(donorDataProvider.imageurl!.path),
                                width: MediaQuery.of(context).size.height * 0.1,
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.1,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.height *
                                          0.010)),
                              child: Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.height *
                                        0.0080),
                                child: Text(
                                  donorDataProvider.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          hintText: 'Expiry Date',
                          prefixIcon: const Icon(Icons.date_range),
                          keyboardType: TextInputType.datetime,
                          obscureText: false,
                          validator: (p0) {},
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _expirytimeEditingController.text =
                                pickedTime.format(context);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFieldWidget(
                          controller: _expirytimeEditingController,
                          hintText: 'Expiry Time',
                          prefixIcon: const Icon(Icons.watch),
                          keyboardType: TextInputType.datetime,
                          obscureText: false,
                          validator: (p0) {},
                        ),
                      ),
                    ),
                    TextFieldWidget(
                      controller: _quantityEditingController,
                      hintText: 'Food Amount or People Count',
                      prefixIcon: const Icon(Icons.food_bank),
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      validator: (p0) {},
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        donorDataProvider
                            .setDonationDate(_expiryDateEditingController.text);
                        donorDataProvider
                            .setDonationTime(_expirytimeEditingController.text);
                        donorDataProvider
                            .setQuantity(_quantityEditingController.text);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AddLocationData()));
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
