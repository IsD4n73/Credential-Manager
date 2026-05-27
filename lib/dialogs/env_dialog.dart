import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common/color_swatch_picker.dart';
import '../widgets/common/form_sheet.dart';
import '../widgets/common/section_label.dart';

Future<void> showEnvDialog(BuildContext context) {
  return FormSheet.show<void>(context, child: const _EnvSheet());
}

class _EnvSheet extends StatefulWidget {
  const _EnvSheet();

  @override
  State<_EnvSheet> createState() => _EnvSheetState();
}

class _EnvSheetState extends State<_EnvSheet> {
  late TextEditingController _name;
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title:
          Text('dialogEnvNewTitle'.tr(), overflow: TextOverflow.ellipsis),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'dialogEnvNewBody'.tr(),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.none,
            decoration: InputDecoration(labelText: 'fieldName'.tr()),
          ),
          const SizedBox(height: 18),
          SectionLabel('fieldColor'.tr()),
          const SizedBox(height: 10),
          ColorSwatchPicker(
            selectedIndex: _colorIndex,
            onSelected: (i) => setState(() => _colorIndex = i),
            swatchSize: 28,
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
                  final exists = state.envs.any((e) =>
                      e.name.toLowerCase() ==
                      _name.text.trim().toLowerCase());
                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('dialogEnvDuplicate'.tr())),
                    );
                    return;
                  }
                  await state.createEnv(
                    name: _name.text.trim(),
                    colorValue:
                        AppColors.projectPalette[_colorIndex].toARGB32(),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
          child: Text(
            'commonCreate'.tr(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
