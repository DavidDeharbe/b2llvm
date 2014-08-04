; ModuleID = 'pg1.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

@a = internal global i32 0, align 4

define i32 @f1() nounwind uwtable ssp {
  %c1 = alloca i32, align 4
  %c2 = alloca i32, align 4
  %c3 = alloca i32, align 4
  %c4 = alloca i32, align 4
  %1 = load i32* @a, align 4
  %2 = add nsw i32 96, %1 	; 96 + a
  store i32 %2, i32* %c1, align 4 ; c1 = 96 + a
  store i32 128, i32* %c2, align 4 ; c2 = 128
  %3 = load i32* %c1, align 4
  %4 = load i32* %c2, align 4
  %5 = icmp slt i32 %3, %4	; c1 < c2
  br i1 %5, label %6, label %10

; <label>:6                                       ; preds = %0
  %7 = load i32* %c1, align 4
  store i32 %7, i32* %c3, align 4
  %8 = load i32* %c2, align 4
  store i32 %8, i32* %c1, align 4
  %9 = load i32* %c3, align 4
  store i32 %9, i32* %c2, align 4
  br label %10

; <label>:10                                      ; preds = %6, %0
  %11 = load i32* %c4, align 4
  %12 = load i32* %c2, align 4
  %13 = add nsw i32 %11, %12
  store i32 %13, i32* %c4, align 4
  br label %14

; <label>:14                                      ; preds = %19, %10
  %15 = load i32* %c2, align 4
  %16 = load i32* %c1, align 4
  %17 = sdiv i32 %16, %15
  store i32 %17, i32* %c1, align 4
  %18 = icmp ne i32 %17, 0
  br i1 %18, label %19, label %27

; <label>:19                                      ; preds = %14
  %20 = load i32* %c1, align 4
  %21 = load i32* %c2, align 4
  %22 = sub nsw i32 %20, %21
  store i32 %22, i32* %c3, align 4
  %23 = load i32* %c2, align 4
  store i32 %23, i32* %c1, align 4
  %24 = load i32* %c3, align 4
  store i32 %24, i32* %c2, align 4
  %25 = load i32* %c4, align 4
  %26 = add nsw i32 %25, 1
  store i32 %26, i32* %c4, align 4
  br label %14

; <label>:27                                      ; preds = %14
  %28 = load i32* %c4, align 4
  ret i32 %28
}
