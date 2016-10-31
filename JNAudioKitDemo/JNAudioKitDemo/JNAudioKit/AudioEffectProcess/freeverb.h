#ifndef FREEVERB_H
#define FREEVERB_H

#include "revmodel.h"
struct RevSettings
{
	int roomsize;
	int damp;
	int wet;
	int dry;
	int width;
	int mode;
};

const RevSettings rs[] = 
{
	//roomsize, damp, wet, dry, width, mode
	{250, 100, 333, 750, 250, 0},  //小房间
//    {1000, 700, 333, 750, 1000, 0},
	{ 500, 250, 333, 750, 500, 0}, //中等房间
	{ 700, 250, 333, 750, 700, 0}, //大房间
	{ 900, 500, 333, 750, 1000, 0},	//大厅
};

class freeverb
{
public:
	freeverb();
	freeverb(RevSettings * rs);
    void setParameter(RevSettings& arry_para, bool b_echo);
	~freeverb();
	static const int scalewet=3;
	void process(int samp_freq, int sf, int nchannels, void *samples0,unsigned int numsamples, bool bCfgChanged);
	void onSeek(void);
	static const int initialroom =int(1000*0.5f);
	static const int initialdamp =int(1000*0.25f);
	static const int initialwet  =int(1000*(1.0f/scalewet));
	static const int initialdry  =int(1000*0.75);
	static const int initialwidth=int(1000*1);
	static const int initialmode =int(1000*0);
private:
	revmodel * m_rev;
	RevSettings * m_rs;
    bool m_bEcho;
};

#endif
