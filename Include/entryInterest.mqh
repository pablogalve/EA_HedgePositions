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
   double minDist = 5*_Point;
   double auxSize;
   
   if(iOpen(NULL,PERIOD_D1,1)-500*_Point > iLow(NULL,PERIOD_D1,1))
   {
      if(2*(iClose(NULL,PERIOD_D1,1)-iOpen(NULL,PERIOD_D1,1))<iOpen(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1)){
         auxSize = iOpen(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1);
         if(iClose(NULL,PERIOD_D1,1)+(auxSize/3)>iHigh(NULL,PERIOD_D1,1)){
            return true;
         }else{
            return false;
         }
      }else{
         return false;
      }
   }else{
      return false;
   }
      
      
      
}