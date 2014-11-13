; C source:
;
; typedef struct TSpoint {
; 	char x;
;	int y;
;	int z;
; } Tpoint;
;

; produced LLVM:
%struct.TSpoint = type { i8, i32, i32 }

; the following routine illustrates how LLVM handles whole structures
; functions may take structure types as parameter type and as return type
define %struct.TSpoint @dx(%struct.TSpoint %p) {
  %1 = alloca %struct.TSpoint
  %2 = alloca %struct.TSpoint
  ; assignment of a structure value to a structure
  store %struct.TSpoint {i8 111, i32 0, i32 0}, %struct.TSpoint* %1
  ; assignment of a structure to a structure
  store %struct.TSpoint %p, %struct.TSpoint* %2
  %3 = load %struct.TSpoint* %1
  ret %struct.TSpoint %3
}

define i32 @f2(%struct.TSpoint %p) {
  %1 = extractvalue %struct.TSpoint {i8 111, i32 0, i32 0}, 1
  ret i32 %1
}

