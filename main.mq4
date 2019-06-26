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
int slippage = 10;

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
      int buy = OrderSend(NULL,OP_BUY,lots,Ask,slippage,NULL,TP,NULL,magic,NULL,clrGreen);
      int sellStop = OrderSend(NULL,OP_SELLSTOP,lots,iLow(NULL,PERIOD_D1,1)-20*_Point,slippage,NULL,NULL,NULL,magic,NULL,clrRed);
   }else if(buyInterest()==true && OrdersTotal()==2)
   {
      Print("111111111OrdersTotal: " + OrdersTotal());
      int closeOrder = OrderSelect(1,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_SELL)
      {
         int closeSellStop = OrderClose(OrderTicket(),lots,Ask,10,clrRed);
      }else if(OrderType()==OP_SELLSTOP)
      {
         int closeSellStop = OrderDelete(OrderTicket(),clrRed);
      }      
      Print("222222222OrdersTotal: " + OrdersTotal());
      int sellStop2 = OrderSend(NULL,OP_SELLSTOP,lots,iLow(NULL,PERIOD_D1,1)-50*_Point,slippage,NULL,NULL,NULL,magic,NULL,clrRed);
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

int MarketOrderSend(string symbol, int cmd, double volume, double price, int slipagge, double stoploss, double takeprofit, string comment)
{
   int newOrder;
   
   newOrder = OrderSend(symbol, cmd, volume, price, slippage, 0, 0, NULL, magic);
   if(newOrder <= 0)Alert("OrderSend Error: ", GetLastError());
   else
   {
      bool res = OrderModify(newOrder,0,stoploss,takeprofit,0);
      if(!res){
         Alert("OrderModify Error: ", GetLastError());
         Alert("IMPORTANT: ORDER #", newOrder, " HAS NO STOPLOSS AND TAKEPROFIT");
      }
   }
   return(newOrder);
}
