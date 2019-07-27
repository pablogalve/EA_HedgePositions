//+------------------------------------------------------------------+
//|                                                    getLowMax.mqh |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property strict

double getLow(string timeframe, int nCandles)
{
   double low = 999999;
   
   for(int i=0;i<nCandles;i++)
   {
      if(timeframe == "M30")
      {
         if(iLow(NULL,PERIOD_M30,i) < low)
            low = iLow(NULL,PERIOD_M30,i);
                  
      }else if(timeframe == "H1")
      {
         if(iLow(NULL,PERIOD_H1,i) < low)     
            low = iLow(NULL,PERIOD_H1,i);
          
      }else if(timeframe == "H4")
      {
         if(iLow(NULL,PERIOD_H4,i) < low)     
            low = iLow(NULL,PERIOD_H4,i);
      }else if(timeframe == "D1")
      {
         if(iLow(NULL,PERIOD_D1,i) < low)     
            low = iLow(NULL,PERIOD_D1,i);
      }else if(timeframe == "W1")
      {
         if(iLow(NULL,PERIOD_W1,i) < low)     
            low = iLow(NULL,PERIOD_W1,i);
      }
   }
   if(low == 999999)
      Alert("Error in <getLowMax.mqh>. We return value of: ", low);
    
   return low;   
}

double getHigh(string timeframe, int nCandles)
{
   double high = 0;
   
   for(int i=0;i<nCandles;i++)
   {
      if(timeframe == "M30")
      {
         if(iHigh(NULL,PERIOD_M30,i) > high)
            high = iHigh(NULL,PERIOD_M30,i);
                  
      }else if(timeframe == "H1")
      {
         if(iHigh(NULL,PERIOD_H1,i) > high)     
            high = iHigh(NULL,PERIOD_H1,i);
          
      }else if(timeframe == "H4")
      {
         if(iHigh(NULL,PERIOD_H4,i) > high)     
            high = iHigh(NULL,PERIOD_H4,i);
      }else if(timeframe == "D1")
      {
         if(iHigh(NULL,PERIOD_D1,i) > high)     
            high = iHigh(NULL,PERIOD_D1,i);
      }else if(timeframe == "W1")
      {
         if(iHigh(NULL,PERIOD_W1,i) > high)     
            high = iHigh(NULL,PERIOD_W1,i);
      }
   }
   if(high == 0)
      Alert("Error in <getLowMax.mqh>. We return value of: ", high);
    
   return high;   
}