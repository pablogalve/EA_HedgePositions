//+------------------------------------------------------------------+
//|                                              entryOportunity.mqh |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property strict

#include <getLowMax.mqh>

bool buyOportunity(bool buyInterest)
{
   bool priceAtMin = false;

   //We check that our buyInterest is at a 7-day low or 20pips higher    
   if(getLow("D1",30) >= iLow(NULL,PERIOD_D1,1) - 200*_Point)
      priceAtMin = true;
   
   //We only buy if we have buyInterest and price is at a relative low
   if(buyInterest==true && priceAtMin == true)
      return true;
      
   else if(buyInterest==false && priceAtMin == true)
      return false;   
      
   else if(buyInterest==true && priceAtMin == false)
      return false;
      
   else if(buyInterest==false && priceAtMin == false)
      return false;
        
   else
      return false;       
}

bool sellOportunity(bool sellInterest, bool priceAtMax)
{
   if(sellInterest==true && priceAtMax == true)
      return true;
      
   else if(sellInterest==false && priceAtMax == true)
      return false;   
      
   else if(sellInterest==true && priceAtMax == false)
      return false;
      
   else if(sellInterest==false && priceAtMax == false)
      return false;
        
   else
      return false;       
}