; ModuleID = 'arr2.c'
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.10.0"

  ;; a = a+v[1];
  ;; b = m[0][0];
  ;; b += m[0][1];
  ;; b += m[1][0];
  ;; printf("%i %i\n", a, b);
@.str = private unnamed_addr constant [7 x i8] c"%i %i\0A\00", align 1

; Function Attrs: nounwind ssp uwtable
define void @f([4 x i32] %v, [5 x [3 x i32]] %m) #0 {
    ;;;;                       int a;
  %a = alloca i32, align 4
    ;;;;                       int b;
  %b = alloca i32, align 4
    ;;;;                       a = v[0];
  %1 = extractvalue [4 x i32] %v, 0
  store i32 %1, i32* %a, align 4
    ;;;;                       b = m[0][0];
  %2 = extractvalue [5 x [3 x i32]] %m, 0, 0
  store i32 %2, i32* %b, align 4
  %3 = load i32* %a, align 4
    ;;;;                       v[1] = a;
  insertvalue [4 x i32] %v, i32 %3, 1
  ret void
}

declare i32 @printf(i8*, ...) #1

attributes #0 = { nounwind ssp uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"Apple LLVM version 6.0 (clang-600.0.54) (based on LLVM 3.5svn)"}
