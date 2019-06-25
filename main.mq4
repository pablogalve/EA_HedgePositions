//+------------------------------------------------------------------+
//|                                               HedgePositions.mq4 |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
input int magic = 17;
input double lots = 0.01;
input double SL = 4;
input double TP = 1.19;
bool oportunity = true;

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
  }
void OnTick()
  {
   if(iHigh(NULL,PERIOD_W1,0) >= TP)
   {
      //Price touched TP, so we stop operating that pair
      oportunity = false;
   }
   
   if(buyInterest()==true && OrdersTotal() < 2)
   {
      Print("--------------------------------Orders Total: " + OrdersTotal());
      int buy = OrderSend(NULL,OP_BUY,lots,Ask,10,NULL,TP,NULL,magic,NULL,clrGreen);
      int sellStop = OrderSend(NULL,OP_SELLSTOP,lots,Bid,10,NULL,NULL,NULL,magic,NULL,clrGreen);
   }
         
  }
  
bool buyInterest()
{
   if(iClose(NULL,PERIOD_D1,1) > iClose(NULL,PERIOD_D1,2))
      return true;
   else
      return false;  
}