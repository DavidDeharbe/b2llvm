; ModuleID = 'struct.c'
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.10.0"

%struct.TSpoint = type { i8, i32, i32 }

@orig = global %struct.TSpoint { i8 111, i32 0, i32 0 }, align 4

; Function Attrs: nounwind ssp uwtable
define { i64, i32 } @dx(i64 %p.coerce0, i32 %p.coerce1) #0 {
  %1 = alloca %struct.TSpoint, align 4
  %p = alloca %struct.TSpoint, align 8
  %2 = alloca { i64, i32 }, align 8
  %res = alloca %struct.TSpoint, align 4
  %3 = alloca { i64, i32 }
  %4 = getelementptr { i64, i32 }* %2, i32 0, i32 0
  store i64 %p.coerce0, i64* %4
  %5 = getelementptr { i64, i32 }* %2, i32 0, i32 1
  store i32 %p.coerce1, i32* %5
  %6 = bitcast %struct.TSpoint* %p to i8*
  %7 = bitcast { i64, i32 }* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %6, i8* %7, i64 12, i32 8, i1 false)
  %8 = bitcast %struct.TSpoint* %res to i8*
  %9 = bitcast %struct.TSpoint* %p to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %8, i8* %9, i64 12, i32 4, i1 false)
  %10 = getelementptr inbounds %struct.TSpoint* %res, i32 0, i32 1
  %11 = load i32* %10, align 4
  %12 = add nsw i32 %11, 1
  %13 = getelementptr inbounds %struct.TSpoint* %res, i32 0, i32 1
  store i32 %12, i32* %13, align 4
  %14 = getelementptr inbounds %struct.TSpoint* %p, i32 0, i32 0
  %15 = load i8* %14, align 1
  store i8 %15, i8* getelementptr inbounds (%struct.TSpoint* @orig, i32 0, i32 0), align 1
  %16 = bitcast %struct.TSpoint* %1 to i8*
  %17 = bitcast %struct.TSpoint* %res to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %16, i8* %17, i64 12, i32 4, i1 false)
  %18 = bitcast { i64, i32 }* %3 to i8*
  %19 = bitcast %struct.TSpoint* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %18, i8* %19, i64 12, i32 1, i1 false)
  %20 = load { i64, i32 }* %3
  ret { i64, i32 } %20
}

; Function Attrs: nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i32, i1) #1

attributes #0 = { nounwind ssp uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"Apple LLVM version 6.0 (clang-600.0.54) (based on LLVM 3.5svn)"}
