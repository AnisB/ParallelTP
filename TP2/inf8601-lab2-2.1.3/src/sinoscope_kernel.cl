/*
 * bilinear_kernel.cl
 *
 *  Created on: 2011-10-14
 *      Author: francis
 */

#define M_PI 3.1416f

typedef struct sinoscope sinoscope_t;

struct sinoscope {
	unsigned char *buf;
	int width;
	int height;
	int interval;
	int taylor;
	float interval_inv;
	float time;
	float max;
	float phase0;
	float phase1;
	float dx;
	float dy;
};
__global sinoscope_t * sinoscope_data;

struct rgb {
	unsigned char r;
	unsigned char g;
	unsigned char b;
};

__constant struct rgb black = { .r = 0, .g = 0, .b = 0 };
__constant struct rgb white = { .r = 255, .g = 255, .b = 255 };

void value_color(struct rgb *color, float value, int interval, float interval_inv)
{
	#pragma OPENCL EXTENSION cl_khr_byte_addressable_store: enable
	if (isnan(value)) {
		*color = black;
		return;
	}
	struct rgb c;
	int x = (((int)value % interval) * 255) * interval_inv;
	int i = value * interval_inv;
	switch(i) {
	case 0:
		c.r = 0;
		c.g = x;
		c.b = 255;
		break;
	case 1:
		c.r = 0;
		c.g = 255;
		c.b = 255 - x;
		break;
	case 2:
		c.r = x;
		c.g = 255;
		c.b = 0;
		break;
	case 3:
		c.r = 255;
		c.g = 255 - x;
		c.b = 0;
		break;
	case 4:
		c.r = 255;
		c.g = 0;
		c.b = x;
		break;
	default:
		c = white;
		break;
	}
	*color = c;
}

__kernel void sinoscope_kernel(int taylorCL,float phase0,float phase1,int interval,float interval_inv,int width,float time,float dx, float dy, __global float* out)
{
  int x = get_global_id(0);
  int y = get_global_id(1);
  int index, taylorCL;
  float px = dx * y - 2 * M_PI;
  float py = dy * x - 2 * M_PI;
  float val = 0.0f;

  for (taylorCL = 1; taylorCL <= taylor; taylorCL += 2) 
  {
    val += sin(px * taylorCL * phase1 + time) / taylorCL + cos(py * taylorCL * phase0) / taylorCL;
  }

  val = (atan(1.0 * val) - atan(-1.0 * val)) / (M_PI);
  val = (val + 1) * 100;
  value_color(&c, val, interval, interval_inv);
  index = (y * 3) + (x * 3) * width;
  out[index + 0] = c.r;
  out[index + 1] = c.g;
  out[index + 2] = c.b;
}
