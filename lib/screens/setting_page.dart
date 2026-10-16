import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onEndSession;

  const SettingsScreen({super.key, this.onEndSession});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primaryBlue = Color(0xFF1E439B);
  static const Color accentOrange = Color(0xFFD35400);

  // Shopper Preferences
  bool _budgetAlertEnabled = true;
  double _budgetLimit = 150.0;
  bool _halalFilter = true;
  bool _vegetarianFilter = false;
  bool _nutAllergyWarning = true;
  bool _lactoseAllergyWarning = false;

  // Trolley & Hardware Controls
  double _scannerVolume = 0.8;
  final bool _vibrationFeedback = true;
  bool _autoBrightness = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings, color: primaryBlue, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Cart & App Settings',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  // Trolley ID & Signal Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Trolley #04 • Online',
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Settings Content Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  // Section 1: Shopper Budget & Dietary Preferences
                  _buildSectionHeader('Shopper Preferences & Health'),
                  _buildCardContainer([
                    // Budget Alert Toggle
                    SwitchListTile(
                      activeThumbColor: accentOrange,
                      title: const Text('Budget Overrun Warning', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Alert me when cart total approaches RM${_budgetLimit.toStringAsFixed(0)}'),
                      value: _budgetAlertEnabled,
                      onChanged: (val) => setState(() => _budgetAlertEnabled = val),
                    ),
                    if (_budgetAlertEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Row(
                          children: [
                            const Text('RM 50', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Expanded(
                              child: Slider(
                                activeColor: accentOrange,
                                inactiveColor: Colors.grey.shade300,
                                min: 50.0,
                                max: 500.0,
                                divisions: 9,
                                value: _budgetLimit,
                                label: 'RM${_budgetLimit.toStringAsFixed(0)}',
                                onChanged: (val) => setState(() => _budgetLimit = val),
                              ),
                            ),
                            const Text('RM 500', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    const Divider(height: 1),
                    // Dietary Filter Chips
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dietary & Allergy Warning Flags',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilterChip('Halal Only', _halalFilter, (v) => setState(() => _halalFilter = v)),
                              _buildFilterChip('Vegetarian', _vegetarianFilter, (v) => setState(() => _vegetarianFilter = v)),
                              _buildFilterChip('Peanut Alert', _nutAllergyWarning, (v) => setState(() => _nutAllergyWarning = v)),
                              _buildFilterChip('Lactose Alert', _lactoseAllergyWarning, (v) => setState(() => _lactoseAllergyWarning = v)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Section 2: Hardware & Cart Diagnostics
                  _buildSectionHeader('Trolley Hardware & Feedback'),
                  _buildCardContainer([
                    ListTile(
                      leading: const Icon(Icons.scale, color: primaryBlue),
                      title: const Text('Tare / Zero Weight Scale', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Calibrate basket weight sensor if reading non-zero'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Basket scale re-calibrated to 0.00 kg!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text('Reset Scale'),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.volume_up, color: primaryBlue),
                          const SizedBox(width: 14),
                          const Text('Scanner Beep Volume', style: TextStyle(fontWeight: FontWeight.w700)),
                          Expanded(
                            child: Slider(
                              activeColor: primaryBlue,
                              value: _scannerVolume,
                              onChanged: (val) => setState(() => _scannerVolume = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      activeThumbColor: primaryBlue,
                      secondary: const Icon(Icons.brightness_auto, color: primaryBlue),
                      title: const Text('Auto-Brightness Sensor', style: TextStyle(fontWeight: FontWeight.w700)),
                      value: _autoBrightness,
                      onChanged: (val) => setState(() => _autoBrightness = val),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Section 3: Session Management
                  _buildSectionHeader('Session Controls'),
                  _buildCardContainer([
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text(
                        'End Shopping Session',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.redAccent),
                      ),
                      subtitle: const Text('Clear cart and return trolley to standby screen'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                      onTap: () => _confirmEndSession(context),
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, ValueChanged<bool> onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: accentOrange.withValues(alpha: 0.2),
      checkmarkColor: accentOrange,
      labelStyle: TextStyle(
        color: isSelected ? accentOrange : Colors.black87,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? accentOrange : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
    );
  }

  void _confirmEndSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Shopping Session?'),
        content: const Text(
          'This will clear your active cart items and return the screen to the home welcome page.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.onEndSession != null) {
                widget.onEndSession!();
              }
            },
            child: const Text('End Session', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}