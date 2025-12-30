import 'package:flutter/material.dart';
import 'package:waqf/data/models/homepage_section.dart';

class SlideFormDialog extends StatefulWidget {
  final HeroSlide? slide;
  final Function(HeroSlide) onSave;

  const SlideFormDialog({
    super.key,
    this.slide,
    required this.onSave,
  });

  @override
  State<SlideFormDialog> createState() => _SlideFormDialogState();
}

class _SlideFormDialogState extends State<SlideFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _ctaTextController;
  late TextEditingController _ctaLinkController;
  late int _displayOrder;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final slide = widget.slide;
    _titleController = TextEditingController(text: slide?.title ?? '');
    _subtitleController = TextEditingController(text: slide?.subtitle ?? '');
    _descriptionController =
        TextEditingController(text: slide?.description ?? '');
    _imageUrlController = TextEditingController(text: slide?.imageUrl ?? '');
    _ctaTextController =
        TextEditingController(text: slide?.ctaText ?? 'اقرأ المزيد');
    _ctaLinkController =
        TextEditingController(text: slide?.ctaLink ?? '/news');
    _displayOrder = slide?.displayOrder ?? 1;
    _isActive = slide?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _ctaTextController.dispose();
    _ctaLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.slide != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.slideshow,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'تعديل الشريحة' : 'إضافة شريحة جديدة',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    hintText: 'عنوان الشريحة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان الفرعي',
                    hintText: 'عنوان فرعي',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    hintText: 'وصف الشريحة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط الصورة',
                    hintText: 'https://example.com/image.jpg',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ctaTextController,
                        decoration: const InputDecoration(
                          labelText: 'نص الزر',
                          hintText: 'اقرأ المزيد',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                        v?.isEmpty ?? true ? 'الحقل مطلوب' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _ctaLinkController,
                        decoration: const InputDecoration(
                          labelText: 'رابط الزر',
                          hintText: '/news',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                        v?.isEmpty ?? true ? 'الحقل مطلوب' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _displayOrder,
                        decoration: const InputDecoration(
                          labelText: 'الترتيب',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          10,
                              (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1}'),
                          ),
                        ),
                        onChanged: (v) => setState(() => _displayOrder = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('نشطة'),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v ?? true),
                        activeColor: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                      ),
                      child: Text(isEditing ? 'تحديث' : 'إضافة'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final slide = HeroSlide(
      id: widget.slide?.id ?? '',
      title: _titleController.text,
      subtitle: _subtitleController.text,
      description: _descriptionController.text,
      imageUrl: _imageUrlController.text,
      ctaText: _ctaTextController.text,
      ctaLink: _ctaLinkController.text,
      displayOrder: _displayOrder,
      isActive: _isActive,
      createdAt: widget.slide?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(slide);
    Navigator.pop(context);
  }
}