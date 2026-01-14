import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_project/model/diary_model.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/service/diary_service.dart';

class DiaryFormPage extends StatefulWidget {
  final DiaryModel? diary;
  final DateTime? selectedDate;

  const DiaryFormPage({super.key, this.diary, this.selectedDate});

  @override
  State<DiaryFormPage> createState() => _DiaryFormPageState();
}

class _DiaryFormPageState extends State<DiaryFormPage> {
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  final List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.diary?.content ?? '',
    );
    _selectedDate = widget.selectedDate ?? widget.diary?.date ?? DateTime.now();
    _existingImageUrls = List.from(widget.diary?.imageUrls ?? []);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            result.files
                .where((file) => file.path != null)
                .map((file) => File(file.path!))
                .toList(),
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra khi chọn ảnh');
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _removeExistingImage(int index) async {
    final imageUrl = _existingImageUrls[index];
    setState(() {
      _isUploading = true;
    });

    try {
      final success = await DiaryService.removeImageFromDiary(
        widget.diary!.id!,
        imageUrl,
      );

      if (success) {
        setState(() {
          _existingImageUrls.removeAt(index);
        });
        _showSuccessSnackBar('Đã xóa ảnh thành công');
      } else {
        _showErrorSnackBar('Có lỗi xảy ra khi xóa ảnh');
      }
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra khi xóa ảnh');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveDiary() async {
    if (_contentController.text.trim().isEmpty &&
        _selectedImages.isEmpty &&
        _existingImageUrls.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập nội dung hoặc thêm ảnh');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await DiaryService.saveDiary(
        date: _selectedDate,
        content: _contentController.text.trim(),
        imageFiles: _selectedImages,
        existingDiary: widget.diary,
      );

      if (success) {
        _showSuccessSnackBar(
          widget.diary == null
              ? 'Tạo nhật ký thành công!'
              : 'Cập nhật nhật ký thành công!',
        );
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar(
          widget.diary == null
              ? 'Có lỗi xảy ra khi tạo nhật ký'
              : 'Có lỗi xảy ra khi cập nhật nhật ký',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.diary == null ? 'Viết nhật ký' : 'Chỉnh sửa nhật ký',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: managerColor.primary,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveDiary,
              child: Text(
                'Lưu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date selector
                _buildDateSelector(),
                SizedBox(height: 20),

                // Content field
                _buildContentField(),
                SizedBox(height: 20),

                // Images section
                _buildImagesSection(),
                SizedBox(height: 100), // Space for floating button
              ],
            ),
          ),

          // Floating action button for adding images
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _pickImages,
              backgroundColor: managerColor.primary,
              child: Icon(Icons.add_photo_alternate, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: managerColor.primary, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ngày',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: _selectDate,
                  child: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildContentField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _contentController,
        maxLines: 10,
        decoration: InputDecoration(
          hintText: 'Viết về ngày hôm nay của bạn...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        style: TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildImagesSection() {
    final allImages = _existingImageUrls.length + _selectedImages.length;

    if (allImages == 0) {
      return Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có ảnh nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Nhấn nút + để thêm ảnh',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library, color: managerColor.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Hình ảnh ($allImages)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Existing images
          if (_existingImageUrls.isNotEmpty) ...[
            Text(
              'Ảnh đã lưu:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            _buildImageGrid(_existingImageUrls, isExisting: true),
            SizedBox(height: 16),
          ],

          // New selected images
          if (_selectedImages.isNotEmpty) ...[
            Text(
              'Ảnh mới:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            _buildImageGrid(_selectedImages, isExisting: false),
          ],
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<dynamic> images, {required bool isExisting}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              clipBehavior: Clip.hardEdge,
              child:
                  isExisting
                      ? Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade500,
                            ),
                          );
                        },
                      )
                      : Image.file(images[index], fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  if (isExisting) {
                    _removeExistingImage(index);
                  } else {
                    _removeSelectedImage(index);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
            if (_isUploading && isExisting)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
