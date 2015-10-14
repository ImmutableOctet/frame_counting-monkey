Strict

Public

#Rem
	PROS:
		* Frame-perfect accuracy.
	CONS:
		* The framerate must the same or higher than the animation-rate.
		
		This can be mitigated using frame-skipping.
		
		* Divison based; technically slower.
		* Requires a frame-counter of some sort. (Could be approximated with a delta-value)
#End

' Imports:
Import mojo2

Import deltatime

' Classes:
Class Application Extends App Final
	' Constant variable(s):
	Const FRAMERATE:= 60
	
	' Constructor(s):
	Method OnCreate:Int()
		SetUpdateRate(0) ' FRAMERATE ' 60
		
		Graphics = New Canvas() ' Null
		
		Element = New Actor()
		
		' ATTENTION: Because of the frame-counting method used by this application,
		' it is prone to floating-point errors if a minimum delta-value is not set.
		DeltaTime = New DeltaTime(FRAMERATE, 0.1) ' <-- Minimum value.
		
		FramesProcessed_ResetTimer = Millisecs() ' DeltaTime.TimeCurrentFrame
		
		' Return the default response.
		Return 0
	End
	
	' Methods:
	Method OnUpdate:Int()
		DeltaTime.Update()
		
		FrameCounter += 1
		
		If ((DeltaTime.TimeCurrentFrame-FramesProcessed_ResetTimer) >= 1000) Then
			Print("Frames processed: " + FramesProcessed)
			
			FramesProcessed = 0
			
			FramesProcessed_ResetTimer = DeltaTime.TimeCurrentFrame
		Endif
		
		If (KeyHit(KEY_SPACE)) Then
			Select AnimationMode
				Case Actor.ANIMATION_MODE_NORMAL
					AnimationMode = Actor.ANIMATION_MODE_PING_PONG
				Case Actor.ANIMATION_MODE_PING_PONG
					Element.AnimationDirection = Actor.ANIMATION_DIRECTION_UP
					AnimationMode = Actor.ANIMATION_MODE_NORMAL
			End Select
		Endif
		
		If (Element.UpdateAnimation(DeltaTime, FrameCounter, AnimationMode)) Then
			FramesProcessed += 1
		Endif
		
		' Return the default response.
		Return 0
	End
	
	Method OnRender:Int()
		Graphics.Clear()
		
		Graphics.DrawText("Press Space to switch animation modes.", 16.0, 16.0)
		
		Graphics.PushMatrix()
		
		Graphics.Translate(Float(DeviceWidth()/2), Float(DeviceHeight()/2))
		
		Element.Render(Graphics)
		
		Graphics.PopMatrix()
		
		Graphics.Flush()
		
		' Return the default response.
		Return 0
	End
	
	' Fields:
	
	' The current frame-counter.
	Field FrameCounter:Int
	
	' The number of frames of animation handled this second.
	Field FramesProcessed:Int
	
	' A timer used to reset 'FramesProcessed' every second.
	Field FramesProcessed_ResetTimer:Int
	
	Field AnimationMode:Int = Actor.ANIMATION_MODE_PING_PONG ' Actor.ANIMATION_MODE_NORMAL
	
	' The element we're manipulating.
	Field Element:Actor
	
	' Our delta-timer.
	Field DeltaTime:DeltaTime
	
	' The canvas we'll be using for graphics.
	Field Graphics:Canvas
End

Class Actor
	' Constant variable(s):
	Const ANIMATION_MODE_NORMAL:= 0
	Const ANIMATION_MODE_PING_PONG:= 1
	
	Const ANIMATION_DIRECTION_UP:Bool = False
	Const ANIMATION_DIRECTION_DOWN:Bool = True
	
	' The number of frames of animation.
	Const FRAME_COUNT:Int = 30 ' (Application.FRAMERATE / 2)
	
	' The number of frames between frame-switches.
	Const ANIMATION_RATE:Int = (Application.FRAMERATE / FRAME_COUNT)
	
	Const SIZE_STEP:Int = Int(16.0 * (Float(FRAME_COUNT) / Float(Application.FRAMERATE))) ' 32.0
	
	' Methods:
	Method Render:Void(Graphics:DrawList)
		' Local variable(s):
		
		' Technically, this should be handled by 'UpdateAnimation'.
		Local DMS:= Float(Millisecs() / 10) ' 100
		
		' Just for the sake of the example, we're drawing rectangles:
		Graphics.SetColor(Sin(DMS), Cos(DMS), 0.5)
		'Graphics.SetColor(1.0, 1.0, 1.0)
		
		Local IS:= ((Frame+1) * SIZE_STEP)
		Local Size:= Float(IS)
		Local HSize:= Float(IS / 2)
		
		Graphics.DrawRect(-HSize, -HSize, Size, Size)
		
		Return
	End
	
	Method UpdateAnimation:Bool(DeltaTime:DeltaTime, FrameCounter:Int, AnimationRate:Int, Mode:Int)
		' Local variable(s):
		
		' Calculate the scaled rate of animation.
		Local ScaledRate:= Max(Int(Float(AnimationRate) / DeltaTime.Delta), 1) ' *
		
		If ((FrameCounter Mod ScaledRate) = 0) Then
			Select Mode
				Case ANIMATION_MODE_NORMAL
					Frame = ((Frame + 1) Mod FRAME_COUNT)
				Case ANIMATION_MODE_PING_PONG
					If (AnimationDirection = ANIMATION_DIRECTION_UP) Then
						Frame += 1
					Else ' If (AnimationDirection = ANIMATION_DIRECTION_DOWN) Then
						Frame -= 1
					Endif
					
					If (Frame = FRAME_COUNT Or Frame = 0) Then
						AnimationDirection = Not AnimationDirection
					Endif
			End Select
			
			' Tell the caller that the frame was changed.
			Return True
		Endif
		
		' Return the default response.
		Return False
	End
	
	Method UpdateAnimation:Bool(DeltaTime:DeltaTime, FrameCounter:Int, Mode:Int=ANIMATION_MODE_PING_PONG)
		Return UpdateAnimation(DeltaTime, FrameCounter, ANIMATION_RATE, Mode)
	End
	
	' Fields:
	
	' The current frame of animation.
	Field Frame:Int
	
	' The direction the animation is playing.
	Field AnimationDirection:Bool
End

' Functions:
Function Main:Int()
	New Application()
	
	' Return the default response.
	Return 0
End