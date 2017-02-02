#include "skse/PluginAPI.h"		// super
#include "skse/skse_version.h"	// What version of SKSE is running?
#include <shlobj.h>				// CSIDL_MYCODUMENTS

#include "vec3.h"
#include "actor.h"

#include <Windows.h>
#include "detours.h"

#include <fstream>
#include <string>

#include "FlightPhysicsPlugin.h"

static PluginHandle					g_pluginHandle = kPluginHandle_Invalid;
static SKSEPapyrusInterface         * g_papyrus = NULL;

namespace cfg
{
	float Forward_Speed = 5.1f;
	float Sprint_Speed = 15.0f;
	float Falling_Speed = 2.5f;
	float LiftUp_Speed = 15.0f;
	float LiftDown_Speed = 1.0f;
	float DynamicSpeedChange = 0.1f;
};

bool enable_physics = true;
vec3 velocity;

float DynamicVelocity = 5.1f;

struct move_params
{
	float delta;
private:
	char padding[0xC];
public:
	vec3 input;
};

using move_t = void(__thiscall*)(actor::physics_data*, move_params*);
move_t orig_move;

float fJumpHeightMin;
bool isFlyingActive;
bool isFlyingUp;
bool isFlyingDown;
bool isHovering;
bool isFlyingBackward;
bool isSprinting;
bool isTakingOff;

// Override the original Skyrim physics
void __fastcall hook_move(actor::physics_data *phys_data, const int edx, move_params *params)
{
	float max_flight_speed = cfg::Forward_Speed;
	//const auto on_ground = phys_data->fall_time() == 0.F;
	//FlightPhysicsPluginNamespace::SKSESetIsOnGround(on_ground);

	if (!enable_physics) {
		return orig_move(phys_data, params);
	}

	// Read Skyrim engine variable "fJumpHeightMin"
	memcpy(&fJumpHeightMin, (void *)0x01B16218, 4);

	isFlyingActive = isFlyingUp = isFlyingDown = isHovering = isFlyingBackward = isSprinting = false;

	// Determine if we're flying
	if ((fJumpHeightMin > 349.0f) && (fJumpHeightMin < 501.0f))	isFlyingActive = true;
	// What flight state are we currently in
	if ((fJumpHeightMin > 499.0f) && (fJumpHeightMin < 501.0f))	isTakingOff = true;
	if ((fJumpHeightMin > 449.0f) && (fJumpHeightMin < 451.0f))	isFlyingUp = true;
	if ((fJumpHeightMin > 419.0f) && (fJumpHeightMin < 421.0f))	isHovering = true;
	if ((fJumpHeightMin > 409.0f) && (fJumpHeightMin < 411.0f))	isSprinting = true;
	if ((fJumpHeightMin > 389.0f) && (fJumpHeightMin < 391.0f))	isFlyingBackward = true;
	if ((fJumpHeightMin > 349.0f) && (fJumpHeightMin < 351.0f))	isFlyingDown = true;

	// If Character is Flying:
	if ((phys_data->velocity().z < 0) && (isFlyingActive == true)) {
		// Set speeds
		if (isFlyingBackward == true) {
			max_flight_speed = cfg::Forward_Speed / 2;
		}

		if (isSprinting == true) {
			max_flight_speed = cfg::Sprint_Speed;
		}

		if (isHovering == true) {
			max_flight_speed = 0.1f;
		}

		if (DynamicVelocity < max_flight_speed) {
			DynamicVelocity = DynamicVelocity + cfg::DynamicSpeedChange;
		}
		if (DynamicVelocity > max_flight_speed) {
			DynamicVelocity = DynamicVelocity - cfg::DynamicSpeedChange;
		}

		// Assign horizontal velocity
		velocity.y = velocity.y * max_flight_speed;
		velocity.x = velocity.x * max_flight_speed;
		params->input.x = params->input.x * max_flight_speed;
		params->input.y = params->input.y * max_flight_speed;

		velocity.z = phys_data->velocity().z / cfg::Falling_Speed;

		if (isHovering == true) {
			velocity.z = velocity.z + cfg::Falling_Speed / 2;
		}

		if (isFlyingUp == true) {
			velocity.z = velocity.z + cfg::LiftUp_Speed;
		}

		if (isFlyingDown == true) {
			velocity.z = velocity.z - cfg::LiftDown_Speed;
		}

		if (isTakingOff == true) {
			velocity.z = velocity.z + (cfg::LiftUp_Speed * 2);
		}

		phys_data->set_velocity(velocity);
	}

	return orig_move(phys_data, params);
}

using change_cam_t = void(__thiscall*)(uintptr_t, uintptr_t);
change_cam_t orig_change_cam;

// Disable physics during the "VATS" (killcam) camera
void __fastcall hook_change_cam(uintptr_t camera, const int edx, uintptr_t new_state)
{
	auto cam_id = *(int*)(new_state + 0xC);

	enable_physics = cam_id != 2;
	orig_change_cam(camera, new_state);
}

// Read the config file
void read_cfg()
{
	std::ifstream config("Data/SKSE/Plugins/Flying_Physics.cfg");
	if (config.fail())
		return;

	while (!config.eof()) {
		std::string line;
		std::getline(config, line);

		char key[32];
		float value;
		if (sscanf_s(line.c_str(), "%s %f", key, 32, &value) != 2)
			continue;

		if (strncmp(key, "//", 2) == 0)
			continue;

		else if (strcmp(key, "Forward_Speed") == 0) {
			cfg::Forward_Speed = value;
			DynamicVelocity = value;
		}
		else if (strcmp(key, "Sprint_Speed") == 0)
			cfg::Sprint_Speed = value;
		else if (strcmp(key, "Falling_Speed") == 0)
			cfg::Falling_Speed = value;
		else if (strcmp(key, "LiftUp_Speed") == 0)
			cfg::LiftUp_Speed = value;
		else if (strcmp(key, "LiftDown_Speed") == 0)
			cfg::LiftDown_Speed = value;
		else if (strcmp(key, "DynamicSpeedChange") == 0)
			cfg::DynamicSpeedChange = value;

	}
}

extern "C" {
	bool SKSEPlugin_Query(const SKSEInterface * skse, PluginInfo * info) {	// Called by SKSE to learn about this plugin and check that it's safe to load it
		// populate info structure
		info->infoVersion = PluginInfo::kInfoVersion;
		info->name = "Player Flying Physics";
		info->version = 3;

		// store plugin handle so we can identify ourselves later
		g_pluginHandle = skse->GetPluginHandle();

		// ### do not do anything else in this callback
		// ### only fill out PluginInfo and return true/false

		return true;
	}

	bool SKSEPlugin_Load(const SKSEInterface * skse) {	// Called by SKSE to load this plugin
		g_papyrus = (SKSEPapyrusInterface *)skse->QueryInterface(kInterface_Papyrus);

		//Check if the function registration was a success...
		bool btest = g_papyrus->Register(FlightPhysicsPluginNamespace::RegisterFuncs);

		// Read in 
		read_cfg();

		// Detour move and camera state change functions
		orig_move = (move_t)(DetourFunction((byte*)(0xD1DA60), (byte*)(hook_move)));
		orig_change_cam = (change_cam_t)(DetourFunction((byte*)(0x6533D0), (byte*)(hook_change_cam)));

		return true;
	}
}