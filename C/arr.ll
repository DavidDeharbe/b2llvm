; ModuleID = 'arr.c'
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.10.0"

@coef = global [3 x i32] [i32 4, i32 5, i32 6], align 4
@a = common global [128 x [32 x i32]] zeroinitializer, align 16

; Function Attrs: nounwind ssp uwtable
define i32 @m3(i32 %n1, i32 %n2, i32 %n3) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %num = alloca i32, align 4
  %den = alloca i32, align 4
  %n = alloca [3 x i32], align 4
  store i32 %n1, i32* %1, align 4
  store i32 %n2, i32* %2, align 4
  store i32 %n3, i32* %3, align 4
  %4 = load i32* %1, align 4
  %5 = getelementptr inbounds [3 x i32]* %n, i32 0, i64 0
  store i32 %4, i32* %5, align 4
  %6 = load i32* %2, align 4
  %7 = getelementptr inbounds [3 x i32]* %n, i32 0, i64 1
  store i32 %6, i32* %7, align 4
  %8 = load i32* %3, align 4
  %9 = getelementptr inbounds [3 x i32]* %n, i32 0, i64 2
  store i32 %8, i32* %9, align 4
  store i32 0, i32* %num, align 4
  %10 = getelementptr inbounds [3 x i32]* %n, i32 0, i64 0
  %11 = load i32* %10, align 4
  %12 = mul nsw i32 %11, 10
  %13 = load i32* getelementptr inbounds ([3 x i32]* @coef, i32 0, i64 0), align 4
  %14 = mul nsw i32 %12, %13
  %15 = load i32* %num, align 4
  %16 = add nsw i32 %15, %14
  store i32 %16, i32* %num, align 4
  %17 = getelementptr inbounds [3 x i32]* %n, i32 0, i64 1
  %18 = load i32* %17, align 4
  %19 = mul nsw i32 %18, 10
  %20 = load i32* getelementptr inbounds ([3 x i32]* @coef, i32 0, i64 1), align 4
  %21 = mul nsw i32 %19, %20
  %22 = load i32* %num, align 4
  %23 = add nsw i32 %22, %21
  store i32 %23, i32* %num, align 4
  %24 = getelementptr inbounds [3 x i32]* %n, i32 0, i64 2
  %25 = load i32* %24, align 4
  %26 = mul nsw i32 %25, 10
  %27 = load i32* getelementptr inbounds ([3 x i32]* @coef, i32 0, i64 2), align 4
  %28 = mul nsw i32 %26, %27
  %29 = load i32* %num, align 4
  %30 = add nsw i32 %29, %28
  store i32 %30, i32* %num, align 4
  %31 = load i32* %num, align 4
  ret i32 %31
}

attributes #0 = { nounwind ssp uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"Apple LLVM version 6.0 (clang-600.0.54) (based on LLVM 3.5svn)"}
