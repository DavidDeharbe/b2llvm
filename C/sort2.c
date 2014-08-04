void sort2 (char v1, char v2, char *min, char *max) {
  if (v1 <= v2) {
    *min = v1;
    *max = v2;
  } else {
    *min = v2;
    *max = v1;
  }
}
