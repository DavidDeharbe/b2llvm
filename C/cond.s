; ModuleID = 'cond.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

define i32 @test(i32 %a, i32 %b, i32 %c) nounwind uwtable ssp {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %a, i32* %2, align 4
  store i32 %b, i32* %3, align 4
  store i32 %c, i32* %4, align 4
  %5 = load i32* %2, align 4
  %6 = load i32* %3, align 4
  %7 = icmp sle i32 %5, %6
  br i1 %7, label %8, label %13

; <label>:8                                       ; preds = %0
  %9 = load i32* %3, align 4
  %10 = load i32* %4, align 4
  %11 = icmp sle i32 %9, %10
  br i1 %11, label %12, label %13

; <label>:12                                      ; preds = %8
  store i32 1, i32* %1
  br label %31

; <label>:13                                      ; preds = %8, %0
  %14 = load i32* %2, align 4
  %15 = load i32* %4, align 4
  %16 = icmp sgt i32 %14, %15
  br i1 %16, label %18, label %17

; <label>:17                                      ; preds = %13
  store i32 2, i32* %1
  br label %31

; <label>:18                                      ; preds = %13
  %19 = load i32* %2, align 4
  %20 = load i32* %3, align 4
  %21 = icmp sgt i32 %19, %20
  br i1 %21, label %27, label %22

; <label>:22                                      ; preds = %18
  %23 = load i32* %2, align 4
  %24 = load i32* %4, align 4
  %25 = mul nsw i32 2, %24
  %26 = icmp sgt i32 %23, %25
  br i1 %26, label %27, label %28

; <label>:27                                      ; preds = %22, %18
  store i32 3, i32* %1
  br label %31

; <label>:28                                      ; preds = %22
  br label %29

; <label>:29                                      ; preds = %28
  br label %30

; <label>:30                                      ; preds = %29
  store i32 4, i32* %1
  br label %31

; <label>:31                                      ; preds = %30, %27, %17, %12
  %32 = load i32* %1
  ret i32 %32
}
