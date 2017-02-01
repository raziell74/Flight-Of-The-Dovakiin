#pragma once

#include "vec3.h"

struct actor
{
	struct physics_data
	{
		vec3 velocity()
		{
			const auto container = *(uintptr_t*)((uintptr_t)(this) + 0x298);
			return *(vec3*)(container + 0x40);
		}
		void set_velocity(vec3 vel)
		{
			const auto container = *(uintptr_t*)((uintptr_t)(this) + 0x298);
			*(vec3*)(container + 0x40) = vel;
		}

		vec3 ground_normal()
		{
			return *(vec3*)((uintptr_t)(this) + 0x160);
		}

		void *ground_entity()
		{
			return *(void**)((uintptr_t)(this) + 0x23C);
		}

		float fall_time()
		{
			return *(float*)((uintptr_t)(this) + 0x1E4);
		}
	};

	physics_data *phys_data()
	{
		const auto level1 = *(uintptr_t*)((uintptr_t)(this) + 0x88);
		if(level1 == 0)
			return nullptr;

		const auto level2 = *(uintptr_t*)((uintptr_t)(level1) + 0x4);
		if(level2 == 0)
			return nullptr;

		return *(physics_data**)((uintptr_t)(level2) + 0x15C);
	}

	vec3 position()
	{
		return *(vec3*)((uintptr_t)(this) + 0x34);
	}

	float yaw()
	{
		return *(float*)((uintptr_t)(this) + 0x30);
	}

	static actor *player()
	{
		return *(actor**)(0x1B2E8E4);
	}
};