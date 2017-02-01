#include "skse/PapyrusNativeFunctions.h"


namespace FlightPhysicsPluginNamespace {
	// Papyrus accessable functions
	float isOnGround(StaticFunctionTag *base);
	void SetFlightSpeeds(StaticFunctionTag *base, float forwardSpeed, float sprintSpeed, float fallingSpeed, float liftUpSpeed, float liftDownSpeed, float dynamicSpeedChange);
	float GetForwardSpeed(StaticFunctionTag *base);
	float GetFallingSpeed(StaticFunctionTag *base);
	float GetLiftUpSpeed(StaticFunctionTag *base);
	float GetLiftDownSpeed(StaticFunctionTag *base);
	float GetDynamicSpeedChange(StaticFunctionTag *base);
	void SetIsFlying(StaticFunctionTag *base, bool isFlying);
	void SetIsFlyingUp(StaticFunctionTag *base, bool isFlyingUp);
	void SetIsFlyingDown(StaticFunctionTag *base, bool isFlyingDown);
	void SetIsHovering(StaticFunctionTag *base, bool isHovering);
	void SetIsFlyingBackward(StaticFunctionTag *base, bool isFlyingBackward);
	void SetIsSprinting(StaticFunctionTag *base, bool isSprinting);
	void SetIsTakingOff(StaticFunctionTag *base, bool isTakingOff);

	bool RegisterFuncs(VMClassRegistry* registry);

	// SKSE Accessable functions
	void SKSESetIsOnGround(bool ground_check);
	float SKSEGetForwardSpeed();
	float SKSEGetSprintSpeed();
	float SKSEGetFallingSpeed();
	float SKSEGetLiftUpSpeed();
	float SKSEGetLiftDownSpeed();
	float SKSEGetDynamicSpeedChange();
	bool SKSEGetIsFlyingActive();
	bool SKSEGetIsFlyingUp();
	bool SKSEGetIsFlyingDown();
	bool SKSEGetIsHovering();
	bool SKSEGetIsFlyingBackward();
	bool SKSEGetIsSprinting();
	bool SKSEGetIsTakingOff();
}
