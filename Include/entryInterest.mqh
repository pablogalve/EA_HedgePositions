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
   double minDist = 500*_Point;
   double mechaSize;
   double mechaD1MinPips = 400*_Point;
 
   //Hammer with open >= close //Martillo
   if(iOpen(NULL,PERIOD_D1,1) >= iClose(NULL,PERIOD_D1,1))
   {
      if((iClose(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1)) >= mechaD1MinPips)
      {
         //Candle's body must be at least half of the mecha
         if((iOpen(NULL,PERIOD_D1,1)-iClose(NULL,PERIOD_D1,1))
         < 2*(iClose(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1)))
         {
            mechaSize = iClose(NULL,PERIOD_D1,1) - iLow(NULL,PERIOD_D1,1);
            //Upper mecha must be 1/3 or less of the size
            if(iOpen(NULL,PERIOD_D1,1)+(mechaSize/3) > iHigh(NULL,PERIOD_D1,1)){
               return true;
            }
         }         
      }
   //Hammer with close > Open //Martillo
   }else if(iOpen(NULL,PERIOD_D1,1) < iClose(NULL,PERIOD_D1,1))
   {
      if((iOpen(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1)) >= mechaD1MinPips)
      {
         if((iClose(NULL,PERIOD_D1,1)-iOpen(NULL,PERIOD_D1,1))
         < 2*(iOpen(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1)))
         {
            mechaSize = iOpen(NULL,PERIOD_D1,1) - iLow(NULL,PERIOD_D1,1);
            //Upper mecha must be 1/3 or less of the size
            if(iClose(NULL,PERIOD_D1,1)+(mechaSize/3) > iHigh(NULL,PERIOD_D1,1)){
               return true;
            }
         } 
      }
   }
   return false;
}