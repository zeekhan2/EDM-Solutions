// ignore_for_file: deprecated_member_use

import 'package:velocity_x/velocity_x.dart';

import '../consts/consts.dart';

class CustomTextField extends StatefulWidget {
  final String title;
  final String? hint;
  final TextEditingController? controller;
  final bool isPass;
  final String? errorText;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.title,
    this.hint,
    this.controller,
    this.isPass = false,
    this.errorText,
    this.suffixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true; // 👁 initially hidden

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 14, right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.title.text
              .color(appPrimeryColor)
              .fontFamily(semibold)
              .size(16)
              .make(),
          5.heightBox,
          TextFormField(
            controller: widget.controller,
            obscureText: widget.isPass ? _obscureText : false,
            keyboardType: widget.title.toLowerCase().contains('email')
                ? TextInputType.emailAddress
                : widget.title.toLowerCase().contains('phone')
                    ? TextInputType.phone
                    : TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontFamily: semibold,
                color: appSeconderyColor,
              ),
              hintText: widget.hint,
              fillColor: appSeconderyColor.withOpacity(0.1),
              filled: true,

              // Always visible border - red if error, normal otherwise
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.errorText != null
                      ? Colors.red
                      : const Color(0xffD0D5DD),
                  width: widget.errorText != null ? 1.5 : 1.0,
                ),
              ),

              // On focus - red if error, normal otherwise
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.errorText != null
                      ? Colors.red
                      : const Color(0xffD0D5DD),
                  width: 1.5,
                ),
              ),

              // Error border
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2.0,
                ),
              ),

              // 👁 Add suffix only if password field
              // ✅ USE THE PASSED suffixIcon IF PROVIDED
              suffixIcon: widget.suffixIcon ??
                  (widget.isPass
                      ? IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: widget.errorText != null
                                ? Colors.red
                                : appPrimeryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                      : null),
            ),
            onChanged: (value) {
              // Force rebuild to update UI when text changes
              if (mounted) {
                setState(() {});
              }
            },
          ),
          5.heightBox,

          // 🔴 ERROR MESSAGE (THIS IS WHAT WAS MISSING)
          if (widget.errorText != null && widget.errorText!.trim().isNotEmpty)
            Text(
              widget.errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: semibold,
              ),
            ),
        ],
      ),
    );
  }
}
