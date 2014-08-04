; ModuleID = 'pg9.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-apple-darwin10.8"

%struct.ModuloName_internalState = type { i8, i32 }

define void @d00(%struct.ModuloName_internalState* nocapture %pointerMVars) nounwind readnone ssp {
entry:
  ret void
}

define void @d000(%struct.ModuloName_internalState* nocapture %pointerMVars, %struct.ModuloName_internalState* nocapture %pointerVars2teste) nounwind readnone ssp {
entry:
  ret void
}

define void @d0(%struct.ModuloName_internalState* nocapture %pointerMVars) nounwind readnone ssp {
entry:
  ret void
}

define void @da(%struct.ModuloName_internalState* nocapture %pointerMVars) nounwind ssp {
entry:
  %0 = getelementptr inbounds %struct.ModuloName_internalState* %pointerMVars, i64 0, i32 0 ; <i8*> [#uses=1]
  store i8 50, i8* %0, align 4
  ret void
}

define void @db(%struct.ModuloName_internalState* nocapture %pointerMVars, i8 zeroext %d) nounwind readnone ssp {
entry:
  ret void
}

define void @de(%struct.ModuloName_internalState* nocapture %pointerMVars, i8 zeroext %d) nounwind ssp {
entry:
  %0 = getelementptr inbounds %struct.ModuloName_internalState* %pointerMVars, i64 0, i32 0 ; <i8*> [#uses=1]
  store i8 %d, i8* %0, align 4
  ret void
}

define void @df(%struct.ModuloName_internalState* nocapture %pointerMVars, i8 zeroext %d) nounwind ssp {
entry:
  %0 = getelementptr inbounds %struct.ModuloName_internalState* %pointerMVars, i64 0, i32 0 ; <i8*> [#uses=1]
  store i8 %d, i8* %0, align 4
  %1 = zext i8 %d to i32                          ; <i32> [#uses=1]
  %2 = getelementptr inbounds %struct.ModuloName_internalState* %pointerMVars, i64 0, i32 1 ; <i32*> [#uses=1]
  store i32 %1, i32* %2, align 4
  ret void
}

define void @dg(%struct.ModuloName_internalState* nocapture %pointerMVars, i8 zeroext %d) nounwind ssp {
entry:
  %0 = getelementptr inbounds %struct.ModuloName_internalState* %pointerMVars, i64 0, i32 0 ; <i8*> [#uses=2]
  %1 = load i8* %0, align 4                       ; <i8> [#uses=1]
  %2 = add i8 %1, %d                              ; <i8> [#uses=1]
  store i8 %2, i8* %0, align 4
  %3 = zext i8 %d to i32                          ; <i32> [#uses=1]
  %4 = getelementptr inbounds %struct.ModuloName_internalState* %pointerMVars, i64 0, i32 1 ; <i32*> [#uses=2]
  %5 = load i32* %4, align 4                      ; <i32> [#uses=1]
  %6 = add i32 %5, %3                             ; <i32> [#uses=1]
  store i32 %6, i32* %4, align 4
  ret void
}
