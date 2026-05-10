import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/checkout/providers/checkout_provider.dart';

class BillingDetailsSection extends StatelessWidget {
  final int ticketQuantity;

  const BillingDetailsSection({
    super.key,
    required this.ticketQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Billing Details Section
          _buildBillingDetails(),

          const SizedBox(height: 32),
          const Divider(thickness: 1.5),
          const SizedBox(height: 24),

          // Ticket Information Section
          _buildTicketInformation(),
        ],
      ),
    );
  }

  Widget _buildBillingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Billing Details', style: AppTextStyles.headingMedium),
        const SizedBox(height: 8),
        Consumer2<AuthProvider, CheckoutProvider>(
          builder: (context, auth, vm, _) {
            final u = auth.customerModel;
            final loggedIn = (auth.token ?? '').isNotEmpty && u != null;
            if (loggedIn) {
              return Column(
                children: [
                  _InputRow(
                    children: [
                      _ReadOnlyField(label: 'First Name', value: u.fname ?? ''),
                      _ReadOnlyField(label: 'Last Name', value: u.lname ?? ''),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _ReadOnlyField(label: 'Email', value: u.email ?? ''),
                  const SizedBox(height: 4),
                  _ReadOnlyField(label: 'Phone', value: u.phone ?? ''),
                  const SizedBox(height: 4),
                  const SizedBox(height: 4),
                  _ReadOnlyField(
                    label: 'Address',
                    value: u.address ?? '',
                    lines: 3,
                  ),
                ],
              );
            }

            // Guest checkout: editable fields bound to CheckoutViewModel
            String gv(String k) => vm.getRawField(k);
            return Column(
              children: [
                _InputRow(
                  children: [
                    _EditableField(
                      label: 'First Name',
                      initialValue: gv('fname'),
                      onChanged: (v) => vm.setRawField('fname', v),
                    ),
                    _EditableField(
                      label: 'Last Name',
                      initialValue: gv('lname'),
                      onChanged: (v) => vm.setRawField('lname', v),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _EditableField(
                  label: 'Email',
                  initialValue: gv('email'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) => vm.setRawField('email', v),
                ),
                const SizedBox(height: 4),
                _EditableField(
                  label: 'Phone',
                  initialValue: gv('phone'),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => vm.setRawField('phone', v),
                ),
                const SizedBox(height: 4),
                const SizedBox(height: 4),
                _EditableField(
                  label: 'Address',
                  initialValue: gv('address'),
                  lines: 3,
                  onChanged: (v) => vm.setRawField('address', v),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTicketInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ticket Information', style: AppTextStyles.headingMedium),
        const SizedBox(height: 16),
        Consumer2<AuthProvider, CheckoutProvider>(
          builder: (context, auth, vm, _) {
            return Column(
              children: List.generate(
                ticketQuantity,
                    (index) => _TicketCard(
                  ticketNumber: index + 1,
                  isFirstTicket: index == 0,
                  auth: auth,
                  vm: vm,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ==================== TICKET CARD ====================
class _TicketCard extends StatefulWidget {
  final int ticketNumber;
  final bool isFirstTicket;
  final AuthProvider auth;
  final CheckoutProvider vm;

  const _TicketCard({
    required this.ticketNumber,
    required this.isFirstTicket,
    required this.auth,
    required this.vm,
  });

  @override
  State<_TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<_TicketCard> {
  bool _isForMe = false;
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _nationality = '';
  String _address = '';
  String? _gender;
  DateTime? _dob;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-check first ticket if user is logged in
    if (widget.isFirstTicket && widget.auth.customerModel != null) {
      _isForMe = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillUserData();
      });
    }

    // Initialize ticket data in provider
    _initializeTicketData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalityController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _initializeTicketData() {
    final ticketKey = 'ticket_${widget.ticketNumber}';
    widget.vm.setTicketField(ticketKey, 'is_me', _isForMe ? '1' : '0');
  }

  void _fillUserData() {
    final user = widget.auth.customerModel;
    if (user == null) return;

    setState(() {
      _fullName = '${user.fname ?? ''} ${user.lname ?? ''}'.trim();
      _email = user.email ?? '';
      _phone = user.phone ?? '';
      _nationality = user.country ?? '';

      // If you have gender and DOB in your user model, uncomment:
      // _gender = user.gender;
      // if (user.dob != null) {
      //   _dob = DateTime.parse(user.dob!);
      //   _dobController.text = '${_dob!.day}/${_dob!.month}/${_dob!.year}';
      // }

      _nameController.text = _fullName;
      _emailController.text = _email;
      _phoneController.text = _phone;
      _nationalityController.text = _nationality;

      // Update provider
      _updateTicketData();
    });
  }

  void _clearUserData() {
    setState(() {
      _fullName = '';
      _email = '';
      _phone = '';
      _nationality = '';
      _gender = null;
      _dob = null;

      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _nationalityController.clear();
      _dobController.clear();

      // Update provider
      _updateTicketData();
    });
  }

  void _updateTicketData() {
    final ticketKey = 'ticket_${widget.ticketNumber}';
    widget.vm.setTicketField(ticketKey, 'is_me', _isForMe ? '1' : '0');
    widget.vm.setTicketField(ticketKey, 'full_name', _fullName);
    widget.vm.setTicketField(ticketKey, 'email', _email);
    widget.vm.setTicketField(ticketKey, 'phone', _phone);
    widget.vm.setTicketField(ticketKey, 'nationality', _nationality);
    widget.vm.setTicketField(ticketKey, 'address', _address);
    widget.vm.setTicketField(ticketKey, 'gender', _gender ?? '');
    widget.vm.setTicketField(
      ticketKey,
      'dob',
      _dob != null ? _dob!.toIso8601String().split('T')[0] : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = widget.auth.customerModel != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with ticket number and toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TICKET ${widget.ticketNumber}',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoggedIn)
                  Row(
                    children: [
                      Text(
                        'Is ticket for me?',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _isForMe,
                        onChanged: (value) {
                          setState(() {
                            _isForMe = value;
                            if (value) {
                              _fillUserData();
                            } else {
                              _clearUserData();
                            }
                          });
                        },
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Full Name
            _buildTextField(
              label: 'Full Name',
              controller: _nameController,
              readOnly: _isForMe && isLoggedIn,
              onChanged: (value) {
                _fullName = value;
                _updateTicketData();
              },
            ),
            const SizedBox(height: 12),

            // Gender
            _buildGenderField(),
            const SizedBox(height: 12),

            // Email and Phone Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    readOnly: _isForMe && isLoggedIn,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      _email = value;
                      _updateTicketData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Phone',
                    controller: _phoneController,
                    readOnly: _isForMe && isLoggedIn,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      _phone = value;
                      _updateTicketData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // DOB
            _buildDateField(),
            const SizedBox(height: 12),

                          // Nationality
              _buildTextField(
                label: 'Nationality',
                controller: _nationalityController,
                readOnly: _isForMe && isLoggedIn,
                onChanged: (value) {
                  _nationality = value;
                  _updateTicketData();
                },
              ),
              const SizedBox(height: 12),
              // Address
              _buildTextField(
                label: 'Address',
                controller: _addressController,
                onChanged: (value) {
                  _address = value;
                  _updateTicketData();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *', style: AppTextStyles.bodySmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(
            color: readOnly ? Colors.grey[600] : Colors.black,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[200] : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: readOnly ? Colors.grey[300]! : Colors.grey[400]!,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    final isLoggedIn = widget.auth.customerModel != null;
    final isDisabled = _isForMe && isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender *', style: AppTextStyles.bodySmall),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Male'),
                value: 'Male',
                groupValue: _gender,
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: isDisabled
                    ? null
                    : (value) {
                  setState(() {
                    _gender = value;
                    _updateTicketData();
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Female'),
                value: 'Female',
                groupValue: _gender,
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: isDisabled
                    ? null
                    : (value) {
                  setState(() {
                    _gender = value;
                    _updateTicketData();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField() {
    final isLoggedIn = widget.auth.customerModel != null;
    final isDisabled = _isForMe && isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DOB *', style: AppTextStyles.bodySmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _dobController,
          readOnly: true,
          style: TextStyle(
            color: isDisabled ? Colors.grey[600] : Colors.black,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: isDisabled,
            fillColor: isDisabled ? Colors.grey[200] : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: Icon(
              Icons.calendar_today,
              size: 20,
              color: isDisabled ? Colors.grey[400] : null,
            ),
          ),
          onTap: isDisabled
              ? null
              : () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dob ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _dob = picked;
                _dobController.text =
                '${picked.day}/${picked.month}/${picked.year}';
                _updateTicketData();
              });
            }
          },
          validator: (value) {
            if (_dob == null) {
              return 'DOB is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ==================== HELPER WIDGETS ====================
class _InputRow extends StatelessWidget {
  final List<Widget> children;
  const _InputRow({required this.children});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .map(
            (e) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: e,
          ),
        ),
      )
          .toList(),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final int lines;
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.lines = 1,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 6),
        TextFormField(
          readOnly: true,
          initialValue: value,
          maxLines: lines,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final String initialValue;
  final int lines;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  const _EditableField({
    required this.label,
    required this.initialValue,
    this.lines = 1,
    this.keyboardType,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          maxLines: lines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
