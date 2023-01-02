import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/util/debouncer.dart';

class ClearSupportedTextField extends StatefulWidget {
  final String hint;
  final int maxLines;
  final Function(String) callback;
  final String initialText;
  ClearSupportedTextField(this.hint, this.maxLines, this.callback, this.initialText);

  @override
  _ClearSupportedTextFieldState createState() => _ClearSupportedTextFieldState();
}

class _ClearSupportedTextFieldState extends State<ClearSupportedTextField> {
  late TextEditingController _textController;
  late bool _wasEmpty;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _wasEmpty = _textController.text.isEmpty;
    _textController.addListener(() {
      if (_wasEmpty != _textController.text.isEmpty) {
        setState(() => {_wasEmpty = _textController.text.isEmpty});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (String text){
        _debouncer.run(() {
          widget.callback(text);
        });
      },
      controller: _textController,
      minLines: 1,
      maxLines: widget.maxLines,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        suffixIcon: _textController.text.isNotEmpty ? IconButton(
          icon: Icon(Icons.clear), onPressed: () {
          _textController.clear();

          FocusScope.of(context).unfocus();
        },
        ) : null,
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.fromLTRB(2, 22, 0, 0),
        hintText: widget.hint,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
