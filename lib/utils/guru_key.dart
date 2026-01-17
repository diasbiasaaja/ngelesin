String guruKeyFromNama(String namaGuru) {
  return namaGuru
      .trim()
      .replaceAll(RegExp(r'[.#$\[\]]'), '')
      .replaceAll(RegExp(r'\s+'), '_');
}
