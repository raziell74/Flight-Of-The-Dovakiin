scriptName FlightPhysicsPluginScript Hidden

; Setters
Function SetFlightSpeeds(float forwardSpeed, float sprintSpeed, float fallingSpeed, float liftUpSpeed, float liftDownSpeed, float dynamicSpeedChange) global native
Function SetIsFlying(bool isFlying) global native
Function SetIsFlyingUp(bool isFlyingUp) global native
Function SetIsFlyingDown(bool isFlyingDown) global native
Function SetIsHovering(bool isHovering) global native
Function SetIsFlyingBackward(bool isFlyingBackward) global native
Function SetIsSprinting(bool isSprinting) global native
Function SetIsTakingOff(bool isTakingOff) global native

; Getters
float Function isOnGround() global native
float Function GetForwardSpeed() global native
float Function GetFallingSpeed() global native
float Function GetLiftUpSpeed() global native
float Function GetLiftDownSpeed() global native
float Function GetDynamicSpeedChange() global native