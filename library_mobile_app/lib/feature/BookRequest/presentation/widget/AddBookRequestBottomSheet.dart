import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestBloc.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestEvent.dart';

class AddBookRequestBottomSheet extends StatefulWidget {
  const AddBookRequestBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddBookRequestBottomSheet> createState() =>
      _AddBookRequestBottomSheetState();
}

class _AddBookRequestBottomSheetState extends State<AddBookRequestBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'طلب كتاب غير موجود',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الكتاب',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'يرجى إدخال عنوان الكتاب'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'اسم المؤلف',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'يرجى إدخال اسم المؤلف'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    BlocProvider.of<BookRequestBloc>(context).add(
                      SubmitBookRequestEvent(
                        bookTitle: _titleController.text,
                        authorName: _authorController.text,
                        notes: _notesController.text,
                      ),
                    );
                    Navigator.pop(context); // إغلاق البوتم شيت
                  }
                },
                child: const Text(
                  'إرسال الطلب',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
