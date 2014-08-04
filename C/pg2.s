; ModuleID = 'pg2.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

@c1 = common global i16 0, align 2
@c2 = common global i16 0, align 2
@c3 = common global i16 0, align 2
@c4 = common global i16 0, align 2

define zeroext i16 @f1() nounwind uwtable ssp {
  store i16 96, i16* @c1, align 2
  store i16 128, i16* @c2, align 2
  %1 = load i16* @c1, align 2
  %2 = zext i16 %1 to i32
  %3 = load i16* @c2, align 2
  %4 = zext i16 %3 to i32
  %5 = icmp slt i32 %2, %4
  br i1 %5, label %6, label %10

; <label>:6                                       ; preds = %0
  %7 = load i16* @c1, align 2
  store i16 %7, i16* @c3, align 2
  %8 = load i16* @c2, align 2
  store i16 %8, i16* @c1, align 2
  %9 = load i16* @c3, align 2
  store i16 %9, i16* @c2, align 2
  br label %10

; <label>:10                                      ; preds = %6, %0
  store i16 0, i16* @c4, align 2
  br label %11

; <label>:11                                      ; preds = %19, %10
  %12 = load i16* @c2, align 2
  %13 = zext i16 %12 to i32
  %14 = load i16* @c1, align 2
  %15 = zext i16 %14 to i32
  %16 = sdiv i32 %15, %13
  %17 = trunc i32 %16 to i16
  store i16 %17, i16* @c1, align 2
  %18 = icmp ne i16 %17, 0
  br i1 %18, label %19, label %32

; <label>:19                                      ; preds = %11
  %20 = load i16* @c1, align 2
  %21 = zext i16 %20 to i32
  %22 = load i16* @c2, align 2
  %23 = zext i16 %22 to i32
  %24 = sub nsw i32 %21, %23
  %25 = trunc i32 %24 to i16
  store i16 %25, i16* @c3, align 2
  %26 = load i16* @c2, align 2
  store i16 %26, i16* @c1, align 2
  %27 = load i16* @c3, align 2
  store i16 %27, i16* @c2, align 2
  %28 = load i16* @c4, align 2
  %29 = zext i16 %28 to i32
  %30 = add nsw i32 %29, 1
  %31 = trunc i32 %30 to i16
  store i16 %31, i16* @c4, align 2
  br label %11

; <label>:32                                      ; preds = %11
  %33 = load i16* @c4, align 2
  ret i16 %33
}
