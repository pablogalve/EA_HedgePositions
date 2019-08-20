//+------------------------------------------------------------------+
//|                                                       UpDown.mqh |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property strict



bool UpDown(double startPrice, double TP)
{
   if(startPrice < TP)
      return 1; //Up. Our position is long/buy
   else if(startPrice > TP)
      return 0; //Down. Our position is short/sell
   else
      return 0;   
}