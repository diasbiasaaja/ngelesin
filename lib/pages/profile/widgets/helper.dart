import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '/dummy/dummy_user.dart';

const Color softBg = Color(0xFFF3F4F6);

// ================= CARD =================
Widget card(Widget child) {
  return Container(
    width: 340,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}

// ================= AVATAR =================
Widget avatar() {
  return Column(
    children: const [
      CircleAvatar(
        radius: 34,
        backgroundColor: Color(0xFFE5E7EB),
        child: Icon(Icons.person, size: 36, color: Colors.grey),
      ),
      SizedBox(height: 16),
    ],
  );
}

// ================= INPUT FIELD =================
Widget field(
  String label,
  TextEditingController controller, {
  bool isPassword = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: softBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: navy, width: 1.5),
        ),
      ),
    ),
  );
}

// ================= STATIC BOX (HARGA) =================
Widget staticBox(String title, String value) {
  return Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: softBg,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: navy),
        ),
        const SizedBox(height: 4),
        Text(value),
      ],
    ),
  );
}

// ================= BUTTON ROW =================
Widget actionRow({
  required String primaryText,
  required VoidCallback onPrimary,
  required VoidCallback onSecondary,
}) {
  return Row(
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: yellowAcc,
            foregroundColor: navy,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onPrimary,
          child: Text(
            primaryText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: navy,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: navy),
          ),
          onPressed: onSecondary,
          child: const Text("Kembali"),
        ),
      ),
    ],
  );
}
