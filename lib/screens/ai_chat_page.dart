import 'package:IntelliCart/ai/groq_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AiChatScreen extends StatefulWidget {
  final String? initialQueryProduct;

  const AiChatScreen({super.key, this.initialQueryProduct});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class _AiChatScreenState extends State<AiChatScreen> {
  static const Color primaryBlue = Color(0xFF1E439B);
  static const Color accentOrange = Color(0xFFD35400);

  // Replace this with your exact Netlify link
  static const String netlifyBeamUrl = 'https://intelli-cart.netlify.app';

  final TextEditingController _textController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQueryProduct != null && widget.initialQueryProduct!.isNotEmpty) {
      _askGroqForProduct(widget.initialQueryProduct!);
    } else {
      _messages.add(
        _ChatMessage(
          text: 'Hello! I am your IntelliCart Assistant. Scan an item or select one from the catalog to check ingredients, allergens, and Halal status.',
          isUser: false,
        ),
      );
    }
  }

  void _askGroqForProduct(String productName) async {
    setState(() {
      _messages.add(_ChatMessage(text: 'Tell me about $productName', isUser: true));
      _isLoading = true;
    });

    final aiResponse = await GroqService.getProductInsights(productName);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add(_ChatMessage(text: aiResponse, isUser: false));
      });
    }
  }

  void _handleSubmittedText() {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _textController.clear();
    _askGroqForProduct(text);
  }

  void _showQrDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.qr_code_scanner_rounded, color: primaryBlue, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Beam YouTube Recipe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Scan this QR code with your phone camera to open the beam remote. Paste any recipe link and watch it sync here!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.3),
              ),
              const SizedBox(height: 20),

              // Real QR Code Generator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: netlifyBeamUrl,
                  version: QrVersions.auto,
                  size: 210.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: primaryBlue,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Connected to Cart #cart_01',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Title and QR Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF8E24AA), size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'IntelliCart AI Assistant (Llama 3.1 8B via Groq)',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // QR Trigger Button
                  InkWell(
                    onTap: _showQrDialog,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.qr_code_2_rounded, color: primaryBlue, size: 22),
                          SizedBox(width: 6),
                          Text(
                            'Beam Recipe',
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Message History
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isUser ? accentOrange : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                          height: 1.4,
                          fontWeight: msg.isUser ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Loading Indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text('Groq is generating response...', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),

            // Text Input Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _handleSubmittedText(),
                      decoration: const InputDecoration(
                        hintText: 'Ask about any product or ingredient...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _handleSubmittedText,
                    icon: const Icon(Icons.send_rounded, color: primaryBlue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}