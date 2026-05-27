import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common/color_swatch_picker.dart';
import '../widgets/common/form_sheet.dart';
import '../widgets/common/section_label.dart';

Future<void> showProjectDialog(BuildContext context, {Project? existing}) {
  return FormSheet.show<void>(
    context,
    child: _ProjectSheet(existing: existing),
  );
}

class _ProjectSheet extends StatefulWidget {
  const _ProjectSheet({this.existing});
  final Project? existing;

  @override
  State<_ProjectSheet> createState() => _ProjectSheetState();
}

class _ProjectSheetState extends State<_ProjectSheet> {
  late TextEditingController _name;
  late TextEditingController _desc;
  late int _colorIndex;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _desc = TextEditingController(text: widget.existing?.description ?? '');
    _colorIndex = widget.existing?.colorIndex ?? 0;
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return FormSheet(
      title: Text(
        isEdit ? 'dialogProjectEditTitle'.tr() : 'dialogProjectNewTitle'.tr(),
        overflow: TextOverflow.ellipsis,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _name,
            autofocus: !isEdit,
            decoration: InputDecoration(labelText: 'fieldName'.tr()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 2,
            decoration: InputDecoration(labelText: 'fieldDescription'.tr()),
          ),
          const SizedBox(height: 18),
          SectionLabel('fieldColor'.tr()),
          const SizedBox(height: 10),
          ColorSwatchPicker(
            selectedIndex: _colorIndex,
            onSelected: (i) => setState(() => _colorIndex = i),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('commonCancel'.tr(), overflow: TextOverflow.ellipsis),
        ),
        FilledButton(
          onPressed: _name.text.trim().isEmpty
              ? null
              : () async {
                  final state = context.read<AppState>();
                  if (isEdit) {
                    await state.updateProject(widget.existing!.copyWith(
                      name: _name.text.trim(),
                      description: _desc.text.trim().isEmpty
                          ? null
                          : _desc.text.trim(),
                      colorIndex: _colorIndex,
                    ));
                  } else {
                    await state.createProject(
                      name: _name.text.trim(),
                      description: _desc.text.trim().isEmpty
                          ? null
                          : _desc.text.trim(),
                      colorIndex: _colorIndex,
                    );
                  }
                  if (context.mounted) Navigator.pop(context);
                },
          child: Text(
            isEdit ? 'commonSave'.tr() : 'commonCreate'.tr(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
