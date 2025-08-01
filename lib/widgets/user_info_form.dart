import 'package:flutter/material.dart';
import 'package:alfalite_configurator/services/user_data.dart';

class UserInfoForm extends StatefulWidget {
  final String title;
  final Function(UserData) onSubmit;

  const UserInfoForm({super.key, required this.title, required this.onSubmit});

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _projectNameController = TextEditingController();
  String _assemblyValue = 'Stacked';
  String _applicationValue = 'Rental';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Text(widget.title, style: const TextStyle(color: Color(0xFFFC7100))),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextFormField(label: 'First Name', controller: _firstNameController),
              _buildTextFormField(label: 'Last Name', controller: _lastNameController),
              _buildTextFormField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
              _buildTextFormField(label: 'Address', controller: _addressController),
              _buildTextFormField(label: 'City', controller: _cityController),
              _buildTextFormField(label: 'Country', controller: _countryController),
              _buildTextFormField(label: 'Company', controller: _companyController),
              _buildTextFormField(label: 'Phone', controller: _phoneController, keyboardType: TextInputType.phone),
              _buildTextFormField(label: 'Project name', controller: _projectNameController),
              _buildDialogDropdown('Assembly', _assemblyValue, ['Stacked', 'Floor', 'Hanged'], (val) => setState(() => _assemblyValue = val!)),
              _buildDialogDropdown('Application', _applicationValue, ['Rental', 'Broadcast', 'Film & Series', 'Advertising', 'Entertainment', 'Corporate', 'Sports', 'Transport', 'Retail'], (val) => setState(() => _applicationValue = val!)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: const TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final userData = UserData(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                email: _emailController.text,
                address: _addressController.text,
                city: _cityController.text,
                country: _countryController.text,
                company: _companyController.text,
                phone: _phoneController.text,
                projectName: _projectNameController.text,
                assembly: _assemblyValue,
                application: _applicationValue,
              );
              widget.onSubmit(userData);
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFC7100),
            foregroundColor: Colors.black,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
          labelStyle: const TextStyle(color: Colors.orange),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDialogDropdown(
    String label,
    String currentValue,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.orange),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
        ),
        dropdownColor: const Color(0xFF1E1E1E),
      ),
    );
  }
} 