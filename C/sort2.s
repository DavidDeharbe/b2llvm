; ModuleID = 'sort2.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

define void @sort2(i8 signext %v1, i8 signext %v2, i8* %min, i8* %max) nounwind uwtable ssp {
  %1 = alloca i8, align 1
  %2 = alloca i8, align 1
  %3 = alloca i8*, align 8
  %4 = alloca i8*, align 8
  store i8 %v1, i8* %1, align 1
  store i8 %v2, i8* %2, align 1
  store i8* %min, i8** %3, align 8
  store i8* %max, i8** %4, align 8
  %5 = load i8* %1, align 1
  %6 = sext i8 %5 to i32
  %7 = load i8* %2, align 1
  %8 = sext i8 %7 to i32
  %9 = icmp sle i32 %6, %8
  br i1 %9, label %10, label %15

; <label>:10                                      ; preds = %0
  %11 = load i8* %1, align 1
  %12 = load i8** %3, align 8
  store i8 %11, i8* %12
  %13 = load i8* %2, align 1
  %14 = load i8** %4, align 8
  store i8 %13, i8* %14
  br label %20

; <label>:15                                      ; preds = %0
  %16 = load i8* %2, align 1
  %17 = load i8** %3, align 8
  store i8 %16, i8* %17
  %18 = load i8* %1, align 1
  %19 = load i8** %4, align 8
  store i8 %18, i8* %19
  br label %20

; <label>:20                                      ; preds = %15, %10
  ret void
}
