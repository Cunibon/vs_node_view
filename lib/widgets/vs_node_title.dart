import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vs_node_view/data/vs_node_data.dart';
import 'package:vs_node_view/data/vs_node_data_provider.dart';

enum PopupOptions { rename, delete }

class VSNodeTitle extends StatefulWidget {
  ///Base node title widget
  ///
  ///Used in [VSNode] to build the title
  const VSNodeTitle({
    required this.data,
    super.key,
  });

  final VSNodeData data;

  @override
  State<VSNodeTitle> createState() => _VSNodeTitleState();
}

class _VSNodeTitleState extends State<VSNodeTitle> {
  bool isRenaming = false;
  final titleController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.data.title;
  }

  @override
  Widget build(BuildContext context) {
    if (isRenaming) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                readOnly: !isRenaming,
                controller: titleController,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.data.type,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 5,
                  ),
                ),
                onTapOutside: (event) => setState(() {
                  isRenaming = false;
                  titleController.text = widget.data.title;
                }),
                onSubmitted: (input) => widget.data.title = input,
              ),
            ),
            PopupMenuButton<PopupOptions>(
              tooltip: "",
              child: const Icon(
                Icons.more_vert,
                size: 20,
              ),
              onSelected: (value) {
                switch (value) {
                  case PopupOptions.rename:
                    setState(
                      () => isRenaming = true,
                    );
                    break;
                  case PopupOptions.delete:
                    context.read<VSNodeDataProvider>().removeNodes(
                      [widget.data],
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<PopupOptions>(
                  value: PopupOptions.rename,
                  child: Text("Rename"),
                ),
                const PopupMenuItem<PopupOptions>(
                  value: PopupOptions.delete,
                  child: Text("Delete"),
                ),
              ],
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
