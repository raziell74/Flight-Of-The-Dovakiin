#include "FlightPhysicsPlugin.h"

// Flight speed defaults
static float Forward_Speed = 5.1f;
static float Sprint_Speed = 15.0f;
static float Falling_Speed = 2.5f;
static float LiftUp_Speed = 15.0f;
static float LiftDown_Speed = 2.0f;
static float DynamicSpeedChange = 0.1f;

// Flight status flags
static bool on_ground = true;

static bool isFlyingActive = false;
static bool isFlyingUp = false;
static bool isFlyingDown = false;
static bool isHovering = false;
static bool isFlyingBackward = false;
static bool isSprinting = false;
static bool isTakingOff = false;

// Facilitates communication between SKSE and Papyrus
namespace FlightPhysicsPluginNamespace {
	// Papyrus accessable functions
	float isOnGround(StaticFunctionTag *base) {
		return on_ground;
	}

	//Speed controls
	void SetFlightSpeeds(StaticFunctionTag *base, float forwardSpeed, float sprintSpeed, float fallingSpeed, float liftUpSpeed, float liftDownSpeed, float dynamicSpeedChange) {
		Forward_Speed = forwardSpeed;
		Sprint_Speed = sprintSpeed;
		Falling_Speed = fallingSpeed;
		LiftUp_Speed = liftUpSpeed;
		LiftDown_Speed = liftDownSpeed;
		DynamicSpeedChange = dynamicSpeedChange;
	}

	float GetForwardSpeed(StaticFunctionTag *base) { return Forward_Speed; }
	float GetSprintSpeed(StaticFunctionTag *base) { return Sprint_Speed; }
	float GetFallingSpeed(StaticFunctionTag *base) { return Falling_Speed; }
	float GetLiftUpSpeed(StaticFunctionTag *base) { return LiftUp_Speed; }
	float GetLiftDownSpeed(StaticFunctionTag *base) { return LiftDown_Speed; }
	float GetDynamicSpeedChange(StaticFunctionTag *base) { return DynamicSpeedChange; }

	// Set Flight States
	void SetIsFlying(StaticFunctionTag *base, bool isFlying) {
		isFlyingActive = isFlying;

		// force all flying states to false if we're not flying
		if (!isFlying) {
			isFlyingUp = false;
			isFlyingDown = false;
			isHovering = false;
			isFlyingBackward = false;
			isSprinting = false;
			isTakingOff = false;
		}
	}

	void SetIsFlyingUp(StaticFunctionTag *base, bool isFlyingUp) {
		isFlyingUp = isFlyingUp;

		// force the proper state
		if (isFlyingUp) {
			isFlyingDown = false;
			isHovering = false;
		}
	}

	void SetIsFlyingDown(StaticFunctionTag *base, bool isFlyingDown) {
		isFlyingDown = isFlyingDown;

		// force the proper state
		if (isFlyingDown) {
			isFlyingUp = false;
			isHovering = false;
		}
	}

	void SetIsHovering(StaticFunctionTag *base, bool isHovering) {
		isHovering = isHovering;

		// force the proper state
		if (isHovering) {
			isSprinting = false;
		}
	}

	void SetIsFlyingBackward(StaticFunctionTag *base, bool isFlyingBackward) {
		isFlyingBackward = isFlyingBackward;

		// force the proper state
		if (isFlyingBackward) {
			isSprinting = false;
			isHovering = false;
		}
	}

	void SetIsSprinting(StaticFunctionTag *base, bool isSprinting) {
		isFlyingBackward = isSprinting;
	}

	void SetIsTakingOff(StaticFunctionTag *base, bool isTakingOff) {
		isTakingOff = isTakingOff;

		// force the proper state
		if (isTakingOff) {
			isFlyingActive = true;
			isFlyingUp = false;
			isFlyingDown = false;
			isHovering = false;
			isFlyingBackward = false;
			isSprinting = false;
		}
	}

	// ----------------------------------------------------------------------------------------------------------

	// SKSE Accessable functions
	void SKSESetIsOnGround(bool ground_check) { on_ground = ground_check; }

	// Flight speeds
	float SKSEGetForwardSpeed() { return Forward_Speed; }
	float SKSEGetSprintSpeed() { return Sprint_Speed; }
	float SKSEGetFallingSpeed() { return Falling_Speed; }
	float SKSEGetLiftUpSpeed() { return LiftUp_Speed; }
	float SKSEGetLiftDownSpeed() { return LiftDown_Speed; }
	float SKSEGetDynamicSpeedChange() { return DynamicSpeedChange; }

	// Flight controls
	bool SKSEGetIsFlyingActive() { return isFlyingActive; }
	bool SKSEGetIsFlyingUp() { return isFlyingUp; }
	bool SKSEGetIsFlyingDown() { return isFlyingDown; }
	bool SKSEGetIsHovering() { return isHovering; }
	bool SKSEGetIsFlyingBackward() { return isFlyingBackward; }
	bool SKSEGetIsSprinting() { return isSprinting; }
	bool SKSEGetIsTakingOff() { return isTakingOff; }

	// ----------------------------------------------------------------------------------------------------------

	// Register functions with papyrus
	bool RegisterFuncs(VMClassRegistry* registry) {
		// Register speed control
		registry->RegisterFunction(
			new NativeFunction6 <StaticFunctionTag, void, float, float, float, float, float, float>("SetFlightSpeeds", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::SetFlightSpeeds, registry));
		registry->RegisterFunction(
			new NativeFunction0 <StaticFunctionTag, float>("GetForwardSpeed", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::GetForwardSpeed, registry));
		registry->RegisterFunction(
			new NativeFunction0 <StaticFunctionTag, float>("GetSprintSpeed", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::GetSprintSpeed, registry));
		registry->RegisterFunction(
			new NativeFunction0 <StaticFunctionTag, float>("GetFallingSpeed", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::GetFallingSpeed, registry));
		registry->RegisterFunction(
			new NativeFunction0 <StaticFunctionTag, float>("GetLiftUpSpeed", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::GetLiftUpSpeed, registry));
		registry->RegisterFunction(
			new NativeFunction0 <StaticFunctionTag, float>("GetLiftDownSpeed", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::GetLiftDownSpeed, registry));
		registry->RegisterFunction(
			new NativeFunction0 <StaticFunctionTag, float>("GetDynamicSpeedChange", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::GetDynamicSpeedChange, registry));

		// Register flight control
		registry->RegisterFunction(
		    new NativeFunction1 <StaticFunctionTag, void, bool>("SetIsFlying", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::SetIsFlying, registry));
		registry->RegisterFunction(
			new NativeFunction1 <StaticFunctionTag, void, bool>("SetIsFlyingUp", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::SetIsFlyingUp, registry));
		registry->RegisterFunction(
			new NativeFunction1 <StaticFunctionTag, void, bool>("SetIsFlyingDown", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::SetIsFlyingDown, registry));
		registry->RegisterFunction(
			new NativeFunction1 <StaticFunctionTag, void, bool>("SetIsHovering", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::SetIsHovering, registry));
		registry->RegisterFunction(
			new NativeFunction1 <StaticFunctionTag, void, bool>("SetIsFlyingBackward", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::SetIsFlyingBackward, registry));
		registry->RegisterFunction(
			new NativeFunction1 <StaticFunctionTag, void, bool>("SetIsSprinting", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::SetIsSprinting, registry));
		registry->RegisterFunction(
			new NativeFunction1 <StaticFunctionTag, void, bool>("SetIsTakingOff", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::SetIsTakingOff, registry));

		registry->RegisterFunction(
			new NativeFunction0 <StaticFunctionTag, float>("isOnGround", "FlightPhysicsPluginScript", FlightPhysicsPluginNamespace::isOnGround, registry));
		return true;
	}
}
