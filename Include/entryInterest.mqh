//+------------------------------------------------------------------+
//|                                                entryInterest.mqh |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property strict

bool buyInterest()
{
   if(iClose(NULL,PERIOD_D1,1) > iClose(NULL,PERIOD_D1,2))
      return true;
   else
      return false;  
}