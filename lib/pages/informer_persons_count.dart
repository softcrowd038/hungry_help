import 'package:flutter/material.dart';
import 'package:quick_social/pages/informer_capture_image.dart';

class InformerPersonsCount extends StatefulWidget {
  const InformerPersonsCount({super.key});
  @override
  State<InformerPersonsCount> createState() => _InformerPersonsCount();
}

class _InformerPersonsCount extends State<InformerPersonsCount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityEditingController =
      TextEditingController(); // Moved outside of build()

  @override
  void dispose() {
    _quantityEditingController
        .dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 350.0,
                    child: Image.network(
                      'https://www.shutterstock.com/image-vector/hands-counting-by-showing-fingers-600nw-1720234543.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 22,
                              ),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => InformerCaptureImage(
                                    count: _quantityEditingController.text,
                                  ),
                                ));
                              }
                            },
                            child: Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.022,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Form(
                key: _formKey, // Updated form key
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    const Text(
                      'Inform Now',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Enter the Count of Needy people',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.020),
                    Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.0080),
                      child: TextFormField(
                        controller: _quantityEditingController,
                        decoration: const InputDecoration(
                          hintText: ' People Count',
                          prefixIcon: Icon(Icons.people),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a value';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
