; ModuleID = 'pg3.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

@c1 = common global i8 0, align 1
@c2 = common global i8 0, align 1

define zeroext i8 @f1() nounwind uwtable ssp {
  %c3 = alloca i8, align 1
  %c4 = alloca i8, align 1
  %c31 = alloca i8, align 1
  store i8 48, i8* @c1, align 1
  store i8 76, i8* @c2, align 1
  %1 = load i8* @c1, align 1
  %2 = zext i8 %1 to i32
  %3 = load i8* @c2, align 1
  %4 = zext i8 %3 to i32
  %5 = icmp slt i32 %2, %4
  br i1 %5, label %6, label %10

; <label>:6                                       ; preds = %0
  %7 = load i8* @c1, align 1
  store i8 %7, i8* %c31, align 1
  %8 = load i8* @c2, align 1
  store i8 %8, i8* @c1, align 1
  %9 = load i8* %c31, align 1
  store i8 %9, i8* @c2, align 1
  br label %10

; <label>:10                                      ; preds = %6, %0
  store i8 0, i8* %c4, align 1
  br label %11

; <label>:11                                      ; preds = %19, %10
  %12 = load i8* @c2, align 1
  %13 = zext i8 %12 to i32
  %14 = load i8* @c1, align 1
  %15 = zext i8 %14 to i32
  %16 = sdiv i32 %15, %13
  %17 = trunc i32 %16 to i8
  store i8 %17, i8* @c1, align 1
  %18 = icmp ne i8 %17, 0
  br i1 %18, label %19, label %32

; <label>:19                                      ; preds = %11
  %20 = load i8* @c1, align 1
  %21 = zext i8 %20 to i32
  %22 = load i8* @c2, align 1
  %23 = zext i8 %22 to i32
  %24 = sub nsw i32 %21, %23
  %25 = trunc i32 %24 to i8
  store i8 %25, i8* %c3, align 1
  %26 = load i8* @c2, align 1
  store i8 %26, i8* @c1, align 1
  %27 = load i8* %c3, align 1
  store i8 %27, i8* @c2, align 1
  %28 = load i8* %c4, align 1
  %29 = zext i8 %28 to i32
  %30 = add nsw i32 %29, 1
  %31 = trunc i32 %30 to i8
  store i8 %31, i8* %c4, align 1
  br label %11

; <label>:32                                      ; preds = %11
  %33 = load i8* %c4, align 1
  ret i8 %33
}
