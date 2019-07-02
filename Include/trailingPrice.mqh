//+------------------------------------------------------------------+
//|                                                trailingPrice.mqh |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property strict

double trailing(string type, double trailingPrice, double distance)
{   
   if(type == "buy")
   {
      if(Ask + distance > trailingPrice)
         return trailingPrice; //Price has increased, so don't do anything
      else
         return Ask + distance; //Price has decreased, so we lower our trailing price
   }else if(type == "sell")
   {
      return 0;
   }else
   {
      return 0; //Error. This should never happen
   }
}