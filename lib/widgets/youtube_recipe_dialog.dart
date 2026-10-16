import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/recipe_extractor_service.dart';

class YoutubeRecipeDialog extends StatefulWidget {
  final String? initialUrl;

  const YoutubeRecipeDialog({super.key, this.initialUrl});

  @override
  State<YoutubeRecipeDialog> createState() => _YoutubeRecipeDialogState();
}

class _YoutubeRecipeDialogState extends State<YoutubeRecipeDialog> {
  static const Color primaryBlue = Color(0xFF1E439B);

  late final TextEditingController _controller;
  bool _isLoading = false;
  RecipeExtractionResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl ?? '');
    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processInput(widget.initialUrl);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _processInput([String? customUrl]) async {
    final text = customUrl ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (customUrl != null) {
      _controller.text = customUrl;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    final data = await RecipeExtractorService.extractFromInput(text);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data != null) {
          _result = data;
        } else {
          _error = 'Could not extract recipe from this link. Check the link or tap a demo preset.';
        }
      });
    }
  }

  void _pasteFromClipboard() async {
    final clip = await Clipboard.getData(Clipboard.kTextPlain);
    if (clip?.text != null && clip!.text!.isNotEmpty) {
      _controller.text = clip.text!;
      _processInput(clip.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        width: 650,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.video_library_rounded, color: Colors.redAccent, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Cook with YouTube Recipe',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Beamed from mobile or entered directly. IntelliCart AI maps ingredients to supermarket aisles.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Input Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _processInput(),
                      decoration: InputDecoration(
                        hintText: 'Paste YouTube URL (e.g. https://youtu.be/...)',
                        prefixIcon: const Icon(Icons.link, color: primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Paste from Clipboard',
                    onPressed: _pasteFromClipboard,
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.content_paste, color: primaryBlue, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : () => _processInput(),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Extract', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Quick Try Demo Chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Demo Presets:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ActionChip(
                    label: const Text('Maggi Goreng'),
                    avatar: const Icon(Icons.ramen_dining, size: 16),
                    onPressed: () => _processInput('https://www.youtube.com/watch?v=kXx31fW2u9E'),
                  ),
                  ActionChip(
                    label: const Text('Ayam Masak Merah'),
                    avatar: const Icon(Icons.lunch_dining, size: 16),
                    onPressed: () => _processInput('https://www.youtube.com/watch?v=n5l7kG4V7vE'),
                  ),
                  ActionChip(
                    label: const Text('Yeo’s Drink Mocktail'),
                    avatar: const Icon(Icons.local_cafe, size: 16),
                    onPressed: () => _processInput('https://www.youtube.com/watch?v=J7_b8WJvPz0'),
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],

              // Results Section
              if (_result != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Video Card Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _result!.thumbnailUrl,
                          width: 80,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 50,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.movie_outlined, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _result!.dishName,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primaryBlue),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'By ${_result!.channelTitle}',
                              style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Supermarket Shopping Checklist:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 8),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _result!.ingredients.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _result!.ingredients[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 13,
                          backgroundColor: primaryBlue.withValues(alpha: 0.1),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(item.quantity, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                item.aisleLocation,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}