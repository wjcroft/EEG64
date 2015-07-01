% MYUI Brief description of program.
%       Comments displayed at the command line in response
%       to the help command.

% (Leave a blank line following the help.)

function varargout = GUI_Man(varargin)

%% GLOBAL VARIABLES

global deviceStates;
global totalActiveDevices;
%global deviceDataStruct;
%global deviceData;
global currentDevice;


%% CONSTANTS
    function ret =  WAKEUP; ret = 02; end;
    function ret =  STANDBY; ret = 04; end;
    function ret =  RESET; ret = 06; end;
    function ret =  START; ret = 08; end;
    function ret =  STOP; ret = 10; end;
    function ret =  RDATAC; ret = 16; end;
    function ret =  SDATAC; ret = 17; end;
    function ret =  RDATA; ret = 18; end;

%ASD1299 Register Addresses
%REG_ADDR
    function ret =  ID;            ret = 00; end;
    function ret =  CONFIG1;       ret = 01; end;
    function ret =  CONFIG2;       ret = 02; end;
    function ret =  CONFIG3;       ret = 03; end;
    function ret =  LOFF;          ret = 04; end;
    function ret =  CH1SET;        ret = 05; end;
    function ret =  CH2SET;        ret = 06; end;
    function ret =  CH3SET;        ret = 07; end;
    function ret =  CH4SET;        ret = 08; end;
    function ret =  CH5SET;        ret = 09; end;
    function ret =  CH6SET;        ret = 10; end;
    function ret =  CH7SET;        ret = 11; end;
    function ret =  CH8SET;        ret = 12; end;
    function ret =  BIAS_SENSP;    ret = 13; end;
    function ret =  BIAS_SENSN;    ret = 14; end;
    function ret =  LOFF_SENSP;    ret = 15; end;
    function ret =  LOFF_SENSN;    ret = 16; end;
    function ret =  LOFF_FLIP;     ret = 17; end;
    function ret =  LOFF_STATP;    ret = 18; end;
    function ret =  LOFF_STATN;    ret = 19; end;
    function ret =  GPIO;          ret = 20; end;
    function ret =  MISC1;         ret = 21; end;
    function ret =  MISC2;         ret = 22; end;
    function ret =  CONFIG4;       ret = 23; end;

% NOT NEEDED
%CHAN_ON (0b00000000)
%CHAN_OFF (0b10000000)
%SRB2_CON
%SRB2_DISCON

%GAIN_CODE
    function ret = NEXT_GAIN(currGain)
        ret = currGain + 16;
        if ret > 96; ret = 0; end
    end
    function ret =  GAIN01; ret = 00; end;    %(0b00000000) 0x00
    function ret =  GAIN02; ret = 16; end;    %(0b00010000) 0x10
    function ret =  GAIN04; ret = 32; end;    %(0b00100000) 0x20
    function ret =  GAIN06; ret = 48; end;    %(0b00110000) 0x30
    function ret =  GAIN08; ret = 64; end;    %(0b01000000) 0x40
    function ret =  GAIN12; ret = 80; end;    %(0b01010000) 0x50
    function ret =  GAIN24; ret = 96; end;    %(0b01100000) 0x60 //default

%MUX_CODE
    function ret =  NEXT_MUX(currMux)
        ret = currMux + 1;
        if ret > 7; ret = 0; end
    end
    function ret =  MUX_NORMAL;    ret = 0; end; %default
    function ret =  MUX_SHORTED;   ret = 1; end;
    function ret =  MUX_BIAS_MEAS; ret = 2; end;
    function ret =  MUX_MVDD;      ret = 3; end;
    function ret =  MUX_TEMP;      ret = 4; end;
    function ret =  MUX_TESTSIG;   ret = 5; end;
    function ret =  MUX_BIAS_DRP;  ret = 6; end;
    function ret =  MUX_BIAS_DRN;  ret = 7; end;

%TEST_AMP_CODE (Pg. 41)
    function ret =  TESTSIG_AMP_1X; ret = 0; end; %1 × (VREFP ? VREFN) / 2.4 mV (default)
    function ret =  TESTSIG_AMP_2X; ret = 4; end; %2 × (VREFP ? VREFN) / 2.4 mV

%TEST_FREQ_CODE (Pg. 41)
    function ret =  TESTSIG_PULSE_SLOW;    ret = 0; end %Pulsed at fCLK / 2^21 (default)
    function ret =  TESTSIG_PULSE_FAST;    ret = 1; end %Pulsed at fCLK / 2^20
    function ret =  TESTSIG_DCSIG;         ret = 3; end %Pulsed at DC

%LOFF_THRESH_CODE (Datasheet Pg. 43)

%LOFF_THRESH_CODE_P
    function ret = NEXT_LOFF_THRESH(currThresh)
        ret = currThresh + 32;
        if ret > 224; ret = 0; end
    end
    function ret =  THRESH_95;   ret = 000; end; %(0b00000000) //default
    function ret =  THRESH_92p5; ret = 032; end; %(0b00100000)
    function ret =  THRESH_90;   ret = 064; end; %(0b01000000)
    function ret =  THRESH_87p5; ret = 096; end; %(0b01100000)
    function ret =  THRESH_85;   ret = 128; end; %(0b10000000)
    function ret =  THRESH_80;   ret = 160; end; %(0b10100000)
    function ret =  THRESH_75;   ret = 192; end; %(0b11000000)
    function ret =  THRESH_70;   ret = 224; end; %(0b11100000)

%LOFF_THRESH_CODE_N
    function ret =  THRESH_5;    ret =   0; end; %(0b00000000) //default
    function ret =  THRESH_7p5;  ret =  32; end; %(0b00100000)
    function ret =  THRESH_10;   ret =  64; end; %(0b01000000)
    function ret =  THRESH_12p5; ret =  96; end; %(0b01100000)
    function ret =  THRESH_15;   ret = 128; end; %(0b10000000)
    function ret =  THRESH_20;   ret = 160; end; %(0b10100000)
    function ret =  THRESH_25;   ret = 192; end; %(0b11000000)
    function ret =  THRESH_30;   ret = 224; end; %(0b11100000)

%LOFF_AMP_CODE
    function ret = NEXT_LOFF_AMP(currAmp)
        ret = currAmp + 4;
        if ret > 12; ret = 0; end
    end
    function ret =  LOFF_AMP_6NA;   ret =  0; end; %(0b00000000) //default
    function ret =  LOFF_AMP_24NA;  ret =  4; end; %(0b00000100)
    function ret =  LOFF_AMP_6UA;   ret =  8; end; %(0b00001000)
    function ret =  LOFF_AMP_24UA;  ret = 12; end; %(0b00001100)

%LOFF_FREQ_CODE
    function ret =  NEXT_LOFF_FREQ(currFreq)
        ret = currFreq + 1;
        if ret > 3; ret = 0; end
    end
    function ret =  LOFF_FREQ_DC;       ret = 0; end; %(0b00000000) //default
    function ret =  LOFF_FREQ_7p8HZ;    ret = 1; end; %(0b00000001)
    function ret =  LOFF_FREQ_31p2HZ;   ret = 2; end; %(0b00000010)
    function ret =  LOFF_FREQ_FS_4;     ret = 3; end; %(0b00000011)

%MISC DEFINITIONS
    function ret =  PCHAN;     ret = 0; end;
    function ret =  NCHAN;     ret = 1; end;
    function ret =  BOTHCHAN;  ret = 2; end;

    function ret =  NONINV;   ret = 0; end;
    function ret =  INV;       ret = 1; end;

    function ret =  OFF;   ret = 0; end;
    function ret =  ON;    ret = 1; end;

    function ret =  DISABLE;   ret = 0; end;
    function ret =  ENABLE;    ret = 1; end;

%SERIAL COMMUNICATIONS
    function ret =  PCKT_START;    ret = 160; end; % 0xA0	// prefix for data packet error checking
    function ret =  PCKT_END;      ret = 192; end; %0xC0	// postfix for data packet error checking

    function ret = NEXT_DR(currDR)
        ret = currDR - 1;
        if ret < 0; ret = 6; end
    end
    function ret =  DR_16KSPS; ret = 0; end % (00000000)
    function ret =  DR_8KSPS;  ret = 1; end % (00000001)
    function ret =  DR_4KSPS;  ret = 2; end % (00000010)
    function ret =  DR_2KSPS;  ret = 3; end % (00000011)
    function ret =  DR_1KSPS;  ret = 4; end % (00000100)
    function ret =  DR_500SPS; ret = 5; end % (00000101)
    function ret =  DR_250SPS; ret = 6; end % (00000110) //default
%111 not used


    function ret = CHG_CH_STATE;        ret = 'Q'; end %
    function ret = CHG_CH_GAIN;         ret = 'W'; end %
    function ret = CHG_CH_SRB2;         ret = 'E'; end %
    function ret = CHG_CH_MUX;          ret = 'R'; end %

    function ret = ACT_TEST;            ret = 'T'; end %
    function ret = DEACT_TEST;          ret = 'Y'; end %

    function ret = TEST_SIG_INTERN;     ret = 'U'; end %
    function ret = TEST_SIG_EXTERN;     ret = 'I'; end %

    function ret = ACT_TEST_SHORTED;    ret = 'O'; end %
    function ret = DEACT_TEST_SHORTED;  ret = 'P'; end %

    function ret = CHG_TEST_AMP;        ret = '['; end %
    function ret = CHG_TEST_FREQ;       ret = ']'; end %


    function ret = EN_LOFF_COMP;        ret = 'A'; end %
    function ret = DIS_LOFF_COMP;       ret = 'S'; end %

    function ret = SET_LOFF_THRESH;     ret = 'D'; end %
    function ret = SET_LOFF_CUR_MAG;    ret = 'F'; end %
    function ret = SET_LOFF_FREQ;       ret = 'G'; end %

    function ret = LOFF_DETECT_N;       ret = 'H'; end %
    function ret = LOFF_DETECT_P;       ret = 'J'; end %
    function ret = LOFF_CUR_DIR;        ret = 'K'; end %

    function ret = RUN_BIAS_LOFF_SENSE; ret = 'L'; end %


    function ret = EN_BIAS_BUFF;        ret = 'Z'; end %
    function ret = DIS_BIAS_BUFF;       ret = 'X'; end %

    function ret = EN_REROUTE_BIAS;     ret = 'C'; end %param1 byte "channel"  param2 bit "positive_or_negative_select"
    function ret = DIS_REROUTE_BIAS;    ret = 'V'; end %

    function ret = EN_MEASURE_BIAS;     ret = 'B'; end %param1 byte "channel"
    function ret = DIS_MEASURE_BIAS;    ret = 'N'; end %param1 byte "channel"

    function ret = EN_BIAS_REF_INT;     ret = 'M'; end %
    function ret = DIS_BIAS_REF_INT;    ret = '<'; end %

    function ret = CHG_BIAS_SENS_N;     ret = '<'; end %param1 byte "channel"  param2 bit "state_con_or_discon"
    function ret = CHG_BIAS_SENS_P;     ret = '?'; end %param1 byte "channel"  param2 bit "state_con_or_discon"

    function ret = EN_OSC_OUT;          ret = '!'; end
    function ret = DIS_OSC_OUT;         ret = '@'; end

    function ret = EN_DAISY_CHAIN;      ret = '#'; end
    function ret = DIS_DAISY_CHAIN;     ret = '$'; end

    function ret = EN_INT_REF;          ret = '%'; end
    function ret = DIS_INT_REF;         ret = '^'; end

    function ret = EN_SRB1_CON;         ret = '&'; end
    function ret = DIS_SRB1_CON;        ret = '*'; end

    function ret = EN_CONV_MODE_CONTINUOUS; ret = '('; end
    function ret = DIS_CONV_MODE_CONTINUOUS;ret = ')'; end

    function ret = START_ALL_DATA_ACQU;     ret = '1'; end
    function ret = HALT_ALL_DATA_ACQU;      ret = '2'; end
    function ret = SYNC_CP_TO_MSP;          ret = '3'; end
    function ret = SYNC_MSP_TO_CP;          ret = '4'; end
    function ret = GET_DEV_ID;              ret = '5'; end
    function ret = GET_DEV_ACTIVE;          ret = '6'; end %is device active?
    function ret = RREG;                    ret = '9'; end
    function ret = WREG;                    ret = '0'; end

    function ret = DARK_RED;                ret = [.5 0 0];    end
    function ret = RED;                     ret = [1 0 0];    end

    function ret = YELLOW;                  ret = [1 1 0];    end

    function ret = DARK_GREEN;              ret = [0 .5 0];    end
    function ret = GREEN;                   ret = [0 1 0];    end

    function ret = DARK_BLUE;               ret = [0 0 .5];    end
    function ret = BLUE;                    ret = [0 0 1];    end

    function ret = DARK_ORANGE;             ret = [1 .25 0];         end
    function ret = ORANGE;                  ret = [1 .5 0];         end

    function ret = DARK_PURPLE;             ret = [.4 .0 .6];    end
    function ret = PURPLE;                  ret = [.8 .0 .6];    end
    function ret = GREY;                    ret = [.75 .75 .75];    end


%%  Initialization tasks

%initially set all devices and channels as active

deviceStates = ones(1,8);
totalActiveDevices = 0;
currentDevice = 1;

%CHANNEL SETTINGS
ch1Opt_HB = 'ChannelState';                   chv1 = zeros(1,8);
ch2Opt_HB = 'ChannelGain';                    chv2 = zeros(1,8);
ch3Opt_HB = 'ChannelSRB2Con';                 chv3 = zeros(1,8);
ch4Opt_HB = 'ChannelMUX';                     chv4 = zeros(1,8);
ch5Opt_HB = 'ChannelLoffStatP';               chv5 = zeros(1,8);
ch6Opt_HB = 'ChannelLoffStatN';               chv6 = zeros(1,8);

%CONFIG1
c1 = 'DaisyChainEnableLOW';             cv1 = 0; %daisy-chain enabled
c2 = 'ClockOutputEnable';               cv2 = 0; %clock output disabled
c3 = 'DataRate';                        cv3 = DR_250SPS; %250SPS
c4 = 'PDReferenceBufferLOW';            cv4 = 0; %internal reference buffer disabled
c5 = 'SRB1Connected';                   cv5 = 0; %SRB1 disconnected
c6 = 'EnableSingleShot';                cv6 = 0; %single shot disabled

%TEST SETTINGS
t1 = 'TestSignalsGeneratedInternally';  tv1 = 0; %test sig generated externally
t2 = 'TestSignalAmplitude';             tv2 = TESTSIG_AMP_1X; %1x AMP
t3 = 'TestSignalFrequency';             tv3 = TESTSIG_PULSE_FAST;

%LOFF SETTINGS
l1 = 'PDLOFFComparator';                lv1 = 0; %LOFF Comparator Disabled
l2 = 'LOFFComparatorThreshold';         lv2 = THRESH_95;
l3 = 'LOFFCurrentMagnitude';            lv3 = LOFF_AMP_6NA;
l4 = 'LOFFFrequency';                   lv4 = LOFF_FREQ_DC;

%BIAS SETTINGS
b1 = 'BiasMeasureEnabled';              bv1 = 0; %BIASIN not rerouted to channel
b2 = 'PDInternalBiasRef';               bv2 = 0; %internal bias reference disabled
b3 = 'PDBiasReferenceBuffer';           bv3 = 0; %bias buffer disabled
b4 = 'BiasLOFFSenseEnable';             bv4 = 0; %bias LOFF sense disabled
b5 = 'BiasLOFFStatus';                  bv5 = 0; %bias is connected

%LOFF SENSING
l5 = 'LOFFSenseN';                      lv5 = zeros(1,8); %all channels discon
l6 = 'LOFFSenseP';                      lv6 = zeros(1,8); %all channels discon
l7 = 'LOFFCurrentDirection';            lv7 = zeros(1,8); %AVDD connected to INP, AVSS connected to INN

b6 = 'BiasSenseN';                      bv6 = zeros(1,8); %all channels discon
b7 = 'BiasSenseP';                      bv7 = zeros(1,8); %all channels discon

deviceDataStruct = struct(...
    ch1Opt_HB, chv1, ch2Opt_HB, chv2, ch3Opt_HB, chv3, ch4Opt_HB, chv4, ch5Opt_HB, chv5, ch6Opt_HB, chv6, ...
    t1,  tv1,  t2,  tv2,  t3,  tv3, ...
    l1,  lv1,  l2,  lv2,  l3,  lv3,  l4,  lv4, ...
    b1,  bv1,  b2,  bv2,  b3,  bv3,  b4,  bv4,  b5,  bv5, ...
    l5,  lv5,  l6,  lv6,  l7,  lv7, ...
    b6,  bv6,  b7,  bv7 );
deviceData = [deviceDataStruct, deviceDataStruct, deviceDataStruct, deviceDataStruct, deviceDataStruct, deviceDataStruct, deviceDataStruct, deviceDataStruct];


%%  GUI Initialization tasks
fig = figure( 'Position', [250 250 650 500], 'Units', 'normalized');
tabs = uiextras.TabPanel('Parent', fig, 'TabSize', 120);
%tabs.TabNames = { 'View', 'Channel Options', 'Lead-Off Detection', 'Bias Configuration', 'Device Configuration' };

%% View Tab

view_T = uiextras.VBox('Parent', tabs);

graphOpts_HB = uiextras.HBox('Parent', view_T, 'Padding', 10);
eegGraph_HB = uiextras.HBox('Parent', view_T);
boardsIndic_HB = uiextras.HBox('Parent', view_T, 'Padding', 10);
electrodeIndic1_HB = uiextras.HBox('Parent', view_T, 'Padding', 10);
electrodeIndic2_HB = uiextras.HBox('Parent', view_T, 'Padding', 10);
colorCode1_HB = uiextras.HBox('Parent', view_T);
colorCode2_HB = uiextras.HBox('Parent', view_T);

%Graphing Options
uicontrol('Parent', graphOpts_HB, 'Callback', {@graphOpts1_CB}, 'String', 'Traditional');
uicontrol('Parent', graphOpts_HB, 'Callback', {@graphOpts2_CB}, 'String', 'Spectrogram');
uicontrol('Parent', graphOpts_HB, 'Callback', {@graphOpts3_CB}, 'String', 'Topographic');
uicontrol('Parent', graphOpts_HB, 'Callback', {@graphOpts4_CB}, 'String', '???');
%graphOpts.Sizes = [100 100 100 100];


axes('Parent', eegGraph_HB);
%contour(peaks(20));


% Electrode status Indicators
for i = 1:64
    if i < 33
        uicontrol('Parent', electrodeIndic1_HB, 'Tag', strcat('EI', num2str(i)), 'String', num2str(i), 'Background', 'g');
    else
        uicontrol('Parent', electrodeIndic2_HB, 'Tag', strcat('EI', num2str(i)), 'String', num2str(i), 'Background', 'g');
    end
end


%
%"Color Key" at bottom
% - need to add label and center
uicontrol('Parent', colorCode1_HB, 'BackgroundColor', GREEN);
uicontrol('Parent', colorCode1_HB, 'style', 'text', 'FontUnits', 'points', 'HorizontalAlignment', 'left', 'String', 'Normal');



uicontrol('Parent', colorCode1_HB, 'BackgroundColor', DARK_RED);
uicontrol('Parent', colorCode1_HB, 'style', 'text', 'FontUnits', 'points', 'HorizontalAlignment', 'left', 'String', 'Railed');



uicontrol('Parent', colorCode1_HB, 'BackgroundColor', DARK_PURPLE);
uicontrol('Parent', colorCode1_HB, 'style', 'text', 'FontUnits', 'points', 'HorizontalAlignment', 'left', 'String', 'Test Signal');

uicontrol('Parent', colorCode1_HB, 'BackgroundColor', DARK_BLUE);
uicontrol('Parent', colorCode1_HB, 'style', 'text', 'FontUnits', 'points', 'HorizontalAlignment', 'left', 'String', 'Bias Drive');

uicontrol('Parent', colorCode1_HB, 'BackgroundColor', DARK_ORANGE);
uicontrol('Parent', colorCode1_HB, 'style', 'text', 'FontUnits', 'points', 'HorizontalAlignment', 'left', 'String', 'Temperature Sensor');



uicontrol('Parent', colorCode2_HB, 'BackgroundColor', GREY);
uicontrol('Parent', colorCode2_HB, 'style', 'text', 'FontUnits', 'points', 'HorizontalAlignment', 'left', 'String', 'Powered Down');

uicontrol('Parent', colorCode2_HB, 'BackgroundColor', RED);
uicontrol('Parent', colorCode2_HB, 'style', 'text', 'FontUnits', 'points', 'HorizontalAlignment', 'left', 'String', 'Lead-Off');


uicontrol('Parent', colorCode2_HB, 'BackgroundColor', PURPLE);
uicontrol('Parent', colorCode2_HB, 'style', 'text', 'FontUnits', 'points', 'HorizontalAlignment', 'left', 'String', 'Shorted');

uicontrol('Parent', colorCode2_HB, 'BackgroundColor', BLUE);
uicontrol('Parent', colorCode2_HB, 'style', 'text', 'FontUnits', 'points', 'HorizontalAlignment', 'left', 'String', 'Bias Measure');

uicontrol('Parent', colorCode2_HB, 'BackgroundColor', ORANGE);
uicontrol('Parent', colorCode2_HB, 'style', 'text', 'FontUnits', 'points', 'HorizontalAlignment', 'left', 'String', 'Supply Measure');

% top 4 buttons, graph, "Boards:", electrode indicators (x2), color key (x2)
set(view_T, 'Sizes', [50 -8 -0.5 -1 -1 -0.25 -0.25]);


%% Channel Options Tab

chOpt_T = uiextras.VBox('Parent', tabs, 'Padding', 10);

devSel_HB1 = uiextras.HBox('Parent', chOpt_T, 'Padding', 5);%, 'BackgroundColor', 'y');
copyConfig_HB1 = uiextras.HBox('Parent', chOpt_T, 'Padding', 1);
chOptGuide_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 1);
ch1Opt_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 1);%, 'BackgroundColor', 'b');
ch2Opt_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 1);%, 'BackgroundColor', 'y');
ch3Opt_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 1);%, 'BackgroundColor', 'b');
ch4Opt_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 1);%, 'BackgroundColor', 'y');
ch5Opt_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 1);%, 'BackgroundColor', 'b');
ch6Opt_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 1);%, 'BackgroundColor', 'y');
ch7Opt_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 1);%, 'BackgroundColor', 'b');
ch8Opt_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 1);%, 'BackgroundColor', 'y');
testSigTxt_HB1 = uiextras.HBox('Parent', chOpt_T, 'Padding', 10);%, 'BackgroundColor', 'b');
testSigButRow1_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 10);%, 'BackgroundColor', 'y');
testSigButRow2_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 10);%, 'BackgroundColor', 'b');
testSigButRow3_HB = uiextras.HBox('Parent', chOpt_T, 'Padding', 10);%, 'BackgroundColor', 'y');
testSigTxt_HB2 = uiextras.HBox('Parent', chOpt_T, 'Padding', 10);%, 'BackgroundColor', 'b');

chOpt_T.Sizes = [-.6 -.8 -.8 -.8 -.8 -.8 -.8 -.8 -.8 -.8 -.8 -.6 -.8 -.8 -.8 -.4];

%device select: universal for all 4 config pages
uicontrol('Parent', devSel_HB1, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .75, 'HorizontalAlignment', 'left', 'String', 'Device Select:');
for i = 1:8
    uicontrol('Parent', devSel_HB1, 'Callback', @selectDevice_CB, 'style', 'togglebutton', 'String', num2str(i));
end
devSel_HB1.Sizes = [-2 -1 -1 -1 -1 -1 -1 -1 -1];

%Copy configuration: universal for all pages
uiextras.HBox('Parent', copyConfig_HB1);
uicontrol('Parent', copyConfig_HB1, 'String', '<html><center>Copy configuration<br/>to other device...');
copyConfig_HB1.Sizes = [-.75 -.25]

% CH OPTIONS GUIDE
uicontrol('Parent', chOptGuide_HB, 'style', 'text', 'FontWeight', 'bold', 'FontUnits', 'normalized', 'String', {'','', 'CH#'});
uicontrol('Parent', chOptGuide_HB, 'style', 'text', 'FontWeight', 'bold', 'FontUnits', 'normalized', 'String', {'','', 'Enabled'});
uicontrol('Parent', chOptGuide_HB, 'style', 'text', 'FontWeight', 'bold', 'FontUnits', 'normalized', 'String', {'','', 'Gain Setting'});
uicontrol('Parent', chOptGuide_HB, 'style', 'text', 'FontWeight', 'bold', 'FontUnits', 'normalized', 'String', {'','', 'SRB2 Connection'});
uicontrol('Parent', chOptGuide_HB, 'style', 'text', 'FontWeight', 'bold', 'FontUnits', 'normalized', 'String', {'','', 'Channel Status'});
uicontrol('Parent', chOptGuide_HB, 'style', 'text', 'FontWeight', 'bold', 'FontUnits', 'normalized', 'String', {'','', 'Channel Function'});

%Set up channel configuration buttons
chan = 1;
chParentHandles = [ch1Opt_HB ch2Opt_HB ch3Opt_HB ch4Opt_HB ch5Opt_HB ch6Opt_HB ch7Opt_HB ch8Opt_HB];
muxHandles = zeros(1,8);
for parent = chParentHandles
    uicontrol('Parent', parent, 'Tag', strcat('CH', num2str(chan), 'OPT_TXT' ), 'style', 'text',            'FontUnits', 'normalized', 'String', {'', strcat('CH', num2str(chan))});
    uicontrol('Parent', parent, 'Tag', strcat('CH', num2str(chan), 'OPT_PWDN'), 'style', 'togglebutton',    'FontUnits', 'normalized', 'Callback', {@enableChannel_CB, chan}, 'String', 'ON');
    uicontrol('Parent', parent, 'Tag', strcat('CH', num2str(chan), 'OPT_GAIN'), 'style', 'pushbutton',      'FontUnits', 'normalized', 'Callback', {@chgChannelGain_CB, chan}, 'String', 'GAIN: 24');
    uicontrol('Parent', parent, 'Tag', strcat('CH', num2str(chan), 'OPT_SRB2'), 'style', 'togglebutton',    'FontUnits', 'normalized', 'Callback', {@chgChannelSRB2_CB, chan}, 'String', 'SRB2: DISCON');
    uicontrol('Parent', parent, 'Tag', strcat('CH', num2str(chan), 'OPT_STAT'), 'style', 'pushbutton',      'FontUnits', 'normalized', 'ENABLE', 'inactive', 'String', 'NORMAL'); %remains inactive; not a button
    uicontrol('Parent', parent, 'Tag', strcat('CH', num2str(chan), 'OPT_MUX' ), 'style', 'popupmenu',       'FontUnits', 'normalized', 'Callback', {@chgChannelMUX_CB, chan}, 'FontSize', .3, 'ENABLE', 'on',...
        'String', {'000 - Normal', '001 - Shorted', '010 - Bias Measure', '011 - Supply Measure', '100 - Temperature Sensor', '101 - Test Signal', '110 - Bias Drive (P)', '111 - Bias Drive (N)'}); %leave off until user presses "manual config" on config page
    chan = chan + 1;
end

%Set channel conig button sizes
chOptGuide_HB.Sizes = [-.5 -.6 -.8 -1.4 -.7 -2];
ch1Opt_HB.Sizes = [-.5 -.6 -.8 -1.4 -.7 -2];
ch2Opt_HB.Sizes = [-.5 -.6 -.8 -1.4 -.7 -2];
ch3Opt_HB.Sizes = [-.5 -.6 -.8 -1.4 -.7 -2];
ch4Opt_HB.Sizes = [-.5 -.6 -.8 -1.4 -.7 -2];
ch5Opt_HB.Sizes = [-.5 -.6 -.8 -1.4 -.7 -2];
ch6Opt_HB.Sizes = [-.5 -.6 -.8 -1.4 -.7 -2];
ch7Opt_HB.Sizes = [-.5 -.6 -.8 -1.4 -.7 -2];
ch8Opt_HB.Sizes = [-.5 -.6 -.8 -1.4 -.7 -2];

%Set all test signal buttons
uicontrol('Parent', testSigTxt_HB1, 'style', 'text', 'FontUnits', 'normalized', 'HorizontalAlignment', 'left', 'String', 'TEST SIGNALS');
uicontrol('Parent', testSigButRow1_HB, 'Callback', {@disableAllTestSignals_CB}, 'style', 'pushbutton', 'FontUnits', 'normalized', 'String', 'DISABLE ALL TEST SIGNALS / SHORTS');
uicontrol('Parent', testSigButRow1_HB, 'visible', 'off');
uicontrol('Parent', testSigButRow1_HB, 'visible', 'off');
uicontrol('Parent', testSigButRow2_HB, 'Callback', {@enableTestSignals_CB}, 'FontUnits', 'normalized', 'String', 'ENABLE TEST SIGNALS');
uicontrol('Parent', testSigButRow2_HB, 'Callback', {@chgTestAmplitude_CB}, 'FontUnits', 'normalized', 'String', 'TEST SIGNAL AMPLITUDE: 2X');
uicontrol('Parent', testSigButRow2_HB, 'Callback', {@chgTestFrequency_CB}, 'FontUnits', 'normalized', 'String', 'TEST SIGNAL FREQUENCY: DC');
uicontrol('Parent', testSigButRow3_HB, 'Callback', {@shortAllChannels_CB}, 'FontUnits', 'normalized', 'String', 'SHORT ALL CHANNELS');
uicontrol('Parent', testSigButRow3_HB, 'visible', 'off');
uicontrol('Parent', testSigButRow3_HB, 'visible', 'off');
uicontrol('Parent', testSigTxt_HB2, 'style', 'text', 'FontUnits', 'normalized', 'String', 'Test Signals: Disabled'); %when enabled... 'Test Signals: Enabled, 2X Amplitude, Frequency at DC

%% LOFF TAB

loff_T = uiextras.VBox('Parent', tabs, 'Padding', 10);

devSel_HB2 =        uiextras.HBox('Parent', loff_T, 'Padding', 5);%, 'BackgroundColor', 'y');
copyConfig_HB2 =    uiextras.HBox('Parent', loff_T, 'Padding', 1);
loffEn_HB =         uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');
                    uiextras.HBox('Parent', loff_T);
loffConfig_HB1 =    uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');
loffConfig_HB2 =    uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');
loffSensPTxt_HB =   uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');
loffSensP_HB =      uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');
loffSensNTxt_HB =   uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');
loffSensN_HB =      uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');
loffFlipTxt_HB =    uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');
loffFlip_HB =       uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');
loffStat_HB1 =      uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');
loffStat_HB2 =      uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');

%LOFF Status Text
uiextras.HBox('Parent', loffStat_HB1);
loffStatTxtP_HB = uiextras.HBox('Parent', loffStat_HB1);
uiextras.HBox('Parent', loffStat_HB1);
loffStatTxtN_HB = uiextras.HBox('Parent', loffStat_HB1);
uiextras.HBox('Parent', loffStat_HB1);

%LOFF Status Indicators
uiextras.HBox('Parent', loffStat_HB2);
loffStatP_HB = uiextras.HBox('Parent', loffStat_HB2, 'Padding', 1);
uiextras.HBox('Parent', loffStat_HB2);
loffStatN_HB = uiextras.HBox('Parent', loffStat_HB2, 'Padding', 1);
uiextras.HBox('Parent', loffStat_HB2);

uiextras.HBox('Parent', loff_T);
loffBias_HB = uiextras.HBox('Parent', loff_T, 'Padding', 1);%, 'BackgroundColor', 'b');
loffBiasWarning_HB = uiextras.HBox('Parent', loff_T, 'Padding', 1);



%device select: universal for all 4 config pages
uicontrol('Parent', devSel_HB2, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .75, 'HorizontalAlignment', 'left', 'String', 'Device Select:');
for i = 1:8
    uicontrol('Parent', devSel_HB2, 'style', 'pushbutton', 'String', num2str(i));
end
devSel_HB2.Sizes = [-2 -1 -1 -1 -1 -1 -1 -1 -1];

%Copy config - universal
uicontrol('Parent', copyConfig_HB2, 'visible', 'off');
uicontrol('Parent', copyConfig_HB2, 'String', '<html><center>Copy configuration<br/>to other device...');
copyConfig_HB2.Sizes = [-.75 -.25]

%LOFF Enable Comparator (Turn on/off LOFF detect)
uicontrol('Parent', loffEn_HB, 'Callback', {@enableLoff_CB}, 'String', 'LOFF Sensing: Enabled');
uicontrol('Parent', loffEn_HB, 'visible', 'off');

%LOFF Comparator Theshold, Amplitude, Frequency
uicontrol('Parent', loffConfig_HB1, 'Callback', {@chgLoffThreshold_CB}, 'String', '<html><center>LOFF Comparator<br/>Positive Threshold: 95%');
uicontrol('Parent', loffConfig_HB1, 'Callback', {@chgLoffThreshold_CB}, 'String', '<html><center>LOFF Comparator<br/>Negative Threshold: 5%');
uicontrol('Parent', loffConfig_HB2, 'Callback', {@chgLoffAmplitude_CB}, 'String', '<html><center>LOFF Current<br/>Magnitude: 6nA');
uicontrol('Parent', loffConfig_HB2, 'Callback', {@chgLoffFrequency_CB}, 'String', 'LOFF Frequency: DC');

%LOFF Sense, Current Direction, and Titles
uicontrol('Parent', loffSensPTxt_HB, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .25, 'HorizontalAlignment', 'left', 'String', {'', '', 'LOFF Detection Enable, Positive Electrodes'});
uicontrol('Parent', loffSensNTxt_HB, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .25, 'HorizontalAlignment', 'left', 'String', {'', '', 'LOFF Detection Enable, Negative Electrodes'});
uicontrol('Parent', loffFlipTxt_HB,  'style', 'text', 'FontUnits', 'normalized', 'FontSize', .25, 'HorizontalAlignment', 'left', 'String', {'', '', 'LOFF Current Direction (Inverting or Non-inverting)'});
uicontrol('Parent', loffStatTxtP_HB, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .25, 'HorizontalAlignment', 'center', 'String', {'', '', 'LOFF Status, Positive Electrodes'});
uicontrol('Parent', loffStatTxtN_HB, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .25, 'HorizontalAlignment', 'center', 'String', {'', '', 'LOFF Status, Negative Electrodes'});

for i = 1:8
    uicontrol('Parent', loffSensP_HB, 'style', 'togglebutton', 'Callback', {@chgLoffSenseP_CB, i}, 'String', strcat('CH', num2str(i), ': DIS'));   %LOFF Sense P Buttons
    uicontrol('Parent', loffSensN_HB, 'style', 'togglebutton', 'Callback', {@chgLoffSenseN_CB, i}, 'String', strcat('CH', num2str(i), ': DIS'));   %LOFF Sense N Buttons
    uicontrol('Parent', loffFlip_HB,  'style', 'togglebutton', 'Callback', {@chgLoffCurrentDirection_CB, i}, 'String', strcat('CH', num2str(i), ': NON-INV'));%LOFF Current Invert Buttons
    uicontrol('Parent', loffStatP_HB, 'style', 'pushbutton', 'ENABLE', 'inactive', 'String', strcat('CON', num2str(i), ': LOFF'));   %LOFF Status P Indicators
    uicontrol('Parent', loffStatN_HB, 'style', 'pushbutton', 'ENABLE', 'inactive', 'String', strcat('CON', num2str(i), ': LOFF'));
end

%Run bias LOFF sense
uicontrol('Parent', loffBias_HB,  'Callback', {@runBiasLoffSense_CB}, 'String', 'Run Bias LOFF Sense');
uiextras.HBox('Parent', loffBias_HB);
uicontrol('Parent', loffBias_HB, 'ENABLE', 'inactive', 'String', 'Bias LOFF Status: Connected');
uicontrol('Parent', loffBiasWarning_HB, 'style', 'text', 'String', {'WARNING! Running bias electrode detection will momentarily', 'disable data aquisition and the bias drive.'});
uiextras.HBox('Parent', loffBiasWarning_HB);
uiextras.HBox('Parent', loffBiasWarning_HB);

loffStat_HB1.Sizes = [-.25 -1 -.25 -1 -.25];
loffStat_HB2.Sizes = [-.25 -1 -.25 -1 -.25];
loffBias_HB.Sizes = [-1 -.25 -1];

%% BIAS TAB

bias_T = uiextras.VBox('Parent', tabs, 'Padding', 10);

devSel_HB3 =        uiextras.HBox('Parent', bias_T, 'Padding', 5);%, 'BackgroundColor', 'y');
copyConfig_HB3 =    uiextras.HBox('Parent', bias_T, 'Padding', 1);
biasEn_HB =         uiextras.HBox('Parent', bias_T, 'Padding', 1);%, 'BackgroundColor', 'b');
                    uiextras.HBox('Parent', bias_T);

rerouteBias_HB =    uiextras.HBox('Parent', bias_T, 'Padding', 1);
measureBias_HB =    uiextras.HBox('Parent', bias_T, 'Padding', 1);
                    uiextras.HBox('Parent', bias_T);

biasRef_HB =        uiextras.HBox('Parent', bias_T, 'Padding', 1);
biasBuf_HB =        uiextras.HBox('Parent', bias_T, 'Padding', 1);
biasLoffStat_HB =   uiextras.HBox('Parent', bias_T, 'Padding', 1);
                    uiextras.HBox('Parent', bias_T);

biasSensNTxt_HB =   uiextras.HBox('Parent', bias_T, 'Padding', 1);
biasSensN_HB =      uiextras.HBox('Parent', bias_T, 'Padding', 1);
                    uiextras.HBox('Parent', bias_T);
biasSensPTxt_HB =   uiextras.HBox('Parent', bias_T, 'Padding', 1);
biasSensP_HB =      uiextras.HBox('Parent', bias_T, 'Padding', 1);


%Device select - universal
uicontrol('Parent', devSel_HB3, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .75, 'HorizontalAlignment', 'left', 'String', 'Device Select:');
for i = 1:8
    uicontrol('Parent', devSel_HB3, 'style', 'pushbutton', 'String', num2str(i));
end
devSel_HB3.Sizes = [-2 -1 -1 -1 -1 -1 -1 -1 -1];

%Copy Configuration - universal
uicontrol('Parent', copyConfig_HB3, 'visible', 'off');
uicontrol('Parent', copyConfig_HB3, 'String', '<html><center>Copy configuration<br/>to other device...');
copyConfig_HB3.Sizes = [-.75 -.25];

%Bias enable / disable
uicontrol('Parent', biasEn_HB, 'Callback', {@enableBias_CB}, 'String', 'Bias: Enabled');
uicontrol('Parent', biasEn_HB, 'visible', 'off');

%Reroute bias
uicontrol('Parent', rerouteBias_HB, 'Callback', {@rerouteBias_CB}, 'String', 'Reroute bias signal: enabled');
uicontrol('Parent', rerouteBias_HB, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .55, 'HorizontalAlignment', 'right', 'String', 'Reroute bias signal to CH: ');
uicontrol('Parent', rerouteBias_HB, 'Tag', 'CH' , 'Callback', {@chgRerouteBiasChannel_CB}, 'String', '8');
uicontrol('Parent', rerouteBias_HB, 'Tag', 'POL', 'Callback', {@chgRerouteBiasPolarity_CB}, 'String', 'N');

%Measure bias
uicontrol('Parent', measureBias_HB, 'Callback', {@measureBias_CB}, 'String', 'Measure bias signal: enabled');
uicontrol('Parent', measureBias_HB, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .55, 'HorizontalAlignment', 'right', 'String', 'Measure bias signal on CH: ');
uicontrol('Parent', measureBias_HB, 'Callback', {@chgMeasureBiasChannel_CB}, 'String', '8');
uiextras.VBox('Parent', measureBias_HB);

%Bias reference source
uicontrol('Parent', biasRef_HB, 'Callback', {@chgBiasReferenceSource_CB}, 'String', 'Bias Reference: internal');
uiextras.VBox('Parent', biasRef_HB);

%Bias buffer enable / disable
uicontrol('Parent', biasBuf_HB, 'Callback', {@enableBiasBuffer_CB}, 'String', 'Internal bias buffer: disabled');
uiextras.VBox('Parent', biasBuf_HB);

%Bias electrode LOFF status
uiextras.VBox('Parent', biasLoffStat_HB);
uicontrol('Parent', biasLoffStat_HB, 'enable', 'inactive', 'Background', GREEN, 'String', 'Bias LOFF Status: Connected');

%Bias sense P/N enable / disable
uicontrol('Parent', biasSensNTxt_HB, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .55, 'HorizontalAlignment', 'left', 'String', 'Bias Sense Negative Side: Enable / Disable');
uicontrol('Parent', biasSensPTxt_HB, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .55, 'HorizontalAlignment', 'left', 'String', 'Bias Sense Positive Side: Enable / Disable');
for i = 1:8
    uicontrol('Parent', biasSensN_HB, 'style', 'togglebutton', 'Callback', {@chgBiasSenseP_CB, i}, 'String', strcat('CH', num2str(i), ': DIS'));
    uicontrol('Parent', biasSensP_HB, 'style', 'togglebutton', 'Callback', {@chgBiasSenseN_CB, i}, 'String', strcat('CH', num2str(i), ': DIS'));
end

rerouteBias_HB.Sizes = [-.3 -.4 -.1 -.1];
measureBias_HB.Sizes = [-.3 -.4 -.1 -.1];

%% DEVICE CONFIG

device_T =      uiextras.VBox('Parent', tabs, 'Padding', 10);
devSel_HB4 =    uiextras.HBox('Parent', device_T, 'Padding', 1);%, 'BackgroundColor', 'y');
                uiextras.HBox('Parent', device_T);
dev_VB =        uiextras.HBox('Parent', device_T, 'Padding', 1);
device_T.Sizes = [-.6 -.2 -9.6];
dev_HB_L =      uiextras.VBox('Parent', dev_VB, 'Padding', 10);
dev_HB_R =      uiextras.VBox('Parent', dev_VB, 'Padding', 10);

%BOX 1 - LEFT BOX
copyConfig_HB4 =        uiextras.HBox('Parent', dev_HB_L, 'Padding', 1);
                        uiextras.HBox('Parent', dev_HB_L);
oscEn_HB =              uiextras.HBox('Parent', dev_HB_L, 'Padding', 1);
daisyEn_HB =            uiextras.HBox('Parent', dev_HB_L, 'Padding', 1);
intRefEn_HB =           uiextras.HBox('Parent', dev_HB_L, 'Padding', 1);
srb1En_HB =             uiextras.HBox('Parent', dev_HB_L, 'Padding', 1);
conversionMode_HB =     uiextras.HBox('Parent', dev_HB_L, 'Padding', 1);
                        uiextras.HBox('Parent', dev_HB_L);
saveGlobalConfig_HB =   uiextras.HBox('Parent', dev_HB_L, 'Padding', 1);
loadGlobalConfig_HB =   uiextras.HBox('Parent', dev_HB_L, 'Padding', 1);
saveDeviceConfig_HB =   uiextras.HBox('Parent', dev_HB_L, 'Padding', 1);
loadDeviceConfig_HB =   uiextras.HBox('Parent', dev_HB_L, 'Padding', 1);

%BOX 2 - RIGHT BOX
devConfigSelectTxt_HB =     uiextras.HBox('Parent', dev_HB_R, 'Padding', 10);
masterConfigSelect_HB =     uiextras.HBox('Parent', dev_HB_R, 'Padding', 1);
slaveConfigSelect_HB =      uiextras.HBox('Parent', dev_HB_R, 'Padding', 1);
manualConfigSelect_HB =     uiextras.HBox('Parent', dev_HB_R, 'Padding', 1);
manualConfigWarning_HB1 =   uiextras.HBox('Parent', dev_HB_R);
manualConfigWarning_HB2 =   uiextras.HBox('Parent', dev_HB_R);
                            uiextras.HBox('Parent', dev_HB_R);

%Device Select - universal
uicontrol('Parent', devSel_HB4, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', .75, 'HorizontalAlignment', 'left', 'String', 'Device Select:');
for i = 1:8
    uicontrol('Parent', devSel_HB4, 'style', 'pushbutton', 'String', num2str(i));
end
devSel_HB4.Sizes = [-2 -1 -1 -1 -1 -1 -1 -1 -1];

%Copy configuration - universal
uiextras.HBox('Parent', copyConfig_HB4);
uicontrol('Parent', copyConfig_HB4, 'String', '<html><center>Copy configuration<br/>to other device...');
uiextras.HBox('Parent', copyConfig_HB4);
copyConfig_HB4.Sizes = [-1 -2 -1];

%BUTTONS - BOX1
uicontrol('Parent', oscEn_HB,           'style', 'togglebutton', 'Callback', {@enableOscOut_CB}, 'String', 'Device Oscillator Output: Enabled');
uicontrol('Parent', daisyEn_HB,         'style', 'togglebutton', 'Callback', {@enableDaisyChain_CB}, 'String', 'Daisy-Chain: Disabled');
uicontrol('Parent', intRefEn_HB,        'style', 'togglebutton', 'Callback', {@enableInternalReference_CB}, 'String', 'Internal Reference Buffer: Enabled');
uicontrol('Parent', srb1En_HB,          'style', 'togglebutton', 'Callback', {@enableSRB1Connection_CB}, 'String', 'SRB1 Connection: Closed');
uicontrol('Parent', conversionMode_HB,  'style', 'pushbutton',   'Callback', {@chgConversionMode_CB}, 'String', 'Conversation Mode: Continuous'); %Continuous / Single-shot

uicontrol('Parent', saveGlobalConfig_HB,  'Callback', {@saveGlobalConfig_CB}, 'String', 'Save all configuration options');
uicontrol('Parent', loadGlobalConfig_HB,  'Callback', {@loadGlobalConfig_CB}, 'String', 'Load all configuration options');
uicontrol('Parent', saveDeviceConfig_HB,  'Callback', {@saveDeviceConfig_CB}, 'String', 'Save single device configuration');
uicontrol('Parent', loadDeviceConfig_HB,  'Callback', {@loadDeviceConfig_CB}, 'String', 'Load single device configuration');

%BUTTONS - BOX2
uicontrol('Parent', devConfigSelectTxt_HB,   'style', 'text', 'FontUnits', 'normalized', 'FontSize', .45, 'HorizontalAlignment', 'left', 'String', 'Device Configuration');
uicontrol('Parent', masterConfigSelect_HB,   'Callback', {@loadMasterDeviceConfig_CB}, 'String', 'Master');
uicontrol('Parent', slaveConfigSelect_HB,    'Callback', {@loadSlaveDeviceConfig_CB}, 'String', 'Slave');
uicontrol('Parent', manualConfigSelect_HB,   'Callback', {@loadManualDeviceConfig_CB}, 'String', 'Manual', 'Background', GREY);
uicontrol('Parent', manualConfigWarning_HB1, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', 1, 'String', 'WARNING! Advanced settings!');
uicontrol('Parent', manualConfigWarning_HB2, 'style', 'text', 'FontUnits', 'normalized', 'FontSize', 1, 'String', 'Only use if you absolutely know what you are doing!');

dev_HB_R.Sizes = [-.5 -1 -1 -.5 -.1 -.1 -1];

set(tabs, 'TabNames', {'Overview' 'Channel Options' 'Lead-Off Configuration' 'Bias Configuration' 'Device Configuration'});




%  Construct the components

%%  Initialization tasks

cmd_header_packet   = uint8(36);  %0x24
ack_header_packet   = uint8(70);  %0x46
data_header_packet  = uint8(104); %0x68
ack_ok              = uint8(161); %0xA1
ack_bad             = uint8(186); %0xBA

chksum_ack_ok       = uint8(11);    %0x0B
ack_bad_chksm       = uint8(186);  %0xBA

% SERIAL OUTPUT
serialComm = serial('/dev/tty.usbmodem00000001');
serialComm.BaudRate = 115200;
fopen(serialComm);

% OUTPUT FILE
now = clock;
outfile_name = strcat( ...
    '~/EEG64Session_', ...
    num2str(now(3), '%02i'), '-', ...
    num2str(now(2), '%02i'), '-', ...
    num2str(now(1), '%04i'), '_', ...
    num2str(now(4), '%02i'), '-', ...
    num2str(now(5), '%02i'), '-', ...
    num2str(round(now(6)), '%02i'), '.ses')

outfile = fopen(outfile_name, 'w+');





% EXAMPLE
% calibrate (or load) a model
%    mydata = io_loadset('data:/projects/attention/mason.bdf');
%    [loss,model] = bci_train({'data',mydata, 'approach',myapproach});

% create a new online stream
%    onl_newstream('mystream','srate',200,'chanlocs',{'C3','Cz','C4'});
% create a new predictor from a model
%    onl_newpredictor('mypredictor',model);

%    while 1
% obtain a new block of data from some acquisition system
%        datachunk = get_new_samples();
% feed the block into the online stream
%        onl_append('mystream',datachunk);
% obtain predictions
%        outputs = onl_predict('mypredictor');
% display them
%        bar(outputs); drawnow; pause(0.1);
%    end

%        onl_append(Name, Chunk, Markers, Timestamp)
% appends raw block of data (#samples x #channels)



%check how many devices are active
for i = 1:8
    if sendCommand(GET_DEV_ACTIVE, i, 0, 0) == 0
        deviceStates(i) = 0;
        deviceData(i) = deviceDataStruct; %all fields set to 0
    else
        syncRegisters(0, 0, i);
    end
end

dataRate = 0;
numberOfDevices = 0;

infoByte = 0;
statRegN = 0;
statRegP = 0;

while 1
    curr_sample = 0;
    sample_block = zeros(50, totalActiveDevices*8);
    sendCommand(START_TRANS, 0, 0, 0);
    for i = 0:48
           while fread(serialComm) ~= DATA_HEADER_PACKET end
           infoByte = fread(serialComm);
           sampleNumber = fread(serialComm, 1, uint32);
           numberOfDevices = bitshift(infoByte, -3);
           for nDev = 1:numberOfDevices
               for nChan = 0:7
                   sample_block(i, nChan + nDev*8) = fread(serialComm, 1, int32);
               end
           end
    end
    
    while fread(serialComm) ~= DATA_HEADER_PACKET end
           infoByte = fread(serialComm);
           infoByte
           sampleNumber = fread(serialComm, 1, uint32);
           sampleNumber
           numberOfDevices = bitshift(infoByte, -3);
           numberOfDevices
           for nDev = 1:numberOfDevices
               for nChan = 0:7
                   sample_block(i, nChan + nDev*8) = fread(serialComm, 1, int32);
               end
               sample_block(i, i)
           end
    
end
%%  Callbacks for MYUI


%%  MISC FUNCTIONS


devSelHandleArray = [devSel_HB1 devSel_HB2 devSel_HB3 devSel_HB4]
function selectDevice_CB(hObject, eventdata)
    get(hObject, 'String')
    for devSelHandle = devSelHandleArray
        set(findobj('Parent', devSelHandle, '-and', 'String', num2str(currentDevice)), 'Value', 0);
        set(findobj('Parent', devSelHandle, '-and', 'String', get(hObject, 'String'), 'Value', 1));
        findobj('Parent', devSelHandle, '-and', 'String', get(hObject, 'String'), 'Value', 1)
        drawnow
    end
    currentDevice = str2num(get(hObject, 'String'));
    currentDevice
end

function copyPageConfig_CB(hObject, eventdata, chNum)
end


function syncRegisters(hObject, eventdata, channelDataVar)

end

function commandReturn = sendCommand(cmdByte, devNum, param1, param2, param3)
       fwrite(serialComm, cmd_header_packet);
       fwrite(serialComm, uint8(cmdByte));
       fwrite(serialComm, uint8(deviceNum));
       fwrite(serialComm, uint8(param1));
       fwrite(serialComm, uint8(param2));
       fwrite(serialComm, uint8(param3));
       fwrite(serialComm, uint8(bitxor(start_packet, bitxor(cmdByte, bitxor(deviceNum, bitxor(param1, bitxor(param2, param3 ) ) ) ) ) ));
       serial.flush();
       fread(serialComm); %ack_header
       resp = fread(serialComm); 
       if resp == GOOD_CHECKSUM
           fread(serialComm)
       else
           sendCommand(cmdByte, devNum, param1, param2, param3);
       end
    commandReturn = 0;
end

%%  PAGE 1 - GRAPHS
function graphOpts1_CB(hObject, eventdata)
t = linspace(0,2,1024);
sig = rand(32,1024);

% calculate shift
mi = min(sig,[],2);
ma = max(sig,[],2);
shift = cumsum([0; abs(ma(1:end-1))+abs(mi(2:end))]);
shift = repmat(shift,1,1024);

%plot 'eeg' data
plot(t,sig+shift)

% edit axes
set(gca,'ytick',mean(sig+shift,2),'yticklabel',1:32)
grid on
ylim([mi(1) max(max(shift+sig))])

end
function graphOpts2_CB(hObject, eventdata) end
function graphOpts3_CB(hObject, eventdata) end
function graphOpts4_CB(hObject, eventdata) end


%%  PAGE 2 - CHANNEL OPTIONS
function enableChannel_CB(hObject, eventdata, chNum)
%global deviceData;
if deviceData(currentDevice).ChannelState(chNum) == ENABLE
    %disable channel
    set(findobj('Tag', strcat('EI', num2str(chNum+((currentDevice-1)*8)))), 'Background', GREY);
    set(hObject, 'String', 'OFF');
    deviceData(currentDevice).ChannelState(chNum) = DISABLE;
    sendCommand(CHG_CH_STATE, currentDevice, chNum, DISABLE, 0);
else
    %enable channel
    set(findobj('Tag', strcat('EI', num2str(chNum+((currentDevice-1)*8)))), 'Background', 'g');
    set(hObject, 'String', 'ON');
    deviceData(currentDevice).ChannelState(chNum) = ENABLE;
    sendCommand(CHG_CH_STATE, currentDevice, chNum, ENABLE, 0);
end
end

function chgChannelGain_CB(hObject, eventdata, chNum)
%global deviceData;
gainValues = [1 2 4 6 8 12 24];
deviceData(currentDevice).ChannelGain(chNum) = NEXT_GAIN( deviceData(currentDevice).ChannelGain(chNum) )
set(hObject, 'String', strcat('GAIN: ', num2str(gainValues(bitshift( deviceData(currentDevice).ChannelGain(chNum) , -4) +1 ))))
sendCommand(CHG_CH_GAIN, currentDevice, chNum, deviceData(currentDevice).ChannelGain(chNum), 0);
end

function chgChannelSRB2_CB(hObject, eventdata, chNum)
deviceData(currentDevice).ChannelSRB2Con(chNum) = ~deviceData(currentDevice).ChannelSRB2Con(chNum);
if deviceData(currentDevice).ChannelSRB2Con(chNum) == ENABLE
    set(hObject, 'String', 'SRB2: CONN');
    deviceData(currentDevice).ChannelSRB2Con(chNum) = ENABLE;
    sendCommand(CHG_CH_SRB2, currentDevice, chNum, ENABLE, 0);
else
    set(hObject, 'String', 'SRB2: DISCON');
    deviceData(currentDevice).ChannelSRB2Con(chNum) = DISABLE;
    sendCommand(CHG_CH_SRB2, currentDevice, chNum, DISABLE, 0);
end
end



function chgChannelMUX_CB(hObject, eventdata, chNum)
muxSetting = get(hObject, 'value') - 1
deviceData(currentDevice).ChannelMUX(chNum) = bitand(muxSetting, 248); %0b11111000
if deviceData(currentDevice).ChannelState(chNum) == ENABLE
%    set(findobj('Tag', strcat('MUXSTAT', num2str(chNum))), 'String', muxSettingNames(bitand(muxSetting, 248)));
end
sendCommand(CHG_CH_MUX, currentDevice, chNum, muxSetting, 0);
end



function disableAllTestSignals_CB(hObject, eventdata)
deviceData(currentDevice).TestSignalsGeneratedInternally = DISABLE
for i = 1:8
    if deviceData(currentDevice).ChannelMUX(i) == MUX_TESTSIG | deviceData(currentDevice).ChannelMUX(i) == MUX_SHORTED
        deviceData(currentDevice).ChannelMUX(i) = MUX_NORMAL
        sendCommand(CHG_CH_MUX, currentDevice, i, MUX_NORMAL, 0);
    end
end
sendCommand(DEACT_TEST, currentDevice, 0, 0, 0);

end

function enableTestSignals_CB(hObject, eventdata)
for i = 1:8
    deviceData(currentDevice).ChannelMUX(i) = MUX_TESTSIG;
    sendCommand(CHG_CH_MUX, currentDevice, i, MUX_TESTSIG, 0);
end
sendCommand(ACT_TEST, currentDevice, deviceData(currentDevice).TestSignalAmplitude, deviceData(currentDevice).TestSignalFrequency, 0);
end

function chgTestAmplitude_CB(hObject, eventdata)
sendCommand(CHG_TEST_AMP, currentDevice, deviceData(currentDevice).TestSignalAmplitude, 0, 0);
end

function chgTestFrequency_CB(hObject, eventdata)
sendCommand(CHG_TEST_FREQ, currentDevice, deviceData(currentDevice).TestSignalFrequency, 0, 0);
end

function shortAllChannels_CB(hObject, eventdata)
for i = 1:8
        deviceData(currentDevice).ChannelMUX(i) = MUX_SHORTED;
        sendCommand(CHG_CH_MUX, currentDevice, i, MUX_SHORTED, 0);
end
end

%%  PAGE 3 - LEAD OFF

function enableLoff_CB(hObject, eventdata)
deviceData(currentDevice).PDLOFFComparator = ~deviceData(currentDevice).PDLOFFComparator;
if deviceData(currentDevice).PDLOFFComparator
    sendCommand(EN_LOFF_COMP, currentDevice, 0,0,0);
    for i = 1:8
        deviceData(currentDevice).LOFFSenseP(i) = ENABLE;
        deviceData(currentDevice).LOFFSenseN(i) = ENABLE;
        sendCommand(LOFF_DETECT_P, currentDevice, i, deviceData(currentDevice).LOFFSenseP(i), 0);
        sendCommand(LOFF_DETECT_N, currentDevice, i, deviceData(currentDevice).LOFFSenseN(i), 0);
    end
else
    sendCommand(DIS_LOFF_COMP, currentDevice, 0,0,0);
    for i = 1:8
        deviceData(currentDevice).LOFFSenseP(i) = DISABLE;
        deviceData(currentDevice).LOFFSenseN(i) = DISABLE;
        sendCommand(LOFF_DETECT_P, currentDevice, i, deviceData(currentDevice).LOFFSenseP(i), 0);
        sendCommand(LOFF_DETECT_N, currentDevice, i, deviceData(currentDevice).LOFFSenseN(i), 0);
    end
end

end

function chgLoffThreshold_CB(hObject, eventdata)
deviceData(currentDevice).LOFFComparatorThreshold = NEXT_LOFF_THRESH(deviceData(currentDevice).LOFFComparatorThreshold);
sendCommand(SET_LOFF_THRESH, currentDevice, deviceData(currentDevice).LOFFComparatorThreshold, 0, 0);
end

function chgLoffAmplitude_CB(hObject, eventdata)
deviceData(currentDevice).LOFFCurrentMagnitude = NEXT_LOFF_AMP(deviceData(currentDevice).LOFFCurrentMagnitude);
sendCommand(SET_LOFF_CUR_MAG, currentDevice, deviceData(currentDevice).LOFFCurrentMagnitude, 0, 0);
end

function chgLoffFrequency_CB(hObject, eventdata)
deviceData(currentDevice).LOFFFrequency = NEXT_LOFF_FREQ(deviceData(currentDevice).LOFFFrequency);
sendCommand(SET_LOFF_FREQ, currentDevice, deviceData(currentDevice).LOFFFrequency, 0, 0);
end


function chgLoffSenseP_CB(hObject, eventdata, chNum)
deviceData(currentDevice).LOFFSenseP(chNum) = ~deviceData(currentDevice).LOFFSenseP(chNum);
sendCommand(LOFF_DETECT_P, currentDevice, chNum, deviceData(currentDevice).LOFFSenseP(chNum), 0);
end
function chgLoffSenseN_CB(hObject, eventdata, chNum)
deviceData(currentDevice).LOFFSenseN(chNum) = ~deviceData(currentDevice).LOFFSenseN(chNum);
sendCommand(LOFF_DETECT_N, currentDevice, chNum, deviceData(currentDevice).LOFFSenseN(chNum), 0);
end
function chgLoffCurrentDirection_CB(hObject, eventdata, chNum)
deviceData(currentDevice).LOFFCurrentDirection(chNum) = ~deviceData(currentDevice).LOFFCurrentDirection(chNum);
sendCommand(LOFF_CUR_DIR, currentDevice, chNum, deviceData(currentDevice).LOFFCurrentDirection(chNum), 0);
end

%% TODO
function runBiasLoffSense_CB(hObject, eventdata)
%global deviceData;
end

%%  PAGE 4 - BIAS CONFIG

function enableBias_CB(hObject, eventdata) end %GET RID OF THIS

function rerouteBias_CB(hObject, eventdata)
    chNum = str2num ( get(findobj('Parent', rerouteBias_HB, '-and', 'Tag', 'CH'), 'String') );
    chPol = get(findobj('Parent', rerouteBias_HB, '-and', 'Tag', 'POL'), 'String');
 
    if deviceData(currentDevice).ChannelMUX(chNum) == MUX_BIAS_DRN | deviceData(currentDevice).ChannelMUX(chNum) == MUX_BIAS_DRP
        %disable reroute bias
        set(findobj('Tag', strcat('CH', num2str(chNum), 'OPT_MUX')), 'value', MUX_NORMAL + 1)
        deviceData(currentDevice).ChannelMUX(chNum) = MUX_NORMAL;
        sendCommand(DIS_REROUTE_BIAS, currentDevice, chNum, 0, 0);
    else
        %enable bias reroute
        if chPol == 'N'
            set(findobj('Tag', strcat('CH', num2str(chNum), 'OPT_MUX')), 'value', MUX_BIAS_DRN + 1)
            deviceData(currentDevice).ChannelMUX(chNum) = MUX_BIAS_DRN;
        else
            set(findobj('Tag', strcat('CH', num2str(chNum), 'OPT_MUX')), 'value', MUX_BIAS_DRP + 1)
            deviceData(currentDevice).ChannelMUX(chNum) = MUX_BIAS_DRP;
        end
        deviceData(currentDevice).LOFFSenseN(chNum) = DISABLE;
        deviceData(currentDevice).LOFFSenseP(chNum) = DISABLE;
        deviceData(currentDevice).BiasSenseN(chNum) = DISABLE;
        deviceData(currentDevice).BiasSenseP(chNum) = DISABLE;
    
        if chPol == 'N'
            sendCommand(EN_REROUTE_BIAS, currentDevice, chNum, NCHAN, 0);
        else
            sendCommand(EN_REROUTE_BIAS, currentDevice, chNum, PCHAN, 0);
        end
    end
        
    
end

function chgRerouteBiasChannel_CB(hObject, eventdata)
    chNum = str2num(get(hObject, 'String'))
    if chNum == 8
        set(hObject, 'String', '1')
    else
        set(hObject, 'String', num2str(chNum+1))
    end
end

function chgRerouteBiasPolarity_CB(hObject, eventdata)
    if get(hObject, 'String') == 'N'
        set(hObject, 'String', 'P')
    else
        set(hObject, 'String', 'N')
    end
end

function measureBias_CB(hObject, eventdata)
    chNum = str2num ( get(findobj('Parent', rerouteBias_HB, '-and', 'Tag', 'CH'), 'String') );
    
    if deviceData(currentDevice).ChannelMUX(chNum) == MUX_BIAS_MEAS
        %disable bias measure
        set(findobj('Tag', strcat('CH', num2str(chNum), 'OPT_MUX')), 'value', MUX_NORMAL + 1)
        sendCommand(DIS_MEASURE_BIAS, currentDevice, chNum, 0, 0);
    else
        %enable bias easure
        set(findobj('Tag', strcat('CH', num2str(chNum), 'OPT_MUX')), 'value', MUX_BIAS_MEAS + 1)
        deviceData(currentDevice).ChannelMUX(chNum) = MUX_BIAS_MEAS;
        deviceData(currentDevice).LOFFSenseN(chNum) = DISABLE;
        deviceData(currentDevice).LOFFSenseP(chNum) = DISABLE;
        deviceData(currentDevice).BiasSenseN(chNum) = DISABLE;
        deviceData(currentDevice).BiasSenseP(chNum) = DISABLE;
        sendCommand(EN_MEASURE_BIAS, currentDevice, chNum, 0, 0);
    end
end

function chgMeasureBiasChannel_CB(hObject, eventdata)
    chNum = str2num(get(hObject, 'String'))
    if chNum == 8
        set(hObject, 'String', '1')
    else
        set(hObject, 'String', num2str(chNum+1))
    end
end

function chgBiasReferenceSource_CB(hObject, eventdata)
    deviceData(currentDevice).PDInternalBiasRef = ~deviceData(currentDevice).PDInternalBiasRef;
end

function enableBiasBuffer_CB(hObject, eventdata)
    deviceData(currentDevice).PDBiasReferenceBuffer = ~deviceData(currentDevice).PDBiasReferenceBuffer;
    if deviceData(currentDevice).PDBiasReferenceBuffer
        sendCommand(EN_BIAS_BUFF, currentDevice, 0,0,0);
    else
        sendCommand(DIS_BIAS_BUFF, currentDevice, 0,0,0);
    end
end

function chgBiasSenseP_CB(hObject, eventdata, chNum)
deviceData(currentDevice).BiasSenseP(chNum) = ~deviceData(currentDevice).BiasSenseP(chNum);
sendCommand(CHG_BIAS_SENS_P, currentDevice, chNum, deviceData(currentDevice).BiasSenseP(chNum), 0);
end
function chgBiasSenseN_CB(hObject, eventdata, chNum)
deviceData(currentDevice).BiasSenseN(chNum) = ~deviceData(currentDevice).BiasSenseN(chNum);
sendCommand(CHG_BIAS_SENS_N, currentDevice, chNum, deviceData(currentDevice).BiasSenseN(chNum), 0);
end

%%  PAGE 5 - DEVICE CONFIG

function enableOscOut_CB(hObject, eventdata)
%global deviceData;
end
function enableDaisyChain_CB(hObject, eventdata)
%global deviceData;
end
function enableInternalReference_CB(hObject, eventdata)
%global deviceData;
end
function enableSRB1Connection_CB(hObject, eventdata)
%global deviceData;
end
function chgConversionMode_CB(hObject, eventdata)
%global deviceData;
end

function saveGlobalConfig_CB(hObject, eventdata)
%global deviceData;
end
function loadGlobalConfig_CB(hObject, eventdata)
%global deviceData;
end
function saveDeviceConfig_CB(hObject, eventdata)
%global deviceData;
end
function loadDeviceConfig_CB(hObject, eventdata)
%global deviceData;
end

function loadMasterDeviceConfig_CB(hObject, eventdata)
%global deviceData;
end
function loadSlaveDeviceConfig_CB(hObject, eventdata)
%global deviceData;
end
function loadManualDeviceConfig_CB(hObject, eventdata)
%global deviceData;
end




end
%  Utility functions for MYUI
















