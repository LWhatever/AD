#ifndef SINGLE_PHASE_POWER_TLC3578_H_
#define SINGLE_PHASE_POWER_TLC3578_H_
/*
 * TLC3578.h
 *
 *  Created on: 2019年4月15日
 *      Author: LWhatever
 */
#include<msp430.h>




#define      TLC3578_CS         BIT0  //这是配置单片机的管脚，与3578上的名字对应
#define      TLC3578_CLK        BIT2
#define      TLC3578_OUT        BIT3
#define      TLC3578_IN         BIT1


#define      TLC3578_Port_OUT   P2OUT  //这个是单片机上管脚开头编号，即P1.0接CS,P1.1接CLK,P1.2接DIN,P1.3接DOUT
#define      TLC3578_Port_DIR   P2DIR
#define      TLC3578_Port_IN    P2IN

#define      TLC3578_CS_OUT     (TLC3578_Port_DIR|=TLC3578_CS)
#define      SET_TLC3578_CS     (TLC3578_Port_OUT|=TLC3578_CS)
#define      CLR_TLC3578_CS     (TLC3578_Port_OUT&=~TLC3578_CS)

#define      TLC3578_CLK_OUT    (TLC3578_Port_DIR|=TLC3578_CLK)
#define      SET_TLC3578_CLK    (TLC3578_Port_OUT|=TLC3578_CLK)
#define      CLR_TLC3578_CLK    (TLC3578_Port_OUT&=~TLC3578_CLK)

#define      TLC3578_OUT_IN     (TLC3578_Port_DIR&=~TLC3578_OUT)
#define      TLC3578_OUT_Val    (TLC3578_Port_IN&TLC3578_OUT)

#define      TLC3578_IN_OUT     (TLC3578_Port_DIR|=TLC3578_IN)
#define      SET_TLC3578_IN     (TLC3578_Port_OUT|=TLC3578_IN)
#define      CLR_TLC3578_IN     (TLC3578_Port_OUT&=~TLC3578_IN)

unsigned int INT_reg = 0xA000, config_reg = 0xAA00;

void TLC3578_Initial();
unsigned int TLC3578_RD_WR(unsigned int);
unsigned int TLC3578_Get_U(unsigned int);
/*
sel_ch0 = 0x0000;

 */

unsigned int TLC3578_RD_WR(unsigned int data)
{
    unsigned int i,temp,Din;
    temp=data;
    for(i=0;i<16;i++)
    {
        Din = Din<<1;
        SET_TLC3578_CLK;
        if(0x80&temp)
            SET_TLC3578_IN;
        else
            CLR_TLC3578_IN;
        __delay_cycles(1);
        CLR_TLC3578_CLK;
        if(TLC3578_OUT_Val)
            Din |= 0x0001;
        __delay_cycles(1);
        temp = (temp<<1);
    }
    return Din;
}

void TLC3578_Initial(void)
{
    TLC3578_CS_OUT;
    TLC3578_CLK_OUT;
    TLC3578_IN_OUT;
    TLC3578_OUT_IN;
    CLR_TLC3578_CS;
    _NOP();
    CLR_TLC3578_CLK;
    _NOP();
    CLR_TLC3578_IN;
    _NOP();
    TLC3578_RD_WR(INT_reg);
    __delay_cycles(1);		
    TLC3578_RD_WR(INT_reg);
}

unsigned int TLC3578_Get_U(unsigned int ch)
{
    CLR_TLC3578_CS;
    unsigned int i=0;
    unsigned int Data_REG;
    Data_REG = TLC3578_Read(ch);
    SET_TLC3578_CS;
//  Config_Result_M = TLC3578_Read(Config_M);
//  __delay_cycles(1);
//  Config_Result_L = TLC3578_Read(Config_L);
    CLR_TLC3578_IN;
    _NOP();
}

#endif /* SINGLE_PHASE_POWER_TLC3578_H_ */