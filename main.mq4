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
input double SL = 20;
input double TP = 1.2;
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
      //int testBuy = OrderSend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,comment,magic,dateexpiration,color);
      int buy = OrderSend(NULL,OP_BUY,lots,Ask,10,NULL,TP,NULL,magic,NULL,clrGreen);
      int sellStop = OrderSend(NULL,OP_SELLSTOP,lots,iLow(NULL,PERIOD_D1,1)-20*_Point,10,NULL,NULL,NULL,magic,NULL,clrRed);
   }else if(buyInterest()==true && OrdersTotal()==2)
   {
      Print("111111111OrdersTotal: " + OrdersTotal());
      int closeOrder = OrderSelect(1,SELECT_BY_POS,MODE_TRADES);
      int closeSellStop = OrderClose(OrderTicket(),lots,Ask,10,clrRed);
      Print("222222222OrdersTotal: " + OrdersTotal());
      int sellStop2 = OrderSend(NULL,OP_SELLSTOP,lots,iLow(NULL,PERIOD_D1,1)-20*_Point,10,NULL,NULL,NULL,magic,NULL,clrRed);
      Print("333333333OrdersTotal: " + OrdersTotal());
      
   }
         
  }
  
bool buyInterest()
{
   //if(iClose(NULL,PERIOD_D1,1) > iClose(NULL,PERIOD_D1,2))
      return true;
   //else
   //   return false;  
}