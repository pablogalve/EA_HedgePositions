//+------------------------------------------------------------------+
//|                                              checkTakeProfit.mqh |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property strict

bool checkTakeProfit(double TP, string type)
{  
   //returns true if price has touched take profit. False if not
   if(type == "buy")
   {
      if(Bid >= TP)
         return true;
      else
         return false;   
   }
   if(type == "sell")
   {
      if(Ask <= TP)
         return true;
      else
         return false;         
   }
   //IF there is an error, return false
   return false;
}