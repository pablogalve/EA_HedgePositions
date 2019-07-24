//+------------------------------------------------------------------+
//|                                                trailingPrice.mqh |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property strict

double trailingPrice(string type, double trailingPrice, double distance)
{  
   if(type == "buy")
   {
      if(Ask + distance > trailingPrice)
         return trailingPrice; //Price has increased, so we return the same value
      else if(Ask + distance <= trailingPrice)
         return Ask + distance; //Price has decreased, so we lower our trailing price
      else if(trailingPrice == 0)
         return Ask; //If trailingPrice is not set 
   }
   else if(type == "sell")
   {
      return 0;
   }else
   {
      return 0; //Error. This should never happen
   }
   return 0; //Error. This should never happen
}