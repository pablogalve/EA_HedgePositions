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
   distance = distance * _Point;
   if(type == "up")
   {
      if(trailingPrice == 0)
         return Bid - distance; //If trailingPrice is not set
      else if(Bid - distance > trailingPrice)
         return Bid - distance; //Price has increased, so we increase our trailing price
      else if(Bid - distance <= trailingPrice)
         return trailingPrice; //Price has decreased, so we return the same value   
      
      
   }
   else if(type == "down")
   {
      if(trailingPrice == 0)
         return Ask+distance; //If trailingPrice is not set    
      else if(Ask + distance > trailingPrice)
         return trailingPrice; //Price has increased, so we return the same value
      else if(Ask + distance <= trailingPrice)
         return Ask + distance; //Price has decreased, so we lower our trailing price
      
   }else
   {
      return 0; //Error. This should never happen
   }
   return 0; //Error. This should never happen
}