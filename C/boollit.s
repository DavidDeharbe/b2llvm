; ModuleID = 'boollit.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

define zeroext i1 @f(i1 zeroext %a, i1 zeroext %b) nounwind uwtable ssp {
  %1 = alloca i8, align 1
  %2 = alloca i8, align 1
  %c = alloca i32, align 4
  %3 = zext i1 %a to i8
  store i8 %3, i8* %1, align 1
  %4 = zext i1 %b to i8
  store i8 %4, i8* %2, align 1
  %5 = load i8* %1, align 1
  %6 = trunc i8 %5 to i1
  %7 = zext i1 %6 to i32
  %8 = icmp eq i32 %7, 1
  br i1 %8, label %9, label %13

; <label>:9                                       ; preds = %0
  %10 = load i8* %2, align 1
  %11 = trunc i8 %10 to i1
  %12 = zext i1 %11 to i32
  br label %14

; <label>:13                                      ; preds = %0
  br label %14

; <label>:14                                      ; preds = %13, %9
  %15 = phi i32 [ %12, %9 ], [ 0, %13 ]
  store i32 %15, i32* %c, align 4
  store i8 0, i8* %1, align 1
  store i8 0, i8* %2, align 1
  %16 = load i8* %1, align 1
  %17 = trunc i8 %16 to i1
  br i1 %17, label %18, label %21

; <label>:18                                      ; preds = %14
  %19 = load i8* %2, align 1
  %20 = trunc i8 %19 to i1
  br i1 %20, label %24, label %21

; <label>:21                                      ; preds = %18, %14
  %22 = load i32* %c, align 4
  %23 = icmp ne i32 %22, 0
  br label %24

; <label>:24                                      ; preds = %21, %18
  %25 = phi i1 [ true, %18 ], [ %23, %21 ]
  ret i1 %25
}
