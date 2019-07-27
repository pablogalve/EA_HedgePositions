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
   double mechaSize;
   double mechaD1MinPips = 400*_Point;
   double envolventeMinPips = 300*_Point;
   double envolventeSize;
 
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
   }
   if(iOpen(NULL,PERIOD_D1,1) < iClose(NULL,PERIOD_D1,1))
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
   //Envolvente Alcista
   if(iOpen(NULL,PERIOD_D1,2) > (iClose(NULL,PERIOD_D1,2) + envolventeMinPips))
   {
      if(iClose(NULL,PERIOD_D1,1) > iClose(NULL,PERIOD_D1,2))
      {
         envolventeSize = iOpen(NULL,PERIOD_D1,2) - iClose(NULL,PERIOD_D1,2);
         if((iClose(NULL,PERIOD_D1,1) - iOpen(NULL,PERIOD_D1,1)) > 0.6*(envolventeSize))
         {
            if((iClose(NULL,PERIOD_D1,1) - iOpen(NULL,PERIOD_D1,1)) < 1.3 *(envolventeSize))
            {
               return true;
            }
         }
      }
   }
   return false;
}

bool sellInterest()
{
   double mechaSize;
   double mechaD1MinPips = 400*_Point;
   double envolventeMinPips = 300*_Point;
   double envolventeSize;
 
   //Inverted Hammer with open >= close //Martillo invertido
   if(iOpen(NULL,PERIOD_D1,1) >= iClose(NULL,PERIOD_D1,1))
   {
      mechaSize = iHigh(NULL,PERIOD_D1,1) - iOpen(NULL,PERIOD_D1,1);
      if(mechaSize >= mechaD1MinPips)
      {
         //Candle's body must be at least half of the mecha
         if((iOpen(NULL,PERIOD_D1,1)-iClose(NULL,PERIOD_D1,1)) < 2*mechaSize)
         {           
            //Upper mecha must be 1/3 or less of the size
            if(iClose(NULL,PERIOD_D1,1)+(mechaSize/3) < iLow(NULL,PERIOD_D1,1)){
               return true;
            }
         }         
      }
   //Inverted Hammer with close > Open //Martillo invertido
   }
   if(iOpen(NULL,PERIOD_D1,1) < iClose(NULL,PERIOD_D1,1))
   {
      mechaSize = iHigh(NULL,PERIOD_D1,1) - iClose(NULL,PERIOD_D1,1);
      if(mechaSize >= mechaD1MinPips)
      {
         if((iClose(NULL,PERIOD_D1,1)-iOpen(NULL,PERIOD_D1,1)) < 2*mechaSize)
         {            
            //Upper mecha must be 1/3 or less of the size
            if(iOpen(NULL,PERIOD_D1,1)+(mechaSize/3) < iLow(NULL,PERIOD_D1,1)){
               return true;
            }
         } 
      }
   }
   //Envolvente bajista
   if(iOpen(NULL,PERIOD_D1,2) < (iClose(NULL,PERIOD_D1,2) - envolventeMinPips))
   {
      if(iClose(NULL,PERIOD_D1,1) < iClose(NULL,PERIOD_D1,2))
      {
         envolventeSize = iClose(NULL,PERIOD_D1,2) - iOpen(NULL,PERIOD_D1,2);
         if((iOpen(NULL,PERIOD_D1,1) - iClose(NULL,PERIOD_D1,1)) > 0.6*(envolventeSize))
         {
            if(iOpen(NULL,PERIOD_D1,1) - (iClose(NULL,PERIOD_D1,1)) < 1.3 *(envolventeSize))
            {
               return true;
            }
         }
      }
   }
   return false;
}