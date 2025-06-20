import 'package:flutter/material.dart';
import 'package:node_me/utils/app_color.dart';
import 'package:node_me/utils/screen_size.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  const SearchBarWidget({super.key, required this.textEditingController});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  String lastword = "Search for Products";
  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);

    return Container(
      height: screenSize.width * 0.11,
      width: screenSize.width * 0.9,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(),
          SizedBox(
            width: screenSize.width * 0.7,
            height: screenSize.height * 0.1,
            child: Container(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: TextField(
                controller: widget.textEditingController,

                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: Colors.white),
                  contentPadding: const EdgeInsets.only(bottom: 10),
                  hintText: lastword,
                  hintStyle: const TextStyle(
                    color: Colors.white,
                    decorationColor: Colors.white,
                  ),
                  fillColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
